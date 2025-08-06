import 'dart:typed_data';

import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learning/core/provider/connectivity_provider.dart';
import 'package:learning/core/provider/image_provider.dart';
import 'package:learning/core/provider/location_provider.dart';
import 'package:learning/core/provider/permission_provider.dart';
import 'package:learning/features/home_screen/Provider/selected_product_provider.dart';
import 'package:learning/features/home_screen/model/product_model.dart';
import 'package:learning/features/update_screen/repository/update_meter_repository.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_viewmodel.g.dart';

// State class to hold the update screen data
class UpdateProductState {
  final Product? selectedProduct;
  final String? extraDetails;
  final Uint8List? photoBytes;
  final Position? currentLocation;
  final bool isUpdating;
  final bool isLoading;
  final bool isTakingPhoto;
  final bool isGettingLocation;
  final bool islocationServicesEnabled;
  final String? error;
  final bool updateSuccess;

  const UpdateProductState({
    this.selectedProduct,
    this.extraDetails,
    this.photoBytes,
    this.currentLocation,
    this.isUpdating = false,
    this.isLoading = false,
    this.isTakingPhoto = false,
    this.isGettingLocation = false,
    this.islocationServicesEnabled = true,
    this.error,
    this.updateSuccess = false,
  });

  UpdateProductState copyWith({
    Product? selectedProduct,
    double? meterReading,
    Uint8List? photoBytes,
    Position? currentLocation,
    bool? isUpdating,
    bool? isLoading,
    bool? isTakingPhoto,
    bool? isGettingLocation,
    bool? islocationServicesEnabled,
    String? error,
    bool? updateSuccess,
  }) {
    return UpdateProductState(
      selectedProduct: selectedProduct ?? this.selectedProduct,
      photoBytes: photoBytes ?? this.photoBytes,
      currentLocation: currentLocation ?? this.currentLocation,
      isUpdating: isUpdating ?? this.isUpdating,
      isLoading: isLoading ?? this.isLoading,
      isTakingPhoto: isTakingPhoto ?? this.isTakingPhoto,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
      islocationServicesEnabled: islocationServicesEnabled ?? this.islocationServicesEnabled,
      error: error,
      updateSuccess: updateSuccess ?? this.updateSuccess,
    );
  }
}

@riverpod
class UpdateViewModel extends _$UpdateViewModel {
  late UpdateMeterRepository _updateRepository;
  late ConnectivityProvider _connectivityProvider;
  late ImagePicker _imagePickerService;

  @override
  UpdateProductState build() {
    _connectivityProvider = ref.watch(connectivityProviderProvider.notifier);
    _updateRepository = ref.watch(updateMeterRepositoryProvider);
  //  _imagePickerService = ref.watch(imagePickerServiceProvider.notifier);

    // Initialize with empty state
    final initialState = const UpdateProductState(isLoading: true);

    // Load the selected product from the provider
    Future.microtask(() => _loadSelectedProduct());

    return initialState;
  }

  // Load selected product from the provider
  void _loadSelectedProduct() {
    final selectedProduct = ref.read(selectedProductProviderProvider);
    ref.read(permissionProviderProvider.notifier).checkAllPermissions();


    if (selectedProduct != null) {
      state = state.copyWith(
        selectedProduct: selectedProduct,
        isLoading: false,
      );

      // Load additional details if needed
      //   _loadAdditionalDetails();
    } else {
      state = state.copyWith(isLoading: false, error: 'No product selected');
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
Future<void> capturePhoto() async {
    if (state.isTakingPhoto) return;

    try {
      state = state.copyWith(isTakingPhoto: true, error: null);

      final photoBytes = await ref.read(takePhotoProvider.future);

      if (photoBytes != null) {
        state = state.copyWith(   
          photoBytes: photoBytes,
          isTakingPhoto: false,
        );
      } else {
        state = state.copyWith(
          isTakingPhoto: false,
          error: 'Failed to capture photo. Please check camera permissions.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isTakingPhoto: false,
        error: 'Failed to capture photo: $e',
      );
    }
  }

  // Update product via API
  Future<void> updateProduct() async {
    if (state.isUpdating || state.selectedProduct == null) return;
 state = state.copyWith(isGettingLocation: true, error: null);

      // Get location with proper error handling
      Position? currentLocation;
      try {
        currentLocation = await ref.read(getCurrentLocationProvider.future);
        if (currentLocation != null) {
          print('Location obtained: ${currentLocation.latitude}, ${currentLocation.longitude}');
        } else {
          state = state.copyWith(islocationServicesEnabled: false);
          print('Location not available - continuing without location');
        }
      } catch (e) {
        print('Location error: $e');
        // Continue without location - don't fail the entire update
      }

      // Hide location dialog
      state = state.copyWith(
        isGettingLocation: false, 
        currentLocation: currentLocation,
        isUpdating: true,
        updateSuccess: false,
      );
    try {
      final connectivityProvider = ref.read(
        connectivityProviderProvider.notifier,
      );

      if (connectivityProvider.isOnline) {
        // Online: Direct API call
        await _updateProductOnline();
      } else {
        // Offline: Store in SQLite automatically
        await _updateProductOffline();
      }
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: 'Update failed: $e');
    }
  }

  Future<void> _updateProductOnline() async {
    try {
      final result = await _updateRepository.postData(
        productId: state.selectedProduct!.id!,
        imageBytes: state.photoBytes,
        productData: null, // Add actual product data if needed
        latitude: null, // Add actual latitude if needed
        longitude: null, // Add actual longitude if needed
      );

      result.fold(
        (failure) {
          state = state.copyWith(isUpdating: false, error: failure.message);
        },
        (updatedProduct) {
          state = state.copyWith(
            isUpdating: false,
            updateSuccess: true,
            selectedProduct: updatedProduct,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to update product: $e',
      );
    }
  }

  _updateProductOffline() async {
    try {
      final success = await ref
          .read(connectivityProviderProvider.notifier)
          .storeOfflineUpdate(
            productId: state.selectedProduct!.id!,
            reading: 0.0, // Replace with actual reading if needed
            imageBytes: state.photoBytes,
            longitude: 0.0, // Replace with actual longitude if needed
            latitude: 0.0, // Replace with actual latitude if needed
          );

      if (success) {
        state = state.copyWith(isUpdating: false, updateSuccess: true);
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: 'Failed to save offline update',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to save offline update: $e',
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
