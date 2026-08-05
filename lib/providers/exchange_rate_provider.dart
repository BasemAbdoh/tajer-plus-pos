import 'package:flutter/material.dart';
import '../models/exchange_rate.dart';
import '../repositories/exchange_rate_repository.dart';

class ExchangeRateProvider extends ChangeNotifier {
  final ExchangeRateRepository _repository;
  List<ExchangeRate> _rates = [];
  bool _showPricesInLocalCurrency = false;

  List<ExchangeRate> get rates => _rates;
  bool get showPricesInLocalCurrency => _showPricesInLocalCurrency;

  ExchangeRateProvider(this._repository);

  Future<void> loadRates() async {
    try {
      _rates = await _repository.getAllRates();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading exchange rates: $e");
    }
  }

  void toggleShowLocalCurrency(bool value) {
    _showPricesInLocalCurrency = value;
    notifyListeners();
  }

  Future<void> updateRate(String currencyCode, double newRate) async {
    try {
      final rate = ExchangeRate(
        currencyCode: currencyCode,
        rateToLocal: newRate,
        updatedAt: DateTime.now(),
      );
      await _repository.upsertRate(rate);
      await loadRates();
    } catch (e) {
      debugPrint("Error updating rate: $e");
    }
  }

  double getRate(String currencyCode) {
    final match = _rates.where((r) => r.currencyCode == currencyCode);
    if (match.isNotEmpty) return match.first.rateToLocal;
    return currencyCode == 'saudi' ? 530.0 : 2000.0;
  }
}
