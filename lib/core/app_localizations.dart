import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('ar'));
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'appTitle': 'إدارة الأصناف التجارية',
      'homeScreenTitle': 'إدارة الأصناف التجارية',
      'addProduct': 'إضافة صنف جديد',
      'editProduct': 'تعديل بيانات الصنف',
      'productName': 'اسم المنتج',
      'salePrice': 'سعر بيع الحبة',
      'purchasePrice': 'سعر شراء الحبة',
      'packQuantity': 'عدد الحبات داخل الباكت',
      'packPurchasePrice': 'سعر شراء الباكت كاملاً',
      'totalSalePrice': 'إجمالي سعر بيع الباكت',
      'expectedProfit': 'الفائدة المتوقعة',
      'stockPacks': 'الكمية المتوفرة بالمخزون (عدد الباكتات)',
      'lowStockThreshold': 'حد التنبيه لنقص المخزون (بالباكت)',
      'barcode': 'رمز الباركود (اختياري)',
      'notes': 'ملاحظات إضافية للمنتج (اختياري)',
      'currency': 'العملة الخاصة بالمنتج',
      'category': 'القسم',
      'addedDate': 'تاريخ الإضافة',
      'expiryDate': 'تاريخ انتهاء الصلاحية',
      'save': 'حفظ البيانات',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'dashboard': 'لوحة التحكم والتقارير',
      'categories': 'إدارة الأقسام والتصنيفات',
      'exchangeRates': 'أسعار الصرف والعملات',
      'posMode': 'وضع كشك البيع المفرد (POS)',
      'darkMode': 'الوضع الداكن (Dark Mode)',
      'localCurrencyDisplay': 'عرض الأسعار بالريال اليمني',
      'backupCreate': 'إنشاء نسخة احتياطية (JSON)',
      'backupRestore': 'استرجاع نسخة احتياطية',
      'lowStockItems': 'الأصناف المنخفضة',
      'priceHistory': 'تاريخ الأسعار',
      'language': 'اللغة (Language)',
      'arabic': 'العربية',
      'english': 'English',
      'completeSale': 'إتمام البيع',
      'totalAmount': 'الإجمالي المستحق',
      'searchProduct': 'بحث باسم المنتج أو الباركود',
      'noProducts': 'لا توجد أصناف مسجلة',
      'deleteConfirm': 'هل أنت تأكد من الحذف؟',
      'yes': 'نعم',
      'no': 'لا',
      'addCategory': 'إضافة قسم جديد',
      'categoryName': 'اسم القسم',
      'packLabel': 'باكت',
      'unitLabel': 'حبة',
      'sortBy': 'الترتيب الحالي',
      'totalItems': 'العدد',
      'storeManagement': 'إدارة المحل والمخزون',
      'dateRangeFilter': 'فلترة حسب تاريخ الإضافة',
      'sortAndFilter': 'فرز وتصفية',
      'scanBarcode': 'مسح الباركود',
      'financialSummary': '📊 المُلخص المالي والمخزني',
      'expiringSoon': '⏳ أصناف تنتهي صلاحيتها قريباً (أو منتهية)',
      'chartsSection': '📈 الرسوم البيانية والتوزيع الإحصائي',
      'topProfitable': '🏆 أعلى 5 أصناف ربحية (للحبة/الباكت)',
      'categoryDistribution': '📁 توزيع أصناف المنتجات حسب الأقسام',
      'exportCsv': 'تصدير تقرير CSV إلى الجهاز',
      'quickStockAdd': 'زيادة باكت (+1)',
      'pullPack': 'سحب باكت',
      'cancelCart': 'إلغاء السلة',
      'cartEmpty': 'السلة فارغة حالياً',
      'cartEmptySub': 'ابحث باسم المنتج أو الباركود لإضافة أصناف للبيع',
      'saleSuccess': 'تم إتمام عملية البيع وخصم المخزون بنجاح ✅',
    },
    'en': {
      'appTitle': 'Business Items Manager',
      'homeScreenTitle': 'Items Manager',
      'addProduct': 'Add New Item',
      'editProduct': 'Edit Item Details',
      'productName': 'Product Name',
      'salePrice': 'Unit Sale Price',
      'purchasePrice': 'Unit Purchase Price',
      'packQuantity': 'Units per Pack',
      'packPurchasePrice': 'Pack Purchase Price',
      'totalSalePrice': 'Total Sale Price per Pack',
      'expectedProfit': 'Expected Profit',
      'stockPacks': 'Available Stock (Packs)',
      'lowStockThreshold': 'Low Stock Alert Threshold',
      'barcode': 'Barcode (Optional)',
      'notes': 'Additional Notes (Optional)',
      'currency': 'Product Currency',
      'category': 'Category',
      'addedDate': 'Added Date',
      'expiryDate': 'Expiration Date',
      'save': 'Save Data',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'dashboard': 'Dashboard & Reports',
      'categories': 'Manage Categories',
      'exchangeRates': 'Exchange Rates & Currencies',
      'posMode': 'POS Retail Kiosk Mode',
      'darkMode': 'Dark Mode',
      'localCurrencyDisplay': 'Show Prices in Local Currency',
      'backupCreate': 'Create Backup (JSON)',
      'backupRestore': 'Restore Backup',
      'lowStockItems': 'Low Stock Items',
      'priceHistory': 'Price History',
      'language': 'Language',
      'arabic': 'العربية',
      'english': 'English',
      'completeSale': 'Complete Sale',
      'totalAmount': 'Total Due',
      'searchProduct': 'Search by product name or barcode',
      'noProducts': 'No products registered',
      'deleteConfirm': 'Are you sure you want to delete?',
      'yes': 'Yes',
      'no': 'No',
      'addCategory': 'Add New Category',
      'categoryName': 'Category Name',
      'packLabel': 'packs',
      'unitLabel': 'units',
      'sortBy': 'Current Sort',
      'totalItems': 'Total Items',
      'storeManagement': 'Store & Stock Management',
      'dateRangeFilter': 'Filter by added date',
      'sortAndFilter': 'Sort & Filter',
      'scanBarcode': 'Scan Barcode',
      'financialSummary': '📊 Financial & Stock Summary',
      'expiringSoon': '⏳ Items Expiring Soon (or Expired)',
      'chartsSection': '📈 Charts & Statistical Distribution',
      'topProfitable': '🏆 Top 5 Profitable Items',
      'categoryDistribution': '📁 Product Distribution by Category',
      'exportCsv': 'Export CSV Report',
      'quickStockAdd': 'Add pack (+1)',
      'pullPack': 'Pull Pack',
      'cancelCart': 'Clear Cart',
      'cartEmpty': 'Cart is currently empty',
      'cartEmptySub': 'Search product name or scan barcode to add items',
      'saleSuccess': 'Sale completed and stock updated successfully ✅',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['ar']![key] ?? key;
  }

  String get appTitle => get('appTitle');
  String get homeScreenTitle => get('homeScreenTitle');
  String get addProduct => get('addProduct');
  String get editProduct => get('editProduct');
  String get productName => get('productName');
  String get salePrice => get('salePrice');
  String get purchasePrice => get('purchasePrice');
  String get packQuantity => get('packQuantity');
  String get packPurchasePrice => get('packPurchasePrice');
  String get totalSalePrice => get('totalSalePrice');
  String get expectedProfit => get('expectedProfit');
  String get stockPacks => get('stockPacks');
  String get lowStockThreshold => get('lowStockThreshold');
  String get barcode => get('barcode');
  String get notes => get('notes');
  String get currency => get('currency');
  String get category => get('category');
  String get addedDate => get('addedDate');
  String get expiryDate => get('expiryDate');
  String get save => get('save');
  String get cancel => get('cancel');
  String get delete => get('delete');
  String get edit => get('edit');
  String get dashboard => get('dashboard');
  String get categories => get('categories');
  String get exchangeRates => get('exchangeRates');
  String get posMode => get('posMode');
  String get darkMode => get('darkMode');
  String get localCurrencyDisplay => get('localCurrencyDisplay');
  String get backupCreate => get('backupCreate');
  String get backupRestore => get('backupRestore');
  String get lowStockItems => get('lowStockItems');
  String get priceHistory => get('priceHistory');
  String get language => get('language');
  String get arabic => get('arabic');
  String get english => get('english');
  String get completeSale => get('completeSale');
  String get totalAmount => get('totalAmount');
  String get searchProduct => get('searchProduct');
  String get noProducts => get('noProducts');
  String get deleteConfirm => get('deleteConfirm');
  String get yes => get('yes');
  String get no => get('no');
  String get addCategory => get('addCategory');
  String get categoryName => get('categoryName');
  String get packLabel => get('packLabel');
  String get unitLabel => get('unitLabel');
  String get sortBy => get('sortBy');
  String get totalItems => get('totalItems');
  String get storeManagement => get('storeManagement');
  String get dateRangeFilter => get('dateRangeFilter');
  String get sortAndFilter => get('sortAndFilter');
  String get scanBarcode => get('scanBarcode');
  String get financialSummary => get('financialSummary');
  String get expiringSoon => get('expiringSoon');
  String get chartsSection => get('chartsSection');
  String get topProfitable => get('topProfitable');
  String get categoryDistribution => get('categoryDistribution');
  String get exportCsv => get('exportCsv');
  String get quickStockAdd => get('quickStockAdd');
  String get pullPack => get('pullPack');
  String get cancelCart => get('cancelCart');
  String get cartEmpty => get('cartEmpty');
  String get cartEmptySub => get('cartEmptySub');
  String get saleSuccess => get('saleSuccess');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
