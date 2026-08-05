import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/exchange_rate_provider.dart';
import '../core/currency_manager.dart';
import '../core/app_localizations.dart';
import 'barcode_scanner_screen.dart';

class PosCartItem {
  final Product product;
  int quantityUnits;

  PosCartItem({required this.product, required this.quantityUnits});

  double getTotalPrice(ExchangeRateProvider rateProvider) {
    double unitPrice = product.salePrice;
    if (rateProvider.showPricesInLocalCurrency && product.currency != Currency.local) {
      unitPrice = CurrencyManager.convertToLocal(product.salePrice, product.currency, rateProvider.rates);
    }
    return unitPrice * quantityUnits;
  }
}

class PosScreen extends StatefulWidget {
  const PosScreen({Key? key}) : super(key: key);

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<PosCartItem> _cart = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
    setState(() {
      if (existingIndex >= 0) {
        _cart[existingIndex].quantityUnits++;
      } else {
        _cart.add(PosCartItem(product: product, quantityUnits: 1));
      }
    });
  }

  Future<void> _scanBarcode() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (!mounted) return;
    if (code != null && code.isNotEmpty) {
      final productProvider = context.read<ProductProvider>();
      final product = await productProvider.findProductByBarcode(code);
      if (!mounted) return;
      if (product != null) {
        _addToCart(product);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found')),
        );
      }
    }
  }

  Future<void> _completeSale() async {
    if (_cart.isEmpty) return;
    final t = AppLocalizations.of(context);
    final productProvider = context.read<ProductProvider>();

    try {
      for (var item in _cart) {
        final p = item.product;
        int packsToDeduct = (item.quantityUnits / (p.packQuantity == 0 ? 1 : p.packQuantity)).ceil();
        int newStock = (p.stockPacks - packsToDeduct).clamp(0, 999999);
        final updated = p.copyWith(stockPacks: newStock);
        await productProvider.repository.updateProduct(updated);
      }

      await productProvider.loadAllProducts();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.saleSuccess),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _cart.clear();
        _searchController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing sale: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final productProvider = context.watch<ProductProvider>();
    final rateProvider = context.watch<ExchangeRateProvider>();

    double totalAmount = 0;
    for (var item in _cart) {
      totalAmount += item.getTotalPrice(rateProvider);
    }

    final query = productProvider.normalizeArabic(_searchController.text);
    final searchResults = _searchController.text.trim().isEmpty
        ? []
        : productProvider.allProducts.where((p) {
            final name = productProvider.normalizeArabic(p.productName);
            final barcodeMatch = p.barcode != null && p.barcode!.contains(_searchController.text.trim());
            return name.contains(query) || barcodeMatch;
          }).take(6).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.posMode, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: t.searchProduct,
                prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.indigo),
                  onPressed: _scanBarcode,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (searchResults.isNotEmpty)
            Container(
              color: Colors.indigo.shade50,
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final p = searchResults[index];
                  return ListTile(
                    dense: true,
                    title: Text(p.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${t.stockPacks}: ${p.stockPacks} | ${t.salePrice}: ${p.salePrice} ${CurrencyManager.getCurrencySymbol(p.currency)}'),
                    trailing: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                      icon: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                      label: Text(t.save, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      onPressed: () {
                        _addToCart(p);
                      },
                    ),
                  );
                },
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.point_of_sale, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(t.cartEmpty, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(t.cartEmptySub, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      final itemTotal = item.getTotalPrice(rateProvider);
                      final currencySymbol = rateProvider.showPricesInLocalCurrency && item.product.currency != Currency.local
                          ? "YER"
                          : CurrencyManager.getCurrencySymbol(item.product.currency);

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              if (item.product.imagePath != null && File(item.product.imagePath!).existsSync())
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(File(item.product.imagePath!), width: 40, height: 40, fit: BoxFit.cover),
                                )
                              else
                                CircleAvatar(
                                  backgroundColor: Colors.indigo.shade100,
                                  child: const Icon(Icons.shopping_bag, color: Colors.indigo),
                                ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text('${t.salePrice}: ${item.product.salePrice} $currencySymbol', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        if (item.quantityUnits > 1) {
                                          item.quantityUnits--;
                                        } else {
                                          _cart.removeAt(index);
                                        }
                                      });
                                    },
                                  ),
                                  Text('${item.quantityUnits}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        item.quantityUnits++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${itemTotal.toStringAsFixed(1)} $currencySymbol',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.totalAmount, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        '${totalAmount.toStringAsFixed(2)} YER',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    ],
                  ),
                ),
                if (_cart.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _cart.clear()),
                    child: Text(t.cancelCart, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _cart.isEmpty ? null : _completeSale,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: Text(t.completeSale, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
