import '../models/product.dart';
import '../models/exchange_rate.dart';

class CurrencyManager {
  static Currency _defaultCurrency = Currency.local;

  static Currency get defaultCurrency => _defaultCurrency;

  static void setDefaultCurrency(Currency currency) {
    _defaultCurrency = currency;
  }

  static String getCurrencySymbol(Currency currency) {
    switch (currency) {
      case Currency.local:
        return "ر.ي";
      case Currency.saudi:
        return "ر.س";
      case Currency.dollar:
        return "\$";
    }
  }

  static double convertToLocal(double amount, Currency currency, List<ExchangeRate> rates) {
    if (currency == Currency.local) return amount;
    final code = currency == Currency.saudi ? 'saudi' : 'dollar';
    final match = rates.where((r) => r.currencyCode == code);
    if (match.isNotEmpty) {
      return amount * match.first.rateToLocal;
    }
    // أسعار صرف افتراضية إذا لم تتوفر في الداتا بيز بعد
    final defaultRate = currency == Currency.saudi ? 530.0 : 2000.0;
    return amount * defaultRate;
  }
}
