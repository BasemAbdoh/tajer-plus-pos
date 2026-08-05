import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../core/currency_manager.dart';
import '../core/app_localizations.dart';
import '../services/product_service.dart';
import 'barcode_scanner_screen.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _salePriceController;
  late TextEditingController _totalSalePriceController;
  late TextEditingController _profitController;
  late TextEditingController _packQuantityController;
  late TextEditingController _packPurchasePriceController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _stockPacksController;
  late TextEditingController _lowStockThresholdController;
  late TextEditingController _barcodeController;
  late TextEditingController _notesController;

  late DateTime _addedDate;
  DateTime? _expiryDate;
  String? _imagePath;
  late String _category;
  late Currency _currency;

  final List<Currency> _currencies = [Currency.local, Currency.saudi, Currency.dollar];

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    context.read<ProductProvider>().loadAllProducts();
    context.read<CategoryProvider>().loadCategories();

    _nameController = TextEditingController(text: product?.productName ?? '');
    _salePriceController = TextEditingController(text: product?.salePrice.toString() ?? '');
    _totalSalePriceController = TextEditingController(text: product?.totalSalePrice.toString() ?? '');
    _profitController = TextEditingController(text: product?.profit.toString() ?? '');
    _packQuantityController = TextEditingController(text: product?.packQuantity.toString() ?? '');
    _packPurchasePriceController = TextEditingController(text: product?.packPurchasePrice.toString() ?? '');
    _purchasePriceController = TextEditingController(text: product?.purchasePrice.toString() ?? '');
    _stockPacksController = TextEditingController(text: product?.stockPacks.toString() ?? '0');
    _lowStockThresholdController = TextEditingController(text: product?.lowStockThreshold.toString() ?? '2');
    _barcodeController = TextEditingController(text: product?.barcode ?? '');
    _notesController = TextEditingController(text: product?.notes ?? '');
    _addedDate = product?.addedDate ?? DateTime.now();
    _expiryDate = product?.expiryDate;
    _imagePath = product?.imagePath;
    _category = product?.category ?? '';
    _currency = product?.currency ?? CurrencyManager.defaultCurrency;

    _packQuantityController.addListener(_updatePurchasePrice);
    _packPurchasePriceController.addListener(_updatePurchasePrice);

    _salePriceController.addListener(_updateTotalSalePrice);
    _packQuantityController.addListener(_updateTotalSalePrice);

    _totalSalePriceController.addListener(_updateProfitPrice);
    _packPurchasePriceController.addListener(_updateProfitPrice);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _salePriceController.dispose();
    _totalSalePriceController.dispose();
    _profitController.dispose();
    _packQuantityController.dispose();
    _packPurchasePriceController.dispose();
    _purchasePriceController.dispose();
    _stockPacksController.dispose();
    _lowStockThresholdController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updatePurchasePrice() {
    final packQuantity = int.tryParse(_packQuantityController.text) ?? 0;
    final packPurchasePrice = double.tryParse(_packPurchasePriceController.text) ?? 0.0;
    if (packQuantity > 0) {
      final purchasePrice = ProductService.calculatePurchasePrice(packPurchasePrice, packQuantity);
      _purchasePriceController.text = purchasePrice.toStringAsFixed(2);
    } else {
      _purchasePriceController.clear();
    }
  }

  void _updateTotalSalePrice() {
    final salePrice = double.tryParse(_salePriceController.text) ?? 0.0;
    final packQuantity = int.tryParse(_packQuantityController.text) ?? 0;
    final totalSalePrice = ProductService.calculateTotalSalPricr(salePrice, packQuantity);
    _totalSalePriceController.text = totalSalePrice.toStringAsFixed(2);
  }

  void _updateProfitPrice() {
    final totalSalePrice = double.tryParse(_totalSalePriceController.text) ?? 0.0;
    final packPurchasePrice = double.tryParse(_packPurchasePriceController.text) ?? 0.0;
    final profitPrice = ProductService.calculateProfitPrice(packPurchasePrice, totalSalePrice);
    _profitController.text = profitPrice.toStringAsFixed(2);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _scanBarcode() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (!mounted) return;
    if (scannedCode != null && scannedCode.isNotEmpty) {
      _barcodeController.text = scannedCode;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _addedDate) {
      setState(() {
        _addedDate = picked;
      });
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final categoryProvider = context.read<CategoryProvider>();
    final availableCategories = categoryProvider.categories.map((c) => c.name).toList();

    String selectedCategory = _category;
    if (selectedCategory.isEmpty || !availableCategories.contains(selectedCategory)) {
      if (availableCategories.isNotEmpty) {
        selectedCategory = availableCategories[0];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a category first')),
        );
        return;
      }
    }

    final productName = _nameController.text.trim();
    final salePrice = double.tryParse(_salePriceController.text) ?? -1;
    final packQuantity = int.tryParse(_packQuantityController.text) ?? -1;
    final packPurchasePrice = double.tryParse(_packPurchasePriceController.text) ?? -1;
    final stockPacks = int.tryParse(_stockPacksController.text) ?? 0;
    final lowStockThreshold = int.tryParse(_lowStockThresholdController.text) ?? 2;
    final barcode = _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim();
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    if (!ProductService.validateProductFields(
      productName: productName,
      salePrice: salePrice,
      packPurchasePrice: packPurchasePrice,
      packQuantity: packQuantity,
      addedDate: _addedDate,
      category: selectedCategory,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields correctly')));
      return;
    }

    final purchasePrice = ProductService.calculatePurchasePrice(packPurchasePrice, packQuantity);
    final totalSalePrice = ProductService.calculateTotalSalPricr(salePrice, packQuantity);
    final profitPrice = ProductService.calculateProfitPrice(packPurchasePrice, totalSalePrice);

    final product = Product(
      id: widget.product?.id,
      productName: productName,
      salePrice: salePrice,
      totalSalePrice: totalSalePrice,
      profit: profitPrice,
      purchasePrice: purchasePrice,
      packQuantity: packQuantity,
      packPurchasePrice: packPurchasePrice,
      addedDate: _addedDate,
      category: selectedCategory,
      currency: _currency,
      stockPacks: stockPacks,
      lowStockThreshold: lowStockThreshold,
      barcode: barcode,
      expiryDate: _expiryDate,
      imagePath: _imagePath,
      notes: notes,
    );

    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    if (widget.product == null) {
      await productProvider.addProduct(product);
    } else {
      await productProvider.updateProduct(product);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final categories = context.watch<CategoryProvider>().categories.map((c) => c.name).toList();
    if (_category.isEmpty && categories.isNotEmpty) {
      _category = categories[0];
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.product == null ? t.addProduct : t.editProduct,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 42, 150, 177),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery),
                      onLongPress: () => _pickImage(ImageSource.camera),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: (_imagePath != null && File(_imagePath!).existsSync())
                            ? FileImage(File(_imagePath!))
                            : null,
                        child: _imagePath == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_a_photo, size: 30, color: Color.fromARGB(255, 42, 150, 177)),
                                  SizedBox(height: 2),
                                  Text('Add Photo', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              )
                            : null,
                      ),
                    ),
                    if (_imagePath != null)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.red,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close, size: 16, color: Colors.white),
                            onPressed: () => setState(() => _imagePath = null),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '${t.productName} *'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _packQuantityController,
                decoration: InputDecoration(labelText: '${t.packQuantity} *'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || int.tryParse(value) == null ? 'Invalid number' : null,
              ),
              TextFormField(
                controller: _packPurchasePriceController,
                decoration: InputDecoration(labelText: '${t.packPurchasePrice} *'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null || double.tryParse(value) == null ? 'Invalid price' : null,
              ),
              TextFormField(
                controller: _purchasePriceController,
                decoration: InputDecoration(labelText: t.purchasePrice),
                readOnly: true,
              ),
              TextFormField(
                controller: _salePriceController,
                decoration: InputDecoration(labelText: '${t.salePrice} *'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null || double.tryParse(value) == null ? 'Invalid price' : null,
              ),
              TextFormField(
                controller: _totalSalePriceController,
                decoration: InputDecoration(labelText: t.totalSalePrice),
                readOnly: true,
              ),
              TextFormField(
                controller: _profitController,
                decoration: InputDecoration(labelText: t.expectedProfit),
                readOnly: true,
              ),
              const Divider(height: 30),
              TextFormField(
                controller: _stockPacksController,
                decoration: InputDecoration(labelText: t.stockPacks),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _lowStockThresholdController,
                decoration: InputDecoration(labelText: t.lowStockThreshold),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(labelText: t.barcode),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner, color: Color.fromARGB(255, 42, 150, 177)),
                    onPressed: _scanBarcode,
                  ),
                ],
              ),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: t.notes),
                maxLines: 2,
              ),
              DropdownButtonFormField<Currency>(
                value: _currency,
                decoration: InputDecoration(labelText: t.currency),
                items: _currencies
                    .map((currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(CurrencyManager.getCurrencySymbol(currency)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _currency = value;
                    });
                  }
                },
              ),
              DropdownButtonFormField<String>(
                value: categories.contains(_category) ? _category : (categories.isNotEmpty ? categories[0] : null),
                decoration: InputDecoration(labelText: t.category),
                items: categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('${t.addedDate}: ${_addedDate.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text(
                  _expiryDate == null
                      ? '${t.expiryDate}: N/A'
                      : '${t.expiryDate}: ${_expiryDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_expiryDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _expiryDate = null;
                          });
                        },
                      ),
                    const Icon(Icons.event_note, color: Colors.orange),
                  ],
                ),
                onTap: () => _selectExpiryDate(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 42, 150, 177)),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
                ),
                child: Text(t.save, style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
