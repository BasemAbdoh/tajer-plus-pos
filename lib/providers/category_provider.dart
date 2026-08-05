import 'package:flutter/material.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  CategoryProvider(this._repository);

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _repository.getAllCategories();
    } catch (e) {
      debugPrint("Error loading categories: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory(String name, {String? icon}) async {
    if (name.trim().isEmpty) return false;
    try {
      final category = Category(
        name: name.trim(),
        icon: icon,
        createdAt: DateTime.now(),
      );
      await _repository.addCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint("Error adding category: $e");
      return false;
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      await _repository.updateCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint("Error updating category: $e");
      return false;
    }
  }

  Future<bool> deleteCategory(int id, String categoryName) async {
    try {
      final count = await _repository.getProductsCountInCategory(categoryName);
      if (count > 0) {
        return false; // لا يمكن حذف قسم يحتوي على منتجات
      }
      await _repository.deleteCategory(id);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint("Error deleting category: $e");
      return false;
    }
  }
}
