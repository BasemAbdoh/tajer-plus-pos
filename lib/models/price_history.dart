class PriceHistory {
  final int? id;
  final int productId;
  final double? oldSalePrice;
  final double? newSalePrice;
  final double? oldPackPurchasePrice;
  final double? newPackPurchasePrice;
  final DateTime changedAt;
  final String? note;

  PriceHistory({
    this.id,
    required this.productId,
    this.oldSalePrice,
    this.newSalePrice,
    this.oldPackPurchasePrice,
    this.newPackPurchasePrice,
    required this.changedAt,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'oldSalePrice': oldSalePrice,
      'newSalePrice': newSalePrice,
      'oldPackPurchasePrice': oldPackPurchasePrice,
      'newPackPurchasePrice': newPackPurchasePrice,
      'changedAt': changedAt.toIso8601String(),
      'note': note,
    };
  }

  factory PriceHistory.fromMap(Map<String, dynamic> map) {
    return PriceHistory(
      id: map['id'] as int?,
      productId: map['productId'] as int,
      oldSalePrice: map['oldSalePrice'] != null ? (map['oldSalePrice'] as num).toDouble() : null,
      newSalePrice: map['newSalePrice'] != null ? (map['newSalePrice'] as num).toDouble() : null,
      oldPackPurchasePrice: map['oldPackPurchasePrice'] != null ? (map['oldPackPurchasePrice'] as num).toDouble() : null,
      newPackPurchasePrice: map['newPackPurchasePrice'] != null ? (map['newPackPurchasePrice'] as num).toDouble() : null,
      changedAt: DateTime.parse(map['changedAt'] as String),
      note: map['note'] as String?,
    );
  }
}
