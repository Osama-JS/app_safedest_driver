import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final ApiService _apiService = ApiService();

  Position? _currentPosition;
  bool _isTracking = false;
  bool _isOnline = false;
  bool _isFree = true;
  StreamSubscription<Position>? _positionStream;
  Timer? _locationUpdateTimer;

  // Getters
  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  bool get isOnline => _isOnline;
  bool get isFree => _isFree;

  // Initialize location service
  Future<bool> initialize() async {
    try {
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) return false;

      await _getCurrentLocation();
      return true;
    } catch (e) {
      debugPrint('Location service initialization error: $e');
      return false;
    }
  }

  // Request location permission
  Future<bool> _requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Location permission error: $e');
      return false;
    }
  }

  // Get current location
  Future<Position?> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;
      notifyListeners();

      return position;
    } catch (e) {
      debugPrint('Get current location error: $e');
      return null;
    }
  }

  // Start location tracking
  Future<bool> startTracking() async {
    if (_isTracking) return true;

    try {
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) return false;

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _currentPosition = position;
          notifyListeners();
          _sendLocationUpdate(position);
        },
        onError: (error) {
          debugPrint('Location stream error: $error');
        },
      );

      // Also send periodic updates
      _locationUpdateTimer = Timer.periodic(
        Duration(seconds: AppConfig.locationUpdateInterval.toInt()),
        (timer) {
          if (_currentPosition != null) {
            _sendLocationUpdate(_currentPosition!);
          }
        },
      );

      _isTracking = true;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Start tracking error: $e');
      return false;
    }
  }

  // Stop location tracking
  void stopTracking() {
    _positionStream?.cancel();
    _locationUpdateTimer?.cancel();
    _isTracking = false;
    notifyListeners();
  }

  // Send location update to server
  Future<void> _sendLocationUpdate(Position position) async {
    try {
      await _apiService.post<void>(
        AppConfig.updateLocationEndpoint,
        body: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'speed': position.speed,
          'heading': position.heading,
          'timestamp': DateTime.now().toIso8601String(),
        },
        fromJson: null,
      );
    } catch (e) {
      debugPrint('Send location update error: $e');
    }
  }

  // Update driver status
  Future<ApiResponse<void>> updateDriverStatus({
    required bool online,
    bool? free,
    String? status,
  }) async {
    try {
      final response = await _apiService.post<void>(
        AppConfig.updateStatusEndpoint,
        body: {
          'online': online,
          if (free != null) 'free': free,
          if (status != null) 'status': status,
        },
        fromJson: null,
      );

      if (response.isSuccess) {
        _isOnline = online;
        if (free != null) _isFree = free;
        notifyListeners();
      }

      return response;
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'فشل في تحديث حالة السائق: $e',
      );
    }
  }

  // Get current status from server
  Future<ApiResponse<Map<String, dynamic>>> getCurrentStatus() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        AppConfig.getCurrentStatusEndpoint,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!;

        // Update local status
        if (data['status'] != null) {
          final statusData = data['status'];
          _isOnline = statusData['online'] ?? false;
          _isFree = statusData['free'] ?? true;
        }

        // Update location if available
        if (data['location'] != null) {
          final locationData = data['location'];
          final lat = locationData['latitude']?.toDouble();
          final lng = locationData['longitude']?.toDouble();

          if (lat != null && lng != null) {
            // Create a position object for consistency
            // Note: This is a simplified position without all Geolocator fields
          }
        }

        notifyListeners();
      }

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'فشل في جلب الحالة الحالية: $e',
      );
    }
  }

  // Update FCM token
  Future<ApiResponse<void>> updateFcmToken(String fcmToken,
      {String? deviceId}) async {
    try {
      final response = await _apiService.post<void>(
        AppConfig.updateFcmTokenEndpoint,
        body: {
          'fcm_token': fcmToken,
          if (deviceId != null) 'device_id': deviceId,
        },
        fromJson: null,
      );

      return response;
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'فشل في تحديث رمز الإشعارات: $e',
      );
    }
  }

  // Go online
  Future<ApiResponse<void>> goOnline() async {
    final response = await updateDriverStatus(online: true, free: true);
    if (response.isSuccess) {
      await startTracking();
    }
    return response;
  }

  // Go offline
  Future<ApiResponse<void>> goOffline() async {
    stopTracking();
    return await updateDriverStatus(online: false, free: false);
  }

  // Set busy status
  Future<ApiResponse<void>> setBusy() async {
    return await updateDriverStatus(online: true, free: false);
  }

  // Set available status
  Future<ApiResponse<void>> setAvailable() async {
    return await updateDriverStatus(online: true, free: true);
  }

  // Calculate distance between two points
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  // Get distance to location
  double? getDistanceToLocation(double latitude, double longitude) {
    if (_currentPosition == null) return null;

    return calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

  // Check if location services are available
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Dispose
  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
