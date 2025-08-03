import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learning/core/provider/permission_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_provider.g.dart';

// Simple provider for ImagePicker
@riverpod
ImagePicker imagePicker(Ref ref) {
  return ImagePicker();
}

// CAMERA CAPTURE - No storage permissions needed!
@riverpod
Future<Uint8List?> takePhoto(Ref ref) async {
  try {
    final permissionProvider = ref.read(permissionProviderProvider.notifier);
    final picker = ref.read(imagePickerProvider);
    
    // ONLY check camera permission
    if (!ref.read(permissionProviderProvider).cameraGranted) {
      final granted = await permissionProvider.requestCameraPermission();
      if (!granted) return null;
    }

    // Take photo - this uses temporary cache, no storage permission needed
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      return Uint8List.fromList(bytes);
    }
    
    return null;
  } catch (e) {
    print('Error taking photo: $e');
    return null;
  }
}

