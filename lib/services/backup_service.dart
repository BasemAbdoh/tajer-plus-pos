import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import '../repositories/product_repository.dart';
import '../core/currency_manager.dart';

class BackupService {
  final ProductRepository repository;

  BackupService(this.repository);

  Future<String> createBackup() async {
    final products = await repository.getAllProducts();
    final data = products.map((e) => e.toMap()).toList();
    final jsonData = jsonEncode(data);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/products_backup.json');

    await file.writeAsString(jsonData);
    return file.path;
  }

  Future<void> restoreBackup(File file) async {
    if (!await file.exists()) {
      throw Exception("لا توجد نسخة احتياطية للاسترجاع");
    }

    final content = await file.readAsString();
    final dynamic decoded = jsonDecode(content);

    List<dynamic> jsonData;
    if (decoded is List) {
      jsonData = decoded;
    } else if (decoded is Map && decoded.containsKey('products')) {
      jsonData = decoded['products'];
    } else {
      throw Exception("صيغة الملف غير صحيحة");
    }

    await repository.deleteAllProducts();

    for (var item in jsonData) {
      await repository.addProductFromMap(Map<String, dynamic>.from(item));
    }
  }

  Future<String> exportToCsv() async {
    final products = await repository.getAllProducts();

    List<List<dynamic>> rows = [
      [
        "المعرف",
        "اسم المنتج",
        "القسم",
        "العملة",
        "سعر بيع الحبة",
        "العدد في الباكت",
        "سعر شراء الباكت",
        "سعر شراء الحبة",
        "إجمالي البيع",
        "الفائدة المتوقعة",
        "الكمية المتوفرة (بواكت)",
        "حد التنبيه",
        "الباركود",
        "تاريخ الإضافة",
        "تاريخ انتهاء الصلاحية"
      ]
    ];

    for (var p in products) {
      rows.add([
        p.id ?? 0,
        p.productName,
        p.category,
        CurrencyManager.getCurrencySymbol(p.currency),
        p.salePrice,
        p.packQuantity,
        p.packPurchasePrice,
        p.purchasePrice,
        p.totalSalePrice,
        p.profit,
        p.stockPacks,
        p.lowStockThreshold,
        p.barcode ?? '',
        p.addedDate.toIso8601String().split('T')[0],
        p.expiryDate?.toIso8601String().split('T')[0] ?? '',
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/products_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvData);

    return file.path;
  }

  Future<void> shareCsvReport() async {
    final filePath = await exportToCsv();
    await Share.shareXFiles([XFile(filePath)], text: 'تقرير الأصناف التجارية (CSV)');
  }
}