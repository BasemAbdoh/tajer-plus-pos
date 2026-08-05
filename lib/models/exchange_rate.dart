class ExchangeRate {
  final int? id;
  final String currencyCode; // 'saudi' | 'dollar'
  final double rateToLocal; // سعر الصرف مقابل العملة المحلية
  final DateTime updatedAt;

  ExchangeRate({
    this.id,
    required this.currencyCode,
    required this.rateToLocal,
    required this.updatedAt,
  });

  ExchangeRate copyWith({
    int? id,
    String? currencyCode,
    double? rateToLocal,
    DateTime? updatedAt,
  }) {
    return ExchangeRate(
      id: id ?? this.id,
      currencyCode: currencyCode ?? this.currencyCode,
      rateToLocal: rateToLocal ?? this.rateToLocal,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currencyCode': currencyCode,
      'rateToLocal': rateToLocal,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ExchangeRate.fromMap(Map<String, dynamic> map) {
    return ExchangeRate(
      id: map['id'] as int?,
      currencyCode: map['currencyCode'] as String,
      rateToLocal: (map['rateToLocal'] as num).toDouble(),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
