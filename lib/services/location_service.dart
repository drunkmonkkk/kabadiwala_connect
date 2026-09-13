import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Result of a location fetch attempt.
class LocationResult {
  final double latitude;
  final double longitude;
  final String description;
  final bool isFallback;
  final String? errorMessage;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.description,
    this.isFallback = false,
    this.errorMessage,
  });

  String get coordinatesString =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
}

/// Robust location service for Kabadiwala Connect.
/// Handles permissions, timeouts, GPS hardware delays, and safe fallbacks.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  // Default fallback coordinates (Central scrap exchange hub, New Delhi)
  static const double defaultLatitude = 28.6139;
  static const double defaultLongitude = 77.2090;
  static const String defaultAreaName = 'Central Scrap Hub, Connaught Place';

  LocationResult? _lastResult;
  LocationResult? get lastResult => _lastResult;

  /// Check whether GPS service is enabled on the device.
  Future<bool> isServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  /// Check and request location permission.
  Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Get current position with timeout and fallback logic.
  /// Never blocks or hangs indefinitely.
  Future<LocationResult> fetchLocation({bool allowFallback = true}) async {
    try {
      final serviceEnabled = await isServiceEnabled();
      if (!serviceEnabled) {
        if (allowFallback) {
          return _useFallback('Location services (GPS) are turned off on your device.');
        }
        return const LocationResult(
          latitude: defaultLatitude,
          longitude: defaultLongitude,
          description: 'GPS disabled',
          isFallback: true,
          errorMessage: 'Location services are disabled. Please enable GPS.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (allowFallback) {
          return _useFallback('Location permission denied. Using standard hub coordinates.');
        }
        return const LocationResult(
          latitude: defaultLatitude,
          longitude: defaultLongitude,
          description: 'Permission denied',
          isFallback: true,
          errorMessage: 'Location permission denied.',
        );
      }

      // 1. Attempt current position with a strict timeout (6 seconds)
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 6),
          ),
        );

        final result = LocationResult(
          latitude: position.latitude,
          longitude: position.longitude,
          description:
              '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
          isFallback: false,
        );
        _lastResult = result;
        return result;
      } on TimeoutException {
        // Fallback to last known position on timeout
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          final result = LocationResult(
            latitude: lastKnown.latitude,
            longitude: lastKnown.longitude,
            description:
                '${lastKnown.latitude.toStringAsFixed(5)}, ${lastKnown.longitude.toStringAsFixed(5)} (cached)',
            isFallback: false,
          );
          _lastResult = result;
          return result;
        }

        if (allowFallback) {
          return _useFallback('GPS signal timed out indoors. Using hub location.');
        }
        rethrow;
      }
    } catch (e) {
      if (allowFallback) {
        return _useFallback('Could not read GPS: $e');
      }
      return LocationResult(
        latitude: defaultLatitude,
        longitude: defaultLongitude,
        description: 'Location unavailable',
        isFallback: true,
        errorMessage: e.toString(),
      );
    }
  }

  LocationResult _useFallback(String reason) {
    final result = LocationResult(
      latitude: defaultLatitude,
      longitude: defaultLongitude,
      description: defaultAreaName,
      isFallback: true,
      errorMessage: reason,
    );
    _lastResult = result;
    return result;
  }

  /// Calculate distance in kilometers between two GPS coordinates.
  double distanceBetweenKm({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    final distanceMeters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
    return double.parse((distanceMeters / 1000.0).toStringAsFixed(1));
  }
}
