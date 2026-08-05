import '../database/exchange_rate_data_source.dart';
import '../models/exchange_rate.dart';

class ExchangeRateRepository {
  final ExchangeRateDataSource _dataSource;

  ExchangeRateRepository(this._dataSource);

  Future<int> upsertRate(ExchangeRate rate) async {
    return await _dataSource.upsertRate(rate);
  }

  Future<List<ExchangeRate>> getAllRates() async {
    return await _dataSource.getAllRates();
  }

  Future<ExchangeRate?> getRateByCurrency(String currencyCode) async {
    return await _dataSource.getRateByCurrency(currencyCode);
  }
}
