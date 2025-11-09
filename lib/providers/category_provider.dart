import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;
import '../core/models/category.dart';
import '../core/services/database_service.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = false;

  // Getters
  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  // Load categories from database
  Future<void> loadCategories({bool forceRefresh = false}) async {
    // Avoid reloading if already fetched
    if (_categories.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _db.getCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a category
  void selectCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Clear selected category (optional)
  void clearSelection() {
    _selectedCategory = null;
    notifyListeners();
  }
}
