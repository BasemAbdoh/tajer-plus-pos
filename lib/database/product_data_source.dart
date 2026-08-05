import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import 'app_database.dart';

class ProductDataSource {
  Future<Database> get database async => await AppDatabase.database;

  Future<int> addProduct(Product product) async {
    final db = await database;
    return await db.insert(
      'products',
      _toMap(product),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> addProductFromMap(Map<String, dynamic> map) async {
    final db = await database;
    await db.insert('products', map);
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      _toMap(product),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllProducts() async {
    final db = await database;
    return await db.delete('products');
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _fromMap(maps.first);
    }
    return null;
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
    );
    return maps.map((map) => _fromMap(map)).toList();
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products');
    return maps.map((map) => _fromMap(map)).toList();
  }

  Future<List<Product>> getLowStockProducts() async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'stockPacks <= lowStockThreshold',
    );
    return maps.map((map) => _fromMap(map)).toList();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    if (maps.isNotEmpty) {
      return _fromMap(maps.first);
    }
    return null;
  }

  Map<String, dynamic> _toMap(Product product) {
    return {
      'id': product.id,
      'productName': product.productName,
      'salePrice': product.salePrice,
      'totalSalePrice': product.totalSalePrice,
      'profit': product.profit,
      'purchasePrice': product.purchasePrice,
      'packQuantity': product.packQuantity,
      'packPurchasePrice': product.packPurchasePrice,
      'addedDate': product.addedDate.toIso8601String(),
      'category': product.category,
      'currency': product.currency.index,
      'stockPacks': product.stockPacks,
      'lowStockThreshold': product.lowStockThreshold,
      'barcode': product.barcode,
      'expiryDate': product.expiryDate?.toIso8601String(),
      'imagePath': product.imagePath,
      'notes': product.notes,
    };
  }

  Product _fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      productName: map['productName'],
      salePrice: (map['salePrice'] as num).toDouble(),
      totalSalePrice: (map['totalSalePrice'] as num).toDouble(),
      profit: (map['profit'] as num).toDouble(),
      purchasePrice: (map['purchasePrice'] as num).toDouble(),
      packQuantity: map['packQuantity'] as int,
      packPurchasePrice: (map['packPurchasePrice'] as num).toDouble(),
      addedDate: DateTime.parse(map['addedDate']),
      category: map['category'] as String,
      currency: Currency.values[map['currency'] as int],
      stockPacks: map['stockPacks'] != null ? map['stockPacks'] as int : 0,
      lowStockThreshold: map['lowStockThreshold'] != null ? map['lowStockThreshold'] as int : 2,
      barcode: map['barcode'] as String?,
      expiryDate: map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      imagePath: map['imagePath'] as String?,
      notes: map['notes'] as String?,
    );
  }
}
