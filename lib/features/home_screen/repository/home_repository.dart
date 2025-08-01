import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:learning/core/constant/server_constant.dart';
import 'package:learning/core/failure/failure.dart';
import 'package:learning/features/home_screen/model/product_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(Ref ref) {
  return HomeRepository();
}

class HomeRepository {
  Future<Either<AppFailure, List<Product>>> getData({
    required int pageCount,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("${ServerContant.serverUrl}/api/products?page=$pageCount"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        return Left(AppFailure('Server error: ${response.statusCode}'));
      }

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      // Parse the products list
      final products = (resBodyMap['products'] as List<dynamic>)
          .map((product) => Product.fromJson(product as Map<String, dynamic>))
          .toList();

      return Right(products);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}
