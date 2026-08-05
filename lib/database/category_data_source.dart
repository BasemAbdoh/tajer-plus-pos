import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import 'app_database.dart';

class CategoryDataSource {
  Future<Database> get database async => await AppDatabase.database;

  Future<int> addCategory(Category category) async {
    final db = await database;
    return await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'id ASC');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<int> getProductsCountInCategory(String categoryName) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE category = ?',
      [categoryName],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
