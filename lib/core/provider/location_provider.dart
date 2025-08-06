import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learning/core/provider/permission_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'location_provider.g.dart';

@riverpod
Future<Position?> getCurrentLocation(Ref ref) async {
  try {
 
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled');

      return null;
    }

 
    LocationPermission permission = await Geolocator.checkPermission();
    

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return null;
      }
    }
    

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');

      return null;
    }

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 20),
      distanceFilter: 100,
    );

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings
    );
    
    print('Location obtained: ${position.latitude}, ${position.longitude}');
    return position;
    
  } catch (e) {
    print('Error getting location: $e');
    return null;
  }
}