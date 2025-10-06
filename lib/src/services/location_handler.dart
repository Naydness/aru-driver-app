import 'package:geolocator/geolocator.dart';

abstract class LocationHandler {
  static Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location service not enabled');
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print('Location permission denied forever');
      return false;
    }

    print('Location permission granted');
    return true;
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await handleLocationPermission();
      if (!hasPermission) return null;
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high
        )
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Stream<Position>?> getLocationStream() async {
    try {
      final hasPermission = await handleLocationPermission();
      if (!hasPermission) return null;

      return Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high
        )
      );
    } catch (e) {
      return null;
    }
  }
}