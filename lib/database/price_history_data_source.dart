import 'package:sqflite/sqflite.dart';
import '../models/price_history.dart';
import 'app_database.dart';

class PriceHistoryDataSource {
  Future<Database> get database async => await AppDatabase.database;

  Future<int> addPriceHistory(PriceHistory history) async {
    final db = await database;
    return await db.insert('price_history', history.toMap());
  }

  Future<List<PriceHistory>> getHistoryByProductId(int productId) async {
    final db = await database;
    final maps = await db.query(
      'price_history',
      where: 'productId = ?',
      whereArgs: [productId],
      orderBy: 'changedAt DESC',
    );
    return maps.map((map) => PriceHistory.fromMap(map)).toList();
  }

  Future<int> deleteHistoryByProductId(int productId) async {
    final db = await database;
    return await db.delete(
      'price_history',
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }
}
