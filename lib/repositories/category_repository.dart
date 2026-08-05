import '../database/category_data_source.dart';
import '../models/category.dart';

class CategoryRepository {
  final CategoryDataSource _dataSource;

  CategoryRepository(this._dataSource);

  Future<int> addCategory(Category category) async {
    return await _dataSource.addCategory(category);
  }

  Future<int> updateCategory(Category category) async {
    return await _dataSource.updateCategory(category);
  }

  Future<int> deleteCategory(int id) async {
    return await _dataSource.deleteCategory(id);
  }

  Future<List<Category>> getAllCategories() async {
    return await _dataSource.getAllCategories();
  }

  Future<int> getProductsCountInCategory(String categoryName) async {
    return await _dataSource.getProductsCountInCategory(categoryName);
  }
}
