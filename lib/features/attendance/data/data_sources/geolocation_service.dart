import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'dummy_geolocation.dart';

/// Service for handling geolocation and location permissions
/// Manages GPS requests, permission handling, and location data fetching
class GeolocationService {
  /// Request location permission from the user
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isDenied) {
      return false;
    } else if (status.isPermanentlyDenied) {
      // Permission is permanently denied, user must enable it manually
      openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  /// Check if location permission is already granted
  Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Get the current location
  /// In a real app, this would use geolocator or similar package
  /// For now, returns dummy data that can be replaced
  Future<LocationCoordinates> getCurrentLocation() async {
    try {
      // Simulate location fetching with a delay
      // In production, use: geolocator.getCurrentPosition()
      await Future.delayed(const Duration(milliseconds: 800));

      // Use dummy data from DummyGeolocation
      final mockUserPos = DummyGeolocation.userFarFromOffice;

      return LocationCoordinates(
        latitude: mockUserPos['latitude']!,
        longitude: mockUserPos['longitude']! + (Random().nextDouble() * 0.0001), // Small variance
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw LocationFetchException('Failed to fetch location: $e');
    }
  }

  /// Validate if a location is within a geofence
  /// Returns true if the point is within the specified radius
  bool isWithinGeofence({
    required double userLatitude,
    required double userLongitude,
    required double centerLatitude,
    required double centerLongitude,
    required double radiusInMeters,
  }) {
    const double earthRadiusKm = 6371;

    final double latDiff = userLatitude - centerLatitude;
    final double lngDiff = userLongitude - centerLongitude;

    // Haversine formula
    final double a = (latDiff * latDiff) + (lngDiff * lngDiff);
    final double distance =
        earthRadiusKm * 2 * asin(sqrt(a / 4)) * 1000; // Convert to meters

    return distance <= radiusInMeters;
  }

  /// Format coordinates to a readable string
  String formatCoordinates(double latitude, double longitude) {
    final latDir = latitude >= 0 ? "N" : "S";
    final lngDir = longitude >= 0 ? "E" : "W";
    return "${latitude.abs().toStringAsFixed(4)}° $latDir, ${longitude.abs().toStringAsFixed(4)}° $lngDir";
  }

  /// Open app settings for manual permission configuration
  static Future<void> openPermissionSettings() async {
    await openAppSettings();
  }
}

/// Location coordinates data class
class LocationCoordinates {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;

  LocationCoordinates({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
  });

  String toFormattedString() {
    final latDir = latitude >= 0 ? "N" : "S";
    final lngDir = longitude >= 0 ? "E" : "W";
    return "${latitude.abs().toStringAsFixed(4)}° $latDir, ${longitude.abs().toStringAsFixed(4)}° $lngDir";
  }

  @override
  String toString() =>
      'LocationCoordinates(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
}

/// Exception thrown when location permission is denied
class LocationPermissionException implements Exception {
  final String message;
  LocationPermissionException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when location fetching fails
class LocationFetchException implements Exception {
  final String message;
  LocationFetchException(this.message);

  @override
  String toString() => message;
}
