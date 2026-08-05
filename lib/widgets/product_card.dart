import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../core/currency_manager.dart';
import '../providers/exchange_rate_provider.dart';
import '../providers/product_provider.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final ExchangeRateProvider rateProvider;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onHistory;
  final VoidCallback onDecrementStock;

  const ProductCard({
    Key? key,
    required this.product,
    required this.rateProvider,
    required this.onEdit,
    required this.onDelete,
    required this.onHistory,
    required this.onDecrementStock,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isLowStock = product.stockPacks <= product.lowStockThreshold;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int? daysToExpiry;
    bool isExpired = false;
    bool isExpiringSoon = false;

    if (product.expiryDate != null) {
      final exp = DateTime(product.expiryDate!.year, product.expiryDate!.month, product.expiryDate!.day);
      daysToExpiry = exp.difference(today).inDays;
      if (daysToExpiry < 0) {
        isExpired = true;
      } else if (daysToExpiry <= 30) {
        isExpiringSoon = true;
      }
    }

    double displaySalePrice = product.salePrice;
    double displayPurchasePrice = product.purchasePrice;
    double displayPackPurchasePrice = product.packPurchasePrice;
    double displayTotalSalePrice = product.totalSalePrice;
    double displayProfit = product.profit;
    String currencySymbol = CurrencyManager.getCurrencySymbol(product.currency);

    if (widget.rateProvider.showPricesInLocalCurrency && product.currency != Currency.local) {
      displaySalePrice = CurrencyManager.convertToLocal(product.salePrice, product.currency, widget.rateProvider.rates);
      displayPurchasePrice = CurrencyManager.convertToLocal(product.purchasePrice, product.currency, widget.rateProvider.rates);
      displayPackPurchasePrice = CurrencyManager.convertToLocal(product.packPurchasePrice, product.currency, widget.rateProvider.rates);
      displayTotalSalePrice = CurrencyManager.convertToLocal(product.totalSalePrice, product.currency, widget.rateProvider.rates);
      displayProfit = displayTotalSalePrice - displayPackPurchasePrice;
      currencySymbol = "ر.ي (معدّل)";
    }

    Color profitColor = Colors.green;
    if (product.profit <= 0) {
      profitColor = Colors.red;
    } else if ((product.profit / (product.packPurchasePrice == 0 ? 1 : product.packPurchasePrice)) < 0.15) {
      profitColor = Colors.orange;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isExpired
            ? const BorderSide(color: Colors.red, width: 2)
            : (isExpiringSoon
                ? const BorderSide(color: Colors.orange, width: 1.5)
                : (isLowStock ? const BorderSide(color: Colors.amber, width: 1.5) : BorderSide.none)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: profitColor, width: 5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- الجزء العلوي المرئي دائماً ---
                  Row(
                    children: [
                      // الصورة إن وجدت أو الأيقونة
                      if (product.imagePath != null && File(product.imagePath!).existsSync())
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(product.imagePath!),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color.fromARGB(255, 42, 150, 177).withValues(alpha: 0.15),
                          child: const Icon(Icons.inventory_2, color: Color.fromARGB(255, 42, 150, 177)),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'القسم: ${product.category}',
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$currencySymbol ${displaySalePrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color.fromARGB(255, 42, 150, 177),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLowStock ? Colors.red.shade100 : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'المخزون: ${product.stockPacks} باكت',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isLowStock ? Colors.red.shade900 : Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),

                  if (isExpired || isExpiringSoon) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isExpired ? Colors.red.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isExpired ? Icons.cancel : Icons.access_time_filled,
                            size: 14,
                            color: isExpired ? Colors.red : Colors.orange.shade900,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isExpired
                                ? 'منتهي الصلاحية منذ ${daysToExpiry!.abs()} يوم'
                                : 'ينتهي بعد $daysToExpiry يوم (${product.expiryDate.toString().split(' ')[0]})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isExpired ? Colors.red.shade900 : Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // --- الجزء الموسّع بأنيميشن AnimatedCrossFade ---
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 20),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 3.5,
                          children: [
                            _buildDetailRow('سعر شراء الحبة:', '$currencySymbol ${displayPurchasePrice.toStringAsFixed(2)}'),
                            _buildDetailRow('سعر شراء الباكت:', '$currencySymbol ${displayPackPurchasePrice.toStringAsFixed(2)}'),
                            _buildDetailRow('العدد في الباكت:', '${product.packQuantity} حبة'),
                            _buildDetailRow('إجمالي سعر البيع:', '$currencySymbol ${displayTotalSalePrice.toStringAsFixed(2)}'),
                            _buildDetailRow(
                              'الفائدة المتوقعة:',
                              '$currencySymbol ${displayProfit.toStringAsFixed(2)}',
                              textColor: displayProfit > 0 ? Colors.green : Colors.red,
                            ),
                            _buildDetailRow('حد التنبيه:', '${product.lowStockThreshold} باكت'),
                            if (product.barcode != null && product.barcode!.isNotEmpty)
                              _buildDetailRow('الباركود:', product.barcode!),
                            if (product.expiryDate != null)
                              _buildDetailRow('تاريخ الانتهاء:', product.expiryDate.toString().split(' ')[0]),
                          ],
                        ),
                        if (product.notes != null && product.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.note, size: 16, color: Colors.amber),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'ملاحظات: ${product.notes!}',
                                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        // صف أزرار الإجراءات السريعة
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: widget.onDecrementStock,
                                  icon: const Icon(Icons.remove_circle_outline, size: 16, color: Colors.deepOrange),
                                  label: const Text('سحب باكت', style: TextStyle(color: Colors.deepOrange, fontSize: 12)),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.green, size: 22),
                                  tooltip: 'زيادة باكت (+1)',
                                  onPressed: () {
                                    context.read<ProductProvider>().incrementStock(product);
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.history, color: Colors.purple, size: 20),
                                  tooltip: 'تاريخ الأسعار',
                                  onPressed: widget.onHistory,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  tooltip: 'تعديل',
                                  onPressed: widget.onEdit,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  tooltip: 'حذف',
                                  onPressed: widget.onDelete,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 220),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? textColor}) {
    return Row(
      children: [
        Text(
          '$label ',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
