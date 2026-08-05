enum Currency {
  local,
  saudi,
  dollar,
}

class Product {
  int? id;
  final String productName;
  final double salePrice;
  final double totalSalePrice;
  final double profit;
  final double purchasePrice;
  final int packQuantity;
  final double packPurchasePrice;
  final DateTime addedDate;
  final String category;
  final Currency currency;
  final int stockPacks;
  final int lowStockThreshold;
  final String? barcode;
  final DateTime? expiryDate;
  final String? imagePath;
  final String? notes;

  Product({
    required this.id,
    required this.productName,
    required this.salePrice,
    required this.totalSalePrice,
    required this.profit,
    required this.purchasePrice,
    required this.packQuantity,
    required this.packPurchasePrice,
    required this.addedDate,
    required this.category,
    required this.currency,
    this.stockPacks = 0,
    this.lowStockThreshold = 2,
    this.barcode,
    this.expiryDate,
    this.imagePath,
    this.notes,
  });

  Product copyWith({
    int? id,
    String? productName,
    double? salePrice,
    double? totalSalePrice,
    double? profit,
    double? purchasePrice,
    int? packQuantity,
    double? packPurchasePrice,
    DateTime? addedDate,
    String? category,
    Currency? currency,
    int? stockPacks,
    int? lowStockThreshold,
    String? barcode,
    DateTime? expiryDate,
    String? imagePath,
    String? notes,
  }) {
    return Product(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      salePrice: salePrice ?? this.salePrice,
      totalSalePrice: totalSalePrice ?? this.totalSalePrice,
      profit: profit ?? this.profit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      packQuantity: packQuantity ?? this.packQuantity,
      packPurchasePrice: packPurchasePrice ?? this.packPurchasePrice,
      addedDate: addedDate ?? this.addedDate,
      category: category ?? this.category,
      currency: currency ?? this.currency,
      stockPacks: stockPacks ?? this.stockPacks,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      barcode: barcode ?? this.barcode,
      expiryDate: expiryDate ?? this.expiryDate,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'salePrice': salePrice,
      'totalSalePrice': totalSalePrice,
      'profit': profit,
      'purchasePrice': purchasePrice,
      'packQuantity': packQuantity,
      'packPurchasePrice': packPurchasePrice,
      'addedDate': addedDate.toIso8601String(),
      'currency': currency.index,
      'stockPacks': stockPacks,
      'lowStockThreshold': lowStockThreshold,
      'barcode': barcode,
      'expiryDate': expiryDate?.toIso8601String(),
      'imagePath': imagePath,
      'notes': notes,
    };
  }
}
