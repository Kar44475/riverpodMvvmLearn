import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learning/core/provider/permission_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'location_provider.g.dart';

@riverpod
Future<Position?> getCurrentLocation(Ref ref) async {
  try {
    final permissionProvider = ref.read(permissionProviderProvider.notifier);
    
    // Check if location permission is granted
    if (!ref.read(permissionProviderProvider).locationGranted) {
      final granted = await permissionProvider.requestLocationPermission();
      if (!granted) return null;
    }

     LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100,
);

Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    return position;
  } catch (e) {
    print('Error getting location: $e');
    return null;
  }
}