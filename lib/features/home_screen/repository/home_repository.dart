import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:learning/core/constant/server_constant.dart';
import 'package:learning/core/failure/failure.dart';
import 'package:learning/features/home_screen/model/product_model.dart';
import 'package:learning/features/home_screen/repository/home_repository_sqlite.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(Ref ref) {
  return HomeRepository(ref);
}

class HomeRepository {
  final Ref _ref;
  late final HomeRepositorySQLite _sqliteRepository;

  HomeRepository(this._ref) {
    _sqliteRepository = _ref.read(homeRepositorySQLiteProvider);
  }

  Future<Either<AppFailure, List<Product>>> getData({
    required int pageCount,
    bool forceRefresh = false,
  }) async {
    try {
      // If not forcing refresh and we have cached data, return from SQLite first
      if (!forceRefresh && await _sqliteRepository.hasData()) {
        final cachedProducts = await _sqliteRepository.getProductsByPage(pageCount);
        if (cachedProducts.isNotEmpty) {
          return Right(cachedProducts);
        }
      }

      // Fetch from network
      final response = await http.get(
        Uri.parse("${ServerContant.serverUrl}/api/products?page=$pageCount"),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        // If network fails, try to return cached data as fallback
        if (await _sqliteRepository.hasData()) {
          final cachedProducts = await _sqliteRepository.getProductsByPage(pageCount);
          if (cachedProducts.isNotEmpty) {
            return Right(cachedProducts);
          }
        }
        return Left(AppFailure('Server error: ${response.statusCode}'));
      }

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      // Parse the products list
      final products = (resBodyMap['products'] as List<dynamic>)
          .map((product) => Product.fromJson(product as Map<String, dynamic>))
          .toList();

      // Save to SQLite cache
      await _sqliteRepository.saveProducts(products);

      return Right(products);
    } catch (e) {
      // If there's an error and we have cached data, return it
      if (await _sqliteRepository.hasData()) {
        final cachedProducts = await _sqliteRepository.getProductsByPage(pageCount);
        if (cachedProducts.isNotEmpty) {
          return Right(cachedProducts);
        }
      }
      return Left(AppFailure(e.toString()));
    }
  }

  // Method to get cached data only
  Future<Either<AppFailure, List<Product>>> getCachedData({required int pageCount}) async {
    try {
      final products = await _sqliteRepository.getProductsByPage(pageCount);
      return Right(products);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  // Method to clear cache
  Future<void> clearCache() async {
    await _sqliteRepository.clearCache();
  }

  // Check if cache has data
  Future<bool> hasCachedData() async {
    return await _sqliteRepository.hasData();
  }
}

