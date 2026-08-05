import '../database/price_history_data_source.dart';
import '../models/price_history.dart';

class PriceHistoryRepository {
  final PriceHistoryDataSource _dataSource;

  PriceHistoryRepository(this._dataSource);

  Future<int> addPriceHistory(PriceHistory history) async {
    return await _dataSource.addPriceHistory(history);
  }

  Future<List<PriceHistory>> getHistoryByProductId(int productId) async {
    return await _dataSource.getHistoryByProductId(productId);
  }

  Future<int> deleteHistoryByProductId(int productId) async {
    return await _dataSource.deleteHistoryByProductId(productId);
  }
}
