import '../database/product_data_source.dart';
import '../models/product.dart';

class ProductRepository {
  final ProductDataSource _dataSource;

  ProductRepository(this._dataSource);

  Future<int> addProduct(Product product) async {
    return await _dataSource.addProduct(product);
  }

  Future<void> addProductFromMap(Map<String, dynamic> map) async {
    await _dataSource.addProductFromMap(map);
  }

  Future<int> updateProduct(Product product) async {
    return await _dataSource.updateProduct(product);
  }

  Future<int> deleteProduct(int id) async {
    return await _dataSource.deleteProduct(id);
  }

  Future<int> deleteAllProducts() async {
    return await _dataSource.deleteAllProducts();
  }

  Future<Product?> getProductById(int id) async {
    return await _dataSource.getProductById(id);
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    return await _dataSource.getProductsByCategory(category);
  }

  Future<List<Product>> getAllProducts() async {
    return await _dataSource.getAllProducts();
  }

  Future<List<Product>> getLowStockProducts() async {
    return await _dataSource.getLowStockProducts();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    return await _dataSource.getProductByBarcode(barcode);
  }
}
