import 'package:learning/features/home_screen/model/product_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_product_provider.g.dart';

// Simple provider to transfer selected product data between screens
@Riverpod(keepAlive: true)
class SelectedProductProvider extends _$SelectedProductProvider {
  @override
  Product? build() {
    return null;
  }

  // Set the selected product (called from home screen)
  void setSelectedProduct(Product product) {
    state = product;
  }

  // Clear the selected product (optional - for cleanup)
  void clearSelectedProduct() {
    state = null;
  }

  // Get the selected product (used by update viewmodel)
  Product? getSelectedProduct() {
    return state;
  }
}