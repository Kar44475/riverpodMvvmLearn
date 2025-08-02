import 'dart:typed_data';

import 'package:learning/features/home_screen/Provider/selected_product_provider.dart';
import 'package:learning/features/home_screen/model/product_model.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_viewmodel.g.dart';

// State class to hold the update screen data
class UpdateProductState {
  final Product? selectedProduct;
  final String? extraDetails;
  final Uint8List? photoBytes;
  final bool isUpdating;
  final bool isLoading;
  final String? error;
  final bool updateSuccess;

  const UpdateProductState({
    this.selectedProduct,
    this.extraDetails,
    this.photoBytes,
    this.isUpdating = false,
    this.isLoading = false,
    this.error,
    this.updateSuccess = false,
  });

  UpdateProductState copyWith({
    Product? selectedProduct,
    String? extraDetails,
    Uint8List? photoBytes,
    bool? isUpdating,
    bool? isLoading,
    String? error,
    bool? updateSuccess,
  }) {
    return UpdateProductState(
      selectedProduct: selectedProduct ?? this.selectedProduct,
      extraDetails: extraDetails ?? this.extraDetails,
      photoBytes: photoBytes ?? this.photoBytes,
      isUpdating: isUpdating ?? this.isUpdating,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      updateSuccess: updateSuccess ?? this.updateSuccess,
    );
  }
}

@riverpod
class UpdateViewModel extends _$UpdateViewModel {
  // remove late UpdateRepository _updateRepository;

  @override
  UpdateProductState build() {
    // remove
   // remove  _updateRepository = ref.watch(updateRepositoryProvider);
    
    // Initialize with empty state
    final initialState = const UpdateProductState(isLoading: true);
    
    // Load the selected product from the provider
    Future.microtask(() => _loadSelectedProduct());
    
    return initialState;
  }

  // Load selected product from the provider
  void _loadSelectedProduct() {
    final selectedProduct = ref.read(selectedProductProviderProvider);
    
    if (selectedProduct != null) {
      state = state.copyWith(
        selectedProduct: selectedProduct,
        isLoading: false,
      );
      
      // Load additional details if needed
   //   _loadAdditionalDetails();
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'No product selected',
      );
    }
  }

  // Load additional product details from API (if needed)
  // Future<void> _loadAdditionalDetails() async {
  //   if (state.selectedProduct == null) return;
    
  //   try {
  //     final result = await _updateRepository.getProductDetails(
  //       state.selectedProduct!.id!,
  //     );

  //     result.fold(
  //       (failure) {
  //         state = state.copyWith(error: failure.message);
  //       },
  //       (additionalData) {
  //         state = state.copyWith(
  //           extraDetails: additionalData['extraDetails'],
  //         );
  //       },
  //     );
  //   } catch (e) {
  //     state = state.copyWith(error: 'Failed to load details: $e');
  //   }
  // }

  // // Update extra details
  // void updateExtraDetails(String details) {
  //   state = state.copyWith(extraDetails: details);
  // }

  // Update photo
  // void updatePhoto(Uint8List? photoBytes) {
  //   state = state.copyWith(photoBytes: photoBytes);
  // }

  // // Capture photo
  // Future<void> capturePhoto() async {
  //   try {
  //     // TODO: Implement actual photo capture
  //     await Future.delayed(const Duration(seconds: 1));
      
  //     // Simulate photo capture - replace with actual implementation
  //     final dummyPhoto = Uint8List.fromList([1, 2, 3, 4, 5]);
  //     updatePhoto(dummyPhoto);
      
  //   } catch (e) {
  //     state = state.copyWith(error: 'Failed to capture photo: $e');
  //   }
  // }

  // Update product via API
  Future<void> updateProduct() async {
    if (state.isUpdating || state.selectedProduct == null) return;

    state = state.copyWith(
      isUpdating: true,
      error: null,
      updateSuccess: false,
    );

    try {
      // Create updated product data
      final updatedProductData = {
        'id': state.selectedProduct!.id,
        'title': state.selectedProduct!.title,
        'price': state.selectedProduct!.price,
        'description': state.selectedProduct!.description,
        'category': state.selectedProduct!.category,
        'image': state.selectedProduct!.image,
        'rating': state.selectedProduct!.rating?.toJson(),
        'extraDetails': state.extraDetails,
        'hasPhoto': state.photoBytes != null,
      };

      // final result = await _updateRepository.updateProduct(
      //   productId: state.selectedProduct!.id!,
      //   productData: updatedProductData,
      //   photoBytes: state.photoBytes,
      // );

      // result.fold(
      //   (failure) {
      //     state = state.copyWith(
      //       isUpdating: false,
      //       error: failure.message,
      //     );
      //   },
      //   (updatedProduct) {
      //     state = state.copyWith(
      //       isUpdating: false,
      //       updateSuccess: true,
      //       selectedProduct: updatedProduct,
      //     );
      //   },
      // );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to update product: $e',
      );
    }
  }

  // Reset error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset success state
  void clearSuccess() {
    state = state.copyWith(updateSuccess: false);
  }

  // Refresh product data
  Future<void> refreshProduct() async {
    state = state.copyWith(isLoading: true);
    _loadSelectedProduct();
  }
}