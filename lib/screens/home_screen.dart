import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../providers/exchange_rate_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../core/app_localizations.dart';
import '../core/sort_options.dart';
import '../core/app_routes.dart';
import '../services/backup_service.dart';
import '../widgets/product_card.dart';
import '../widgets/sort_filter_sheet.dart';
import 'add_edit_product_screen.dart';
import 'manage_categories_screen.dart';
import 'exchange_rate_screen.dart';
import 'dashboard_screen.dart';
import 'price_history_screen.dart';
import 'barcode_scanner_screen.dart';
import 'pos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  late TextEditingController _searchController;
  late final AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final categoryProvider = context.read<CategoryProvider>();
      final productProvider = context.read<ProductProvider>();
      final rateProvider = context.read<ExchangeRateProvider>();

      await categoryProvider.loadCategories();
      await rateProvider.loadRates();
      await productProvider.loadAllProducts();

      if (!mounted) return;
      _reinitTabController(categoryProvider.categories.map((c) => c.name).toList());
    });
  }

  void _reinitTabController(List<String> categories) {
    if (categories.isEmpty) return;
    _tabController?.dispose();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) return;
      final category = categories[_tabController!.index];
      context.read<ProductProvider>().loadProductsByCategory(category);
      _restartListAnimation();
    });
    setState(() {});
  }

  void _restartListAnimation() {
    _listAnimationController.reset();
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<ProductProvider>().searchProducts(_searchController.text);
    _restartListAnimation();
  }

  Future<void> _scanBarcodeForSearch() async {
    final scannedCode = await Navigator.push<String>(
      context,
      fadeSlideRoute(const BarcodeScannerScreen()),
    );
    if (!mounted) return;

    if (scannedCode != null && scannedCode.isNotEmpty) {
      _searchController.text = scannedCode;
      _onSearchChanged();
    }
  }

  Future<void> _selectDateRange(ProductProvider productProvider) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: productProvider.isDateFilterActive
          ? DateTimeRange(
              start: productProvider.filterFromDate ?? DateTime.now(),
              end: productProvider.filterToDate ?? DateTime.now(),
            )
          : null,
    );

    if (picked != null) {
      productProvider.filterByDateRange(picked.start, picked.end);
      _restartListAnimation();
    }
  }

  void _openSortSheet(ProductProvider productProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SortFilterSheet(
        currentSort: productProvider.currentSort,
        onSortSelected: (selectedSort) {
          productProvider.sortProducts(selectedSort);
          _restartListAnimation();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final rateProvider = context.watch<ExchangeRateProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    final categories = categoryProvider.categories.map((c) => c.name).toList();

    if (_tabController == null || _tabController!.length != categories.length) {
      if (categories.isNotEmpty) {
        _reinitTabController(categories);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.homeScreenTitle, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.date_range,
                  color: productProvider.isDateFilterActive ? Colors.amberAccent : Colors.white,
                ),
                tooltip: t.dateRangeFilter,
                onPressed: () => _selectDateRange(productProvider),
              ),
              if (productProvider.isDateFilterActive)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            tooltip: t.sortAndFilter,
            onPressed: () => _openSortSheet(productProvider),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            tooltip: t.scanBarcode,
            onPressed: _scanBarcodeForSearch,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: Stack(
              key: ValueKey(productProvider.lowStockCount),
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    productProvider.showOnlyLowStock ? Icons.warning : Icons.warning_amber_outlined,
                    color: productProvider.showOnlyLowStock ? Colors.amberAccent : Colors.white,
                  ),
                  tooltip: t.lowStockItems,
                  onPressed: () {
                    productProvider.toggleLowStockFilter();
                    _restartListAnimation();
                  },
                ),
                if (productProvider.lowStockCount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${productProvider.lowStockCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        bottom: categories.isEmpty
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: categories.map((category) => Tab(text: category)).toList(),
                onTap: (index) {
                  productProvider.loadProductsByCategory(categories[index]);
                  _restartListAnimation();
                },
                labelStyle: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                indicatorColor: Colors.amber,
              ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 42, 150, 177),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store, size: 48, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    t.storeManagement,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeProvider.isDarkMode ? Colors.amber : Colors.blue,
              ),
              title: Text(t.darkMode),
              value: themeProvider.isDarkMode,
              onChanged: (val) {
                themeProvider.toggleTheme(val);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.deepPurple),
              title: Text(t.language),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  localeProvider.isArabic ? t.english : t.arabic,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade800),
                ),
              ),
              onTap: () {
                localeProvider.toggleLocale();
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.currency_exchange, color: Colors.green),
              title: Text(t.localCurrencyDisplay),
              subtitle: Text(rateProvider.showPricesInLocalCurrency ? 'Active' : 'Inactive'),
              value: rateProvider.showPricesInLocalCurrency,
              onChanged: (val) {
                rateProvider.toggleShowLocalCurrency(val);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.point_of_sale, color: Colors.indigo),
              title: Text(t.posMode),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, fadeSlideRoute(const PosScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.teal),
              title: Text(t.dashboard),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, fadeSlideRoute(const DashboardScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.orange),
              title: Text(t.categories),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, fadeSlideRoute(const ManageCategoriesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.currency_exchange, color: Colors.green),
              title: Text(t.exchangeRates),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, fadeSlideRoute(const ExchangeRateScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.backup, color: Colors.blue),
              title: Text(t.backupCreate),
              onTap: () async {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(t.backupCreate),
                    content: const Text("هل تريد إنشاء حفظ لنسخة احتياطية لبيانات المحل؟"),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          final service = BackupService(productProvider.repository);
                          final path = await service.createBackup();
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("تم حفظ النسخة في: $path")),
                          );
                        },
                        child: Text(t.yes),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(t.no),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.purple),
              title: Text(t.backupRestore),
              onTap: () async {
                Navigator.pop(context);
                final result = await FilePicker.platform.pickFiles();
                if (result != null && result.files.single.path != null) {
                  final file = File(result.files.single.path!);
                  final service = BackupService(productProvider.repository);
                  try {
                    await service.restoreBackup(file);
                    await categoryProvider.loadCategories();
                    await productProvider.loadAllProducts();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("تم استرجاع النسخة الاحتياطية بنجاح")),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("حدث خطأ أثناء الاسترجاع: $e")),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (productProvider.showOnlyLowStock)
            Container(
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade900),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'يتم الآن عرض الأصناف المنخفضة عن حد التنبيه فقط.',
                      style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      productProvider.toggleLowStockFilter();
                      _restartListAnimation();
                    },
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
            ),
          if (productProvider.isDateFilterActive)
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.date_range, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'فلترة التاريخ: ${productProvider.filterFromDate.toString().split(' ')[0]} ⬅ ${productProvider.filterToDate.toString().split(' ')[0]}',
                      style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () {
                      productProvider.clearDateFilter();
                      _restartListAnimation();
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: t.searchProduct,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scanBarcodeForSearch,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (_) => _onSearchChanged(),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.tune, color: Color.fromARGB(255, 42, 150, 177)),
                  tooltip: t.sortAndFilter,
                  onPressed: () => _openSortSheet(productProvider),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${t.sortBy}: ${productProvider.currentSort.label}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${t.totalItems}: ${productProvider.products.length}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: productProvider.products.isEmpty
                ? Center(
                    child: Text(
                      t.noProducts,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.products[index];
                      return FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _listAnimationController,
                            curve: Interval(
                              (index * 0.05).clamp(0.0, 0.9),
                              ((index * 0.05) + 0.3).clamp(0.1, 1.0),
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                        child: ProductCard(
                          product: product,
                          rateProvider: rateProvider,
                          onDecrementStock: () {
                            productProvider.decrementStock(product);
                          },
                          onEdit: () {
                            Navigator.push(
                              context,
                              fadeSlideRoute(AddEditProductScreen(product: product)),
                            );
                          },
                          onHistory: () {
                            Navigator.push(
                              context,
                              fadeSlideRoute(PriceHistoryScreen(product: product)),
                            );
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(t.deleteConfirm),
                                content: Text(product.productName),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await productProvider.deleteProduct(product.id!);
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      _restartListAnimation();
                                    },
                                    child: Text(t.yes),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(t.no),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: 1.0,
        child: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 42, 150, 177),
          onPressed: () {
            Navigator.push(
              context,
              fadeSlideRoute(const AddEditProductScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
