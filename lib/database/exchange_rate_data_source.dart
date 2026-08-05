import 'package:sqflite/sqflite.dart';
import '../models/exchange_rate.dart';
import 'app_database.dart';

class ExchangeRateDataSource {
  Future<Database> get database async => await AppDatabase.database;

  Future<int> upsertRate(ExchangeRate rate) async {
    final db = await database;
    return await db.insert(
      'exchange_rates',
      rate.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExchangeRate>> getAllRates() async {
    final db = await database;
    final maps = await db.query('exchange_rates');
    return maps.map((map) => ExchangeRate.fromMap(map)).toList();
  }

  Future<ExchangeRate?> getRateByCurrency(String currencyCode) async {
    final db = await database;
    final maps = await db.query(
      'exchange_rates',
      where: 'currencyCode = ?',
      whereArgs: [currencyCode],
    );
    if (maps.isNotEmpty) {
      return ExchangeRate.fromMap(maps.first);
    }
    return null;
  }
}
