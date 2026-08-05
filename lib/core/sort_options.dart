enum SortOption {
  newest, // الأحدث إضافةً
  oldest, // الأقدم إضافةً
  priceHigh, // الأعلى سعراً
  priceLow, // الأقل سعراً
  profitHigh, // الأكثر ربحاً
  profitLow, // الأقل ربحاً
  nameAZ, // ترتيب أبجدي
  stockLow, // الأقل مخزوناً
  expirySoon, // الأقرب انتهاءً
}

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.newest:
        return 'الأحدث إضافةً';
      case SortOption.oldest:
        return 'الأقدم إضافةً';
      case SortOption.priceHigh:
        return 'الأعلى سعراً (بيع)';
      case SortOption.priceLow:
        return 'الأقل سعراً (بيع)';
      case SortOption.profitHigh:
        return 'الأكثر ربحاً';
      case SortOption.profitLow:
        return 'الأقل ربحاً';
      case SortOption.nameAZ:
        return 'أبجدي (أ - ي)';
      case SortOption.stockLow:
        return 'الأقل مخزوناً (تنبيه)';
      case SortOption.expirySoon:
        return 'الأقرب انتهاءً (صلاحية)';
    }
  }
}
