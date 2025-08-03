// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imagePickerHash() => r'7877699a862be48e962306635347623c45e91971';

/// See also [imagePicker].
@ProviderFor(imagePicker)
final imagePickerProvider = AutoDisposeProvider<ImagePicker>.internal(
  imagePicker,
  name: r'imagePickerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$imagePickerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ImagePickerRef = AutoDisposeProviderRef<ImagePicker>;
String _$takePhotoHash() => r'8ee20d9d2819dd0b336848380149e61548d8b904';

/// See also [takePhoto].
@ProviderFor(takePhoto)
final takePhotoProvider = AutoDisposeFutureProvider<Uint8List?>.internal(
  takePhoto,
  name: r'takePhotoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$takePhotoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TakePhotoRef = AutoDisposeFutureProviderRef<Uint8List?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
