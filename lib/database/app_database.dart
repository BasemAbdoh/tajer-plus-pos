import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('products.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  static Future _createDB(Database db, int version) async {
    // 1. جدول المنتجات (products)
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productName TEXT NOT NULL,
        salePrice REAL NOT NULL,
        totalSalePrice REAL NOT NULL,
        profit REAL NOT NULL,
        purchasePrice REAL NOT NULL,
        packQuantity INTEGER NOT NULL,
        packPurchasePrice REAL NOT NULL,
        addedDate TEXT NOT NULL,
        category TEXT NOT NULL,
        currency INTEGER NOT NULL,
        stockPacks INTEGER NOT NULL DEFAULT 0,
        lowStockThreshold INTEGER NOT NULL DEFAULT 2,
        barcode TEXT,
        expiryDate TEXT,
        imagePath TEXT,
        notes TEXT
      )
    ''');

    // 2. جدول الأقسام (categories)
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    final now = DateTime.now().toIso8601String();
    final defaultCategories = ['مواد غذائية', 'أدوات تجميل', 'خردوات', 'بهارات'];
    for (var cat in defaultCategories) {
      await db.insert('categories', {
        'name': cat,
        'icon': null,
        'createdAt': now,
      });
    }

    // 3. جدول أسعار الصرف (exchange_rates)
    await db.execute('''
      CREATE TABLE exchange_rates(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        currencyCode TEXT NOT NULL UNIQUE,
        rateToLocal REAL NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.insert('exchange_rates', {
      'currencyCode': 'saudi',
      'rateToLocal': 530.0,
      'updatedAt': now,
    });
    await db.insert('exchange_rates', {
      'currencyCode': 'dollar',
      'rateToLocal': 2000.0,
      'updatedAt': now,
    });

    // 4. جدول سجل التغييرات في الأسعار (price_history)
    await db.execute('''
      CREATE TABLE price_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        oldSalePrice REAL,
        newSalePrice REAL,
        oldPackPurchasePrice REAL,
        newPackPurchasePrice REAL,
        changedAt TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (productId) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute("ALTER TABLE products ADD COLUMN stockPacks INTEGER NOT NULL DEFAULT 0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE products ADD COLUMN lowStockThreshold INTEGER NOT NULL DEFAULT 2");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE products ADD COLUMN barcode TEXT");
      } catch (_) {}

      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          icon TEXT,
          createdAt TEXT NOT NULL
        )
      ''');

      final now = DateTime.now().toIso8601String();
      final defaultCategories = ['مواد غذائية', 'أدوات تجميل', 'خردوات', 'بهارات'];
      for (var cat in defaultCategories) {
        try {
          await db.insert('categories', {
            'name': cat,
            'icon': null,
            'createdAt': now,
          });
        } catch (_) {}
      }

      await db.execute('''
        CREATE TABLE IF NOT EXISTS exchange_rates(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          currencyCode TEXT NOT NULL UNIQUE,
          rateToLocal REAL NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');

      try {
        await db.insert('exchange_rates', {
          'currencyCode': 'saudi',
          'rateToLocal': 530.0,
          'updatedAt': now,
        });
        await db.insert('exchange_rates', {
          'currencyCode': 'dollar',
          'rateToLocal': 2000.0,
          'updatedAt': now,
        });
      } catch (_) {}

      await db.execute('''
        CREATE TABLE IF NOT EXISTS price_history(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER NOT NULL,
          oldSalePrice REAL,
          newSalePrice REAL,
          oldPackPurchasePrice REAL,
          newPackPurchasePrice REAL,
          changedAt TEXT NOT NULL,
          note TEXT,
          FOREIGN KEY (productId) REFERENCES products(id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 3) {
      try {
        await db.execute("ALTER TABLE products ADD COLUMN expiryDate TEXT");
      } catch (_) {}
    }

    if (oldVersion < 4) {
      try {
        await db.execute("ALTER TABLE products ADD COLUMN imagePath TEXT");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE products ADD COLUMN notes TEXT");
      } catch (_) {}
    }
  }
}
