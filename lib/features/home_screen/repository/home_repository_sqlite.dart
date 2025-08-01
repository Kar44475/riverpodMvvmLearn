import 'package:learning/core/database_helper/database_helper.dart';
import 'package:learning/features/home_screen/model/product_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_repository_sqlite.g.dart';

@riverpod
HomeRepositorySQLite homeRepositorySQLite(Ref ref) {
  return HomeRepositorySQLite();
}

class HomeRepositorySQLite {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Save products to SQLite
  Future<void> saveProducts(List<Product> products) async {
    try {
      await _dbHelper.insertProducts(products);
    } catch (e) {
      print('Error saving products to SQLite: $e');
      rethrow;
    }
  }

  // Get all products from SQLite
  Future<List<Product>> getAllProducts() async {
    try {
      return await _dbHelper.getAllProducts();
    } catch (e) {
      print('Error getting products from SQLite: $e');
      return [];
    }
  }

  // Get products by page (for pagination)
  Future<List<Product>> getProductsByPage(int page, {int itemsPerPage = 10}) async {
    try {
      return await _dbHelper.getProductsPaginated(page, limit: itemsPerPage);
    } catch (e) {
      print('Error getting products by page from SQLite: $e');
      return [];
    }
  }

  // Check if we have any cached data
  Future<bool> hasData() async {
    try {
      return await _dbHelper.hasData();
    } catch (e) {
      print('Error checking if SQLite has data: $e');
      return false;
    }
  }

  // Clear all cached data
  Future<void> clearCache() async {
    try {
      await _dbHelper.clearProducts();
    } catch (e) {
      print('Error clearing SQLite cache: $e');
      rethrow;
    }
  }

  // Get total count of cached products
  Future<int> getTotalCount() async {
    try {
      return await _dbHelper.getProductCount();
    } catch (e) {
      print('Error getting total count from SQLite: $e');
      return 0;
    }
  }
}