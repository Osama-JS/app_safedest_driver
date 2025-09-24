import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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
      debugPrint('🚀 LocationService: Starting initialization...');

      // Check if location services are available on device
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        debugPrint(
            '📍 LocationService: Location services available: $serviceEnabled');
      } catch (e) {
        debugPrint('⚠️ LocationService: Error checking location services: $e');
        // Continue anyway, might be a temporary issue
      }

      // Try to request permission with detailed error handling
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        debugPrint(
            '❌ LocationService: Permission not granted, but continuing initialization');
        // Don't return false, let the service initialize anyway
        // Permission can be requested later when needed
      }

      // Try to get initial location if permission is available
      if (hasPermission) {
        try {
          await _getCurrentLocation();
          debugPrint(
              '✅ LocationService: Initial location obtained successfully');
        } catch (e) {
          debugPrint('⚠️ LocationService: Could not get initial location: $e');
          // Continue anyway, location can be obtained later
        }
      }

      debugPrint('✅ LocationService: Initialization completed');
      return true;
    } catch (e) {
      debugPrint('💥 LocationService initialization error: $e');
      // Return true anyway to not block app startup
      return true;
    }
  }

  // Sync status with driver data (called when driver data is loaded)
  void syncWithDriverData({required bool online, required bool free}) {
    debugPrint(
        'Syncing LocationService with driver data: online=$online, free=$free');

    final wasOnline = _isOnline;
    _isOnline = online;
    _isFree = free;

    // If driver was online and we're syncing to online, start location services
    if (online && !wasOnline) {
      debugPrint('Driver is online, starting location services...');
      startTracking();
      _startLocationUpdateTimer();
    }
    // If driver was online but now offline, stop location services
    else if (!online && wasOnline) {
      debugPrint('Driver is offline, stopping location services...');
      stopTracking(); // This will also stop the location update timer
    }

    notifyListeners();
  }

  // Request GPS permission only (for app startup) with enhanced retry logic
  Future<bool> requestGPSPermissionOnly() async {
    try {
      debugPrint('🔍 Requesting GPS permission only...');

      // First attempt with comprehensive permission check
      final hasPermission = await _requestLocationPermission();
      if (hasPermission) {
        debugPrint('✅ GPS permission granted on first attempt');
        return true;
      }

      // If first attempt failed, try alternative approach
      debugPrint(
          '🔄 First attempt failed, trying alternative permission request...');

      // Try using permission_handler directly
      try {
        final status = await Permission.location.request();
        debugPrint('🔐 Alternative permission request result: $status');

        if (status.isGranted) {
          debugPrint('✅ GPS permission granted via alternative method');
          return true;
        } else if (status.isPermanentlyDenied) {
          debugPrint('❌ GPS permission permanently denied');
          return false;
        } else {
          debugPrint('❌ GPS permission denied via alternative method');
          return false;
        }
      } catch (e) {
        debugPrint('💥 Alternative permission request error: $e');
      }

      debugPrint('❌ All GPS permission attempts failed');
      return false;
    } catch (e) {
      debugPrint('💥 GPS permission request error: $e');
      return false;
    }
  }

  // Check detailed permission status for debugging with manifest validation
  Future<Map<String, dynamic>> getDetailedPermissionStatus() async {
    try {
      debugPrint('📊 Starting detailed permission status check...');

      // Test 1: Check if Geolocator can access manifest permissions
      bool manifestConfigured = true;
      String manifestError = '';
      try {
        await Geolocator.checkPermission();
        debugPrint('✅ Manifest test: Geolocator can read permissions');
      } catch (e) {
        if (e
            .toString()
            .toLowerCase()
            .contains('no location permissions are defined in the manifest')) {
          manifestConfigured = false;
          manifestError = e.toString();
          debugPrint('❌ Manifest test: FAILED - $e');
        }
      }

      // Test 2: Location services
      bool serviceEnabled = false;
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        debugPrint('📍 Location services test: $serviceEnabled');
      } catch (e) {
        debugPrint('❌ Location services test failed: $e');
      }

      // Test 3: permission_handler status
      PermissionStatus permissionHandlerStatus = PermissionStatus.denied;
      try {
        permissionHandlerStatus = await Permission.location.status;
        debugPrint('🔐 Permission handler test: $permissionHandlerStatus');
      } catch (e) {
        debugPrint('❌ Permission handler test failed: $e');
      }

      // Test 4: Geolocator permission (if manifest is configured)
      LocationPermission geolocatorPermission = LocationPermission.denied;
      if (manifestConfigured) {
        try {
          geolocatorPermission = await Geolocator.checkPermission();
          debugPrint('🔐 Geolocator permission test: $geolocatorPermission');
        } catch (e) {
          debugPrint('❌ Geolocator permission test failed: $e');
        }
      }

      final status = {
        'manifestConfigured': manifestConfigured,
        'manifestError': manifestError,
        'serviceEnabled': serviceEnabled,
        'permissionHandlerStatus': permissionHandlerStatus.toString(),
        'geolocatorPermission': geolocatorPermission.toString(),
        'isGranted': permissionHandlerStatus.isGranted,
        'isDenied': permissionHandlerStatus.isDenied,
        'isPermanentlyDenied': permissionHandlerStatus.isPermanentlyDenied,
        'diagnosis': _getDiagnosis(manifestConfigured, serviceEnabled,
            permissionHandlerStatus, geolocatorPermission),
      };

      debugPrint('📊 Complete permission status: $status');
      return status;
    } catch (e) {
      debugPrint('💥 Error getting permission status: $e');
      return {'error': e.toString()};
    }
  }

  // Get diagnosis and recommendations
  String _getDiagnosis(bool manifestConfigured, bool serviceEnabled,
      PermissionStatus permissionStatus, LocationPermission geoPermission) {
    if (!manifestConfigured) {
      return 'CRITICAL: Manifest not configured. Run flutter clean, pub get, and rebuild app.';
    }
    if (!serviceEnabled) {
      return 'GPS/Location services disabled. Enable in device settings.';
    }
    if (permissionStatus.isPermanentlyDenied) {
      return 'Permission permanently denied. Open app settings to grant permission.';
    }
    if (permissionStatus.isDenied) {
      return 'Permission denied. App should request permission from user.';
    }
    if (permissionStatus.isGranted &&
        geoPermission == LocationPermission.denied) {
      return 'Permission handler says granted but Geolocator says denied. Possible sync issue.';
    }
    if (permissionStatus.isGranted &&
        (geoPermission == LocationPermission.whileInUse ||
            geoPermission == LocationPermission.always)) {
      return 'All permissions granted. Location should work normally.';
    }
    return 'Unknown state. Check individual permission statuses.';
  }

  // Open app settings for location permission
  Future<bool> openLocationSettings() async {
    try {
      debugPrint('🔧 Opening app settings for location permission...');
      return await openAppSettings();
    } catch (e) {
      debugPrint('💥 Error opening app settings: $e');
      return false;
    }
  }

  // Request location permission with enhanced handling and manifest error detection
  Future<bool> _requestLocationPermission() async {
    try {
      debugPrint('🔍 Starting comprehensive location permission check...');

      // Step 0: Pre-check for manifest issues by testing Geolocator directly
      try {
        debugPrint('🧪 Testing Geolocator manifest configuration...');
        final testPermission = await Geolocator.checkPermission();
        debugPrint('✅ Geolocator manifest test passed: $testPermission');
      } catch (e) {
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage
            .contains('no location permissions are defined in the manifest')) {
          debugPrint(
              '🚨 CRITICAL: Manifest permissions not configured properly!');
          debugPrint('🔧 SOLUTION REQUIRED:');
          debugPrint('   1. Stop the app completely');
          debugPrint('   2. Run: flutter clean');
          debugPrint('   3. Run: flutter pub get');
          debugPrint('   4. Rebuild and reinstall the app');
          debugPrint(
              '   5. Make sure AndroidManifest.xml has location permissions');

          // Return false immediately - this is a build configuration issue
          return false;
        }
      }

      // Step 1: Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('📍 Location services enabled: $serviceEnabled');

      if (!serviceEnabled) {
        debugPrint(
            '❌ Location services are disabled. Attempting to prompt user...');
        // Try to prompt user to enable location services
        try {
          await Geolocator.openLocationSettings();
          debugPrint('📱 Opened location settings for user');

          // Wait a moment and check again
          await Future.delayed(const Duration(seconds: 2));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          debugPrint('📍 Location services after settings: $serviceEnabled');

          if (!serviceEnabled) {
            debugPrint(
                '❌ Location services still disabled after settings prompt');
            return false;
          }
        } catch (e) {
          debugPrint('⚠️ Could not open location settings: $e');
          return false;
        }
      }

      // Step 2: Use multiple permission request strategies
      debugPrint('🔐 Trying multiple permission request strategies...');

      // Strategy 1: permission_handler first
      try {
        debugPrint('🔐 Strategy 1: Using permission_handler...');
        PermissionStatus permissionStatus = await Permission.location.status;
        debugPrint('🔐 Permission handler initial status: $permissionStatus');

        if (permissionStatus.isDenied) {
          debugPrint('🔒 Requesting permission with permission_handler...');
          permissionStatus = await Permission.location.request();
          debugPrint('🔐 Permission after request: $permissionStatus');
        }

        if (permissionStatus.isGranted) {
          debugPrint('✅ Permission granted via permission_handler');
          return true;
        } else if (permissionStatus.isPermanentlyDenied) {
          debugPrint(
              '❌ Permission permanently denied. Opening app settings...');
          try {
            await openAppSettings();
            debugPrint('📱 Opened app settings for user');

            // Wait and check again
            await Future.delayed(const Duration(seconds: 3));
            permissionStatus = await Permission.location.status;
            debugPrint('🔐 Permission after app settings: $permissionStatus');

            if (permissionStatus.isGranted) {
              debugPrint('✅ Permission granted after app settings');
              return true;
            }
          } catch (e) {
            debugPrint('⚠️ Could not open app settings: $e');
          }
        }
      } catch (e) {
        debugPrint('⚠️ permission_handler strategy failed: $e');
      }

      // Strategy 2: Geolocator direct request
      try {
        debugPrint('🔐 Strategy 2: Using Geolocator direct request...');
        LocationPermission geoPermission = await Geolocator.checkPermission();
        debugPrint('🔐 Geolocator initial permission: $geoPermission');

        if (geoPermission == LocationPermission.denied) {
          debugPrint('🔒 Requesting permission with Geolocator...');
          geoPermission = await Geolocator.requestPermission();
          debugPrint('🔐 Geolocator permission after request: $geoPermission');
        }

        if (geoPermission == LocationPermission.whileInUse ||
            geoPermission == LocationPermission.always) {
          debugPrint('✅ Permission granted via Geolocator');
          return true;
        } else if (geoPermission == LocationPermission.deniedForever) {
          debugPrint('❌ Geolocator permission denied forever');
          return false;
        }
      } catch (e) {
        debugPrint('⚠️ Geolocator strategy failed: $e');

        // Check if this is the manifest error again
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage
            .contains('no location permissions are defined in the manifest')) {
          debugPrint(
              '🚨 MANIFEST ERROR CONFIRMED: App needs complete rebuild!');
          return false;
        }
      }

      debugPrint('❌ All permission strategies failed');
      return false;
    } catch (e) {
      debugPrint('💥 Location permission error: $e');
      return false;
    }
  }

  // Get current location with enhanced error handling for manifest issues
  Future<Position?> _getCurrentLocation() async {
    try {
      debugPrint('📍 Getting current location...');

      // Try with high accuracy first
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );

        _currentPosition = position;
        notifyListeners();

        debugPrint(
            '✅ Location obtained: ${position.latitude}, ${position.longitude}');
        return position;
      } catch (e) {
        final errorMessage = e.toString().toLowerCase();

        if (errorMessage
            .contains('no location permissions are defined in the manifest')) {
          debugPrint('🚨 MANIFEST ERROR DETECTED: $e');
          debugPrint(
              '🔧 This error indicates the app needs to be rebuilt or cleaned');
          debugPrint('💡 Suggested solutions:');
          debugPrint('   1. Run: flutter clean');
          debugPrint('   2. Run: flutter pub get');
          debugPrint('   3. Rebuild the app');

          // Try alternative approach with different settings
          try {
            debugPrint('🔄 Trying alternative location request...');
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium,
              timeLimit: const Duration(seconds: 15),
            );

            _currentPosition = position;
            notifyListeners();

            debugPrint(
                '✅ Location obtained with alternative method: ${position.latitude}, ${position.longitude}');
            return position;
          } catch (e2) {
            debugPrint('💥 Alternative method also failed: $e2');
            throw Exception(
                'MANIFEST_PERMISSIONS_ERROR: Location permissions not properly configured. Please rebuild the app.');
          }
        } else {
          debugPrint('💥 Other location error: $e');
          throw e;
        }
      }
    } catch (e) {
      debugPrint('💥 Get current location error: $e');
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
          // Location updates are sent automatically every 3 minutes by timer
          // No immediate sending to avoid excessive API calls
          debugPrint(
              '📍 Position updated: ${position.latitude}, ${position.longitude}');
        },
        onError: (error) {
          debugPrint('Location stream error: $error');
        },
      );

      // Note: Periodic updates are handled by _startLocationUpdateTimer()
      // which is called separately when driver goes online

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
    _stopLocationUpdateTimer(); // Stop the 3-minute timer
    _isTracking = false;
    debugPrint('📍 Location tracking stopped');
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

  // Manual location send for testing with enhanced error handling
  Future<ApiResponse<Map<String, dynamic>>> sendLocationManually() async {
    try {
      debugPrint('📍 Manual location send requested...');

      // Check and request location permission
      debugPrint('🔐 Checking location permissions...');
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        // Check specific reason for permission failure
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        final permission = await Geolocator.checkPermission();

        String errorMessage;
        if (!serviceEnabled) {
          errorMessage = 'يرجى تفعيل خدمات الموقع (GPS) في إعدادات الهاتف';
        } else if (permission == LocationPermission.deniedForever) {
          errorMessage = 'يرجى منح صلاحية الموقع من إعدادات التطبيق';
        } else {
          errorMessage = 'لا توجد صلاحية للوصول للموقع الجغرافي';
        }

        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
        );
      }

      debugPrint('✅ Location permission granted, getting current location...');

      // Get current location
      final position = await _getCurrentLocation();
      if (position == null) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'فشل في الحصول على الموقع الحالي. تأكد من تفعيل GPS',
        );
      }

      debugPrint(
          '📍 Location obtained: ${position.latitude}, ${position.longitude}');
      debugPrint('🎯 Accuracy: ${position.accuracy}m');

      // Send location to server
      debugPrint('📤 Sending location to server...');
      await _sendLocationUpdate(position);

      debugPrint('✅ Manual location sent successfully!');

      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: 'تم إرسال الموقع بنجاح',
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('💥 Manual location send error: $e');

      // Provide more specific error messages
      String errorMessage = 'خطأ في إرسال الموقع';
      if (e.toString().contains('location service')) {
        errorMessage = 'خدمة الموقع غير متاحة. يرجى تفعيل GPS';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'لا توجد صلاحية للوصول للموقع';
      } else if (e.toString().contains('network')) {
        errorMessage = 'خطأ في الاتصال بالخادم';
      }

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: '$errorMessage: $e',
      );
    }
  }

  // Update driver status (only online status - free is controlled by system)
  Future<ApiResponse<void>> updateDriverStatus({
    required bool online,
    String? status,
  }) async {
    try {
      final response = await _apiService.post<void>(
        AppConfig.updateStatusEndpoint,
        body: {
          'online': online,
          if (status != null) 'status': status,
        },
        fromJson: null,
      );

      if (response.isSuccess) {
        _isOnline = online;
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
    final response = await updateDriverStatus(online: true);
    if (response.isSuccess) {
      await startTracking();
      _startLocationUpdateTimer();
    }
    return response;
  }

  // Go offline
  Future<ApiResponse<void>> goOffline() async {
    stopTracking(); // This will also stop the location update timer
    return await updateDriverStatus(online: false);
  }

  // Start location update timer (every 3 minutes)
  void _startLocationUpdateTimer() {
    _stopLocationUpdateTimer(); // Stop any existing timer

    _locationUpdateTimer = Timer.periodic(
      const Duration(minutes: 3), // تحديث كل 3 دقائق
      (timer) async {
        if (_isOnline && _currentPosition != null) {
          await _sendLocationUpdate(_currentPosition!);
          debugPrint('🕐 Location sent automatically (3-minute interval)');
        } else {
          debugPrint(
              '⏸️ Skipping location update - driver offline or no position');
        }
      },
    );

    debugPrint('⏰ Location update timer started (3-minute intervals)');
  }

  // Stop location update timer
  void _stopLocationUpdateTimer() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    debugPrint('Location update timer stopped');
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

  // Open device location settings (GPS settings)
  Future<void> openDeviceLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Dispose
  @override
  void dispose() {
    stopTracking(); // This will also stop the location update timer
    super.dispose();
  }
}
