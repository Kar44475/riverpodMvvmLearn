import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_provider.g.dart';

// Simplified Permission State - only what you need
class PermissionState {
  final bool cameraGranted;
  final bool locationGranted;
  final bool isCheckingPermissions;
  final String? error;

  const PermissionState({
    this.cameraGranted = false,
    this.locationGranted = false,
    this.isCheckingPermissions = false,
    this.error,
  });

  PermissionState copyWith({
    bool? cameraGranted,
    bool? locationGranted,
    bool? isCheckingPermissions,
    String? error,
  }) {
    return PermissionState(
      cameraGranted: cameraGranted ?? this.cameraGranted,
      locationGranted: locationGranted ?? this.locationGranted,
      isCheckingPermissions: isCheckingPermissions ?? this.isCheckingPermissions,
      error: error,
    );
  }
}

@Riverpod(keepAlive: true)
class PermissionProvider extends _$PermissionProvider {
  @override
  PermissionState build() {
    return const PermissionState();
  }

  // Check permissions - only camera and location
  Future<void> checkAllPermissions() async {
    state = state.copyWith(isCheckingPermissions: true, error: null);

    try {
      final cameraStatus = await Permission.camera.status;
      final locationStatus = await Permission.location.status;

      state = state.copyWith(
        cameraGranted: cameraStatus.isGranted,
        locationGranted: locationStatus.isGranted,
        isCheckingPermissions: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCheckingPermissions: false,
        error: 'Failed to check permissions: $e',
      );
    }
  }

  // Request camera permission - ONLY THIS IS NEEDED FOR PHOTO CAPTURE
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      
      final granted = status.isGranted;
      state = state.copyWith(cameraGranted: granted);
      
      if (!granted && status.isPermanentlyDenied) {
        state = state.copyWith(
          error: 'Camera permission permanently denied. Please enable in settings.',
        );
      }
      
      return granted;
    } catch (e) {
      state = state.copyWith(error: 'Failed to request camera permission: $e');
      return false;
    }
  }

  // Request location permission (only if you need GPS coordinates)
  Future<bool> requestLocationPermission() async {
    try {      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          error: 'Location services are disabled. Please enable location services.',
        );
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            error: 'Location permission denied',
            locationGranted: false,
          );
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          error: 'Location permission permanently denied. Please enable in settings.',
          locationGranted: false,
        );
        return false;
      }

      final granted = permission == LocationPermission.whileInUse || 
                     permission == LocationPermission.always;
      
      state = state.copyWith(locationGranted: granted);
      return granted;
    } catch (e) {
      state = state.copyWith(error: 'Failed to request location permission: $e');
      return false;
    }
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}