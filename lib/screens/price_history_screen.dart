import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/price_history.dart';
import '../repositories/price_history_repository.dart';
import '../database/price_history_data_source.dart';
import '../core/currency_manager.dart';

class PriceHistoryScreen extends StatefulWidget {
  final Product product;

  const PriceHistoryScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<PriceHistoryScreen> createState() => _PriceHistoryScreenState();
}

class _PriceHistoryScreenState extends State<PriceHistoryScreen> {
  late PriceHistoryRepository _repository;
  List<PriceHistory> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = PriceHistoryRepository(PriceHistoryDataSource());
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      if (widget.product.id != null) {
        _historyList = await _repository.getHistoryByProductId(widget.product.id!);
      }
    } catch (e) {
      debugPrint("Error loading price history: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = CurrencyManager.getCurrencySymbol(widget.product.currency);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تاريخ أسعار: ${widget.product.productName}', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 42, 150, 177),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _historyList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'لا يوجد سجل للتغييرات على هذا المنتج بعد.\nيتم إضافة سجل تلقائياً عندما تقوم بتعديل أسعار الشراء أو البيع.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: _historyList.length,
                    itemBuilder: (context, index) {
                      final item = _historyList[index];
                      final isSaleChanged = item.oldSalePrice != item.newSalePrice;
                      final isPurchaseChanged = item.oldPackPurchasePrice != item.newPackPurchasePrice;

                      double saleDiff = (item.newSalePrice ?? 0) - (item.oldSalePrice ?? 0);
                      double purchaseDiff = (item.newPackPurchasePrice ?? 0) - (item.oldPackPurchasePrice ?? 0);

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                      SizedBox(width: 6),
                                      Text(
                                        item.changedAt.toLocal().toString().split('.')[0],
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                  if (item.note != null && item.note!.isNotEmpty)
                                    Chip(
                                      label: Text(item.note!, style: TextStyle(fontSize: 10)),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                ],
                              ),
                              Divider(),
                              if (isSaleChanged) ...[
                                Row(
                                  children: [
                                    Text('سعر البيع للحبة: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${item.oldSalePrice?.toStringAsFixed(2)} $currencySymbol'),
                                    Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                                    Text(
                                      '${item.newSalePrice?.toStringAsFixed(2)} $currencySymbol',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '(${saleDiff > 0 ? "+${saleDiff.toStringAsFixed(2)}" : saleDiff.toStringAsFixed(2)})',
                                      style: TextStyle(
                                        color: saleDiff > 0 ? Colors.red : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                              ],
                              if (isPurchaseChanged) ...[
                                Row(
                                  children: [
                                    Text('سعر شراء الباكت: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${item.oldPackPurchasePrice?.toStringAsFixed(2)} $currencySymbol'),
                                    Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                                    Text(
                                      '${item.newPackPurchasePrice?.toStringAsFixed(2)} $currencySymbol',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '(${purchaseDiff > 0 ? "+${purchaseDiff.toStringAsFixed(2)}" : purchaseDiff.toStringAsFixed(2)})',
                                      style: TextStyle(
                                        color: purchaseDiff > 0 ? Colors.red : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
