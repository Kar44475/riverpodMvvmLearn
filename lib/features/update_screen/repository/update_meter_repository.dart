
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:learning/core/constant/server_constant.dart';
import 'package:learning/core/failure/failure.dart';
import 'package:learning/features/home_screen/model/product_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'update_meter_repository.g.dart';

@riverpod
UpdateMeterRepository updateMeterRepository(Ref ref) {
  return UpdateMeterRepository();
}

class UpdateMeterRepository {
  Future<Either<AppFailure, Product>> postData({
    required int? productId,
    required double? productData,
    required Uint8List? imageBytes,
    required double? longitude,
    required double? latitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ServerContant.serverUrl}/api/products?page="),
        headers: {'Content-Type': 'application/json'},
      );
      // If any response is received, return a fake Product model
      final fakeProduct = Product(
        id: productId,
        title: 'Product send',
        price: productData,
        description: 'product description',
        category: 'Fake',
        image: null,
        rating: null,
      );
      return Right(fakeProduct);
    } catch (e) {
      // Only return failure if there is no internet (network error)
      return Left(AppFailure('No internet connection or network error: $e'));
    }
  }
}
