import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/price_history.dart';
import '../repositories/product_repository.dart';
import '../repositories/price_history_repository.dart';
import '../core/sort_options.dart';
import '../services/notification_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;
  final PriceHistoryRepository? _priceHistoryRepository;

  List<Product> _products = [];
  List<Product> _allProducts = [];
  List<Product> _lowStockProducts = [];
  String? _selectedCategory;
  bool _showOnlyLowStock = false;
  SortOption _currentSort = SortOption.newest;

  DateTime? _filterFromDate;
  DateTime? _filterToDate;

  List<Product> get products => _products;
  List<Product> get allProducts => _allProducts;
  List<Product> get lowStockProducts => _lowStockProducts;
  int get lowStockCount => _lowStockProducts.length;
  bool get showOnlyLowStock => _showOnlyLowStock;
  SortOption get currentSort => _currentSort;
  DateTime? get filterFromDate => _filterFromDate;
  DateTime? get filterToDate => _filterToDate;
  bool get isDateFilterActive => _filterFromDate != null || _filterToDate != null;
  ProductRepository get repository => _repository;

  ProductProvider(this._repository, [this._priceHistoryRepository]);

  String normalizeArabic(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp('[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  Future<void> loadAllProducts() async {
    _allProducts = await _repository.getAllProducts();
    await _updateLowStockList();

    if (_showOnlyLowStock) {
      _products = List.from(_lowStockProducts);
    } else if (_selectedCategory != null) {
      _products = await _repository.getProductsByCategory(_selectedCategory!);
    } else {
      _products = List.from(_allProducts);
    }

    _applyDateFilter();
    _applySort();
    notifyListeners();

    NotificationService.checkAndShowExpiryNotification(_allProducts);
  }

  Future<void> _updateLowStockList() async {
    _lowStockProducts = await _repository.getLowStockProducts();
  }

  void sortProducts(SortOption option) {
    _currentSort = option;
    _applySort();
    notifyListeners();
  }

  void filterByDateRange(DateTime? from, DateTime? to) {
    _filterFromDate = from;
    _filterToDate = to;
    _reloadCurrent();
  }

  void clearDateFilter() {
    _filterFromDate = null;
    _filterToDate = null;
    _reloadCurrent();
  }

  void _applyDateFilter() {
    if (_filterFromDate == null && _filterToDate == null) return;
    _products = _products.where((p) {
      final added = DateTime(p.addedDate.year, p.addedDate.month, p.addedDate.day);
      if (_filterFromDate != null) {
        final from = DateTime(_filterFromDate!.year, _filterFromDate!.month, _filterFromDate!.day);
        if (added.isBefore(from)) return false;
      }
      if (_filterToDate != null) {
        final to = DateTime(_filterToDate!.year, _filterToDate!.month, _filterToDate!.day);
        if (added.isAfter(to)) return false;
      }
      return true;
    }).toList();
  }

  void _applySort() {
    switch (_currentSort) {
      case SortOption.newest:
        _products.sort((a, b) => b.addedDate.compareTo(a.addedDate));
        break;
      case SortOption.oldest:
        _products.sort((a, b) => a.addedDate.compareTo(b.addedDate));
        break;
      case SortOption.priceHigh:
        _products.sort((a, b) => b.salePrice.compareTo(a.salePrice));
        break;
      case SortOption.priceLow:
        _products.sort((a, b) => a.salePrice.compareTo(b.salePrice));
        break;
      case SortOption.profitHigh:
        _products.sort((a, b) => b.profit.compareTo(a.profit));
        break;
      case SortOption.profitLow:
        _products.sort((a, b) => a.profit.compareTo(b.profit));
        break;
      case SortOption.nameAZ:
        _products.sort((a, b) => normalizeArabic(a.productName).compareTo(normalizeArabic(b.productName)));
        break;
      case SortOption.stockLow:
        _products.sort((a, b) => a.stockPacks.compareTo(b.stockPacks));
        break;
      case SortOption.expirySoon:
        _products.sort((a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return a.expiryDate!.compareTo(b.expiryDate!);
        });
        break;
    }
  }

  List<Product> getExpiringSoonProducts({int daysThreshold = 30}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _allProducts.where((p) {
      if (p.expiryDate == null) return false;
      final exp = DateTime(p.expiryDate!.year, p.expiryDate!.month, p.expiryDate!.day);
      final diff = exp.difference(today).inDays;
      return diff <= daysThreshold;
    }).toList();
  }

  Future<void> addProduct(Product product) async {
    await _repository.addProduct(product);
    await loadAllProducts();
  }

  Future<void> updateProduct(Product updatedProduct) async {
    if (_priceHistoryRepository != null && updatedProduct.id != null) {
      final oldProduct = await _repository.getProductById(updatedProduct.id!);
      if (oldProduct != null) {
        final salePriceChanged = oldProduct.salePrice != updatedProduct.salePrice;
        final packPurchaseChanged = oldProduct.packPurchasePrice != updatedProduct.packPurchasePrice;

        if (salePriceChanged || packPurchaseChanged) {
          final history = PriceHistory(
            productId: updatedProduct.id!,
            oldSalePrice: oldProduct.salePrice,
            newSalePrice: updatedProduct.salePrice,
            oldPackPurchasePrice: oldProduct.packPurchasePrice,
            newPackPurchasePrice: updatedProduct.packPurchasePrice,
            changedAt: DateTime.now(),
            note: "تعديل الأسعار",
          );
          await _priceHistoryRepository.addPriceHistory(history);
        }
      }
    }

    await _repository.updateProduct(updatedProduct);
    await loadAllProducts();
  }

  Future<void> deleteProduct(int id) async {
    if (_priceHistoryRepository != null) {
      await _priceHistoryRepository.deleteHistoryByProductId(id);
    }
    await _repository.deleteProduct(id);
    await loadAllProducts();
  }

  Future<void> incrementStock(Product product) async {
    final updated = product.copyWith(stockPacks: product.stockPacks + 1);
    await _repository.updateProduct(updated);
    await loadAllProducts();
  }

  Future<void> decrementStock(Product product) async {
    if (product.stockPacks > 0) {
      final updated = product.copyWith(stockPacks: product.stockPacks - 1);
      await _repository.updateProduct(updated);
      await loadAllProducts();
    }
  }

  Future<void> toggleLowStockFilter() async {
    _showOnlyLowStock = !_showOnlyLowStock;
    if (_showOnlyLowStock) {
      _products = List.from(_lowStockProducts);
    } else {
      await _reloadCurrent();
    }
    _applyDateFilter();
    _applySort();
    notifyListeners();
  }

  Future<Product?> findProductByBarcode(String barcode) async {
    return await _repository.getProductByBarcode(barcode);
  }

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      await _reloadCurrent();
    } else {
      final normalizedQuery = normalizeArabic(query);
      _products = _allProducts.where((p) {
        final name = normalizeArabic(p.productName);
        final barcodeMatch = p.barcode != null && p.barcode!.contains(query.trim());
        return name.contains(normalizedQuery) || barcodeMatch;
      }).toList();
      _applyDateFilter();
      _applySort();
      notifyListeners();
    }
  }

  Future<void> loadProductsByCategory(String category) async {
    _selectedCategory = category;
    _showOnlyLowStock = false;
    _products = await _repository.getProductsByCategory(category);
    await _updateLowStockList();
    _applyDateFilter();
    _applySort();
    notifyListeners();
  }

  Future<void> _reloadCurrent() async {
    await _updateLowStockList();
    if (_selectedCategory == null) {
      _products = await _repository.getAllProducts();
    } else {
      _products = await _repository.getProductsByCategory(_selectedCategory!);
    }
    _applyDateFilter();
    _applySort();
    notifyListeners();
  }
}
