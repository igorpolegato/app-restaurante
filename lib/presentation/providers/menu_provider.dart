import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/models/item_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/item_repository.dart';

class MenuProvider extends ChangeNotifier {
  final ItemRepository _itemRepo;
  final CategoryRepository _categoryRepo;

  MenuProvider(this._itemRepo, this._categoryRepo);

  List<ItemModel> _allItems = [];
  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  List<ItemModel> get allItems => _allItems;
  List<CategoryModel> get categories => _categories;
  int? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ItemModel> get filteredItems {
    var items = _allItems;

    if (_selectedCategoryId != null) {
      items = items
          .where((item) =>
              item.categories.any((cat) => cat.id == _selectedCategoryId))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items
          .where((item) =>
              item.name.toLowerCase().contains(q) ||
              (item.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return items;
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _itemRepo.getItems(),
        _categoryRepo.getCategories(),
      ]);
      _allItems = results[0] as List<ItemModel>;
      _categories = results[1] as List<CategoryModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
