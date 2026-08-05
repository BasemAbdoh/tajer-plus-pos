import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/exchange_rate_provider.dart';
import '../core/currency_manager.dart';
import '../core/app_localizations.dart';
import '../services/backup_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadAllProducts();
      context.read<ExchangeRateProvider>().loadRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final productProvider = context.watch<ProductProvider>();
    final rateProvider = context.watch<ExchangeRateProvider>();

    final allProducts = productProvider.allProducts;
    final rates = rateProvider.rates;
    final expiringSoonProducts = productProvider.getExpiringSoonProducts(daysThreshold: 30);

    double totalCapitalLocal = 0;
    double totalExpectedProfitLocal = 0;

    Map<String, int> categoryCounts = {};
    Map<String, double> categoryProfitLocal = {};

    for (var p in allProducts) {
      double packPurchaseLocal = CurrencyManager.convertToLocal(p.packPurchasePrice, p.currency, rates);
      double totalSaleLocal = CurrencyManager.convertToLocal(p.totalSalePrice, p.currency, rates);
      double profitLocal = totalSaleLocal - packPurchaseLocal;

      totalCapitalLocal += (packPurchaseLocal * p.stockPacks);
      totalExpectedProfitLocal += (profitLocal * p.stockPacks);

      categoryCounts[p.category] = (categoryCounts[p.category] ?? 0) + 1;
      categoryProfitLocal[p.category] = (categoryProfitLocal[p.category] ?? 0) + (profitLocal * p.stockPacks);
    }

    final sortedByProfit = List<Product>.from(allProducts)
      ..sort((a, b) {
        double profitA = CurrencyManager.convertToLocal(a.profit, a.currency, rates);
        double profitB = CurrencyManager.convertToLocal(b.profit, b.currency, rates);
        return profitB.compareTo(profitA);
      });
    final top5Profitable = sortedByProfit.take(5).toList();

    final categoryProfitEntries = categoryProfitLocal.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategoriesProfit = categoryProfitEntries.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.dashboard, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 42, 150, 177),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: t.exportCsv,
            onPressed: () async {
              final backupService = BackupService(productProvider.repository);
              try {
                await backupService.shareCsvReport();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to share report: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await productProvider.loadAllProducts();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.financialSummary,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _buildAnimatedStatCard(
                    index: 0,
                    title: t.totalItems,
                    value: '${allProducts.length}',
                    icon: Icons.inventory_2,
                    color: Colors.blue,
                  ),
                  _buildAnimatedStatCard(
                    index: 1,
                    title: t.lowStockItems,
                    value: '${productProvider.lowStockCount}',
                    icon: Icons.warning_amber_outlined,
                    color: Colors.orange,
                  ),
                  _buildAnimatedStatCard(
                    index: 2,
                    title: 'Stored Capital',
                    value: '${totalCapitalLocal.toStringAsFixed(0)} YER',
                    icon: Icons.account_balance_wallet,
                    color: Colors.teal,
                  ),
                  _buildAnimatedStatCard(
                    index: 3,
                    title: t.expectedProfit,
                    value: '${totalExpectedProfitLocal.toStringAsFixed(0)} YER',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                  _buildAnimatedStatCard(
                    index: 4,
                    title: t.expiryDate,
                    value: '${expiringSoonProducts.length}',
                    icon: Icons.timer_outlined,
                    color: Colors.deepOrange,
                  ),
                ],
              ),
              if (expiringSoonProducts.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  t.expiringSoon,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.orange.shade50,
                  elevation: 2,
                  child: Column(
                    children: expiringSoonProducts.map((p) {
                      final daysLeft = p.expiryDate!.difference(DateTime.now()).inDays;
                      final isExpired = daysLeft < 0;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isExpired ? Colors.red.shade100 : Colors.orange.shade100,
                          child: Icon(
                            isExpired ? Icons.cancel : Icons.access_time_filled,
                            color: isExpired ? Colors.red : Colors.orange.shade900,
                          ),
                        ),
                        title: Text(p.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${t.category}: ${p.category} | ${p.expiryDate.toString().split(' ')[0]}'),
                        trailing: Text(
                          isExpired ? 'Expired!' : '$daysLeft days',
                          style: TextStyle(
                            color: isExpired ? Colors.red : Colors.orange.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              if (allProducts.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  t.chartsSection,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.categoryDistribution, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: categoryCounts.entries.map((e) {
                                final idx = categoryCounts.keys.toList().indexOf(e.key);
                                final color = Colors.primaries[idx % Colors.primaries.length];
                                final double percentage = (e.value / allProducts.length) * 100;
                                return PieChartSectionData(
                                  color: color,
                                  value: e.value.toDouble(),
                                  title: '${percentage.toStringAsFixed(0)}%',
                                  radius: 40,
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (topCategoriesProfit.isNotEmpty)
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Top Profitable Categories (YER)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 180,
                            child: BarChart(
                              BarChartData(
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();
                                        if (index >= 0 && index < topCategoriesProfit.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Text(
                                              topCategoriesProfit[index].key,
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ),
                                barGroups: topCategoriesProfit.asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  double val = entry.value.value;
                                  return BarChartGroupData(
                                    x: idx,
                                    barRods: [
                                      BarChartRodData(
                                        toY: val,
                                        color: const Color.fromARGB(255, 42, 150, 177),
                                        width: 18,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              Text(
                t.topProfitable,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (top5Profitable.isEmpty)
                Text(t.noProducts)
              else
                Card(
                  elevation: 2,
                  child: Column(
                    children: top5Profitable.map((p) {
                      double profitLocal = CurrencyManager.convertToLocal(p.profit, p.currency, rates);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(Icons.attach_money, color: Colors.green.shade800),
                        ),
                        title: Text(p.productName),
                        subtitle: Text('${t.category}: ${p.category} | ${t.stockPacks}: ${p.stockPacks}'),
                        trailing: Text(
                          '+${profitLocal.toStringAsFixed(1)} YER',
                          style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final backupService = BackupService(productProvider.repository);
                    try {
                      final path = await backupService.exportToCsv();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('CSV Exported: $path')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export failed: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: Text(t.exportCsv, style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 42, 150, 177),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStatCard({
    required int index,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOut,
      builder: (context, val, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - val)),
          child: Opacity(opacity: val, child: child),
        );
      },
      child: Card(
        elevation: 4,
        shadowColor: color.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
              const SizedBox(height: 4),
              FittedBox(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
