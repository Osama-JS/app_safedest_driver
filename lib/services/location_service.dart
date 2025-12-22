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
  // Future<bool> initialize() async {
  //   try {
  //     debugPrint('🚀 LocationService: Starting initialization...');
  //     final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     debugPrint('📍 Location services enabled: $serviceEnabled');
  //
  //     final hasPermission = await _requestLocationPermission();
  //     if (!hasPermission) {
  //       debugPrint('⚠️ LocationService: Permission not granted at startup (will request later if needed)');
  //     }
  //
  //     if (hasPermission) {
  //       try {
  //         await _getCurrentLocation();
  //         debugPrint('✅ LocationService: Initial location obtained');
  //       } catch (e) {
  //         debugPrint('⚠️ Could not get initial location: $e');
  //       }
  //     }
  //
  //     debugPrint('✅ LocationService: Initialization completed');
  //     return true;
  //   } catch (e) {
  //     debugPrint('💥 LocationService init error: $e');
  //     return true; // لا نوقف تشغيل التطبيق
  //   }
  // }

  void syncWithDriverData({required bool online, required bool free}) {
    debugPrint('Syncing LocationService: online=$online, free=$free');
    final wasOnline = _isOnline;
    _isOnline = online;
    _isFree = free;

    // if (online && !wasOnline) {
    //   debugPrint('Driver online → starting tracking...');
    //   startTracking();
    //   _startLocationUpdateTimer();
    // } else if (!online && wasOnline) {
    //   debugPrint('Driver offline → stopping tracking...');
    //   stopTracking();
    // }
    notifyListeners();
  }

  // هذه الدالة تُستخدم من الواجهة (مثل SplashScreen) لطلب الصلاحية مرة واحدة فقط
  Future<bool> requestGPSPermissionOnly() async {
    return await _requestLocationPermission();
  }

  // دالة تشخيص مفصلة — بدون استخدام permission_handler
  // Future<Map<String, dynamic>> getDetailedPermissionStatus() async {
  //   try {
  //     bool manifestConfigured = true;
  //     String manifestError = '';
  //
  //     // اختبار Manifest عبر Geolocator فقط
  //     try {
  //       await Geolocator.checkPermission();
  //     } catch (e) {
  //       if (e.toString().toLowerCase().contains('no location permissions are defined in the manifest')) {
  //         manifestConfigured = false;
  //         manifestError = e.toString();
  //       }
  //     }
  //
  //     final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     final geoPermission = manifestConfigured ? await Geolocator.checkPermission() : LocationPermission.denied;
  //
  //     final isGranted = geoPermission == LocationPermission.whileInUse ||
  //         geoPermission == LocationPermission.always;
  //
  //     final status = {
  //       'manifestConfigured': manifestConfigured,
  //       'manifestError': manifestError,
  //       'serviceEnabled': serviceEnabled,
  //       'geolocatorPermission': geoPermission.toString(),
  //       'isGranted': isGranted,
  //       'isDenied': geoPermission == LocationPermission.denied,
  //       'isPermanentlyDenied': geoPermission == LocationPermission.deniedForever,
  //       'diagnosis': _getDiagnosis(manifestConfigured, serviceEnabled, geoPermission),
  //     };
  //
  //     debugPrint('📊 Detailed status: $status');
  //     return status;
  //   } catch (e) {
  //     debugPrint('💥 Error in getDetailedPermissionStatus: $e');
  //     return {'error': e.toString()};
  //   }
  // }
  //
  // String _getDiagnosis(bool manifestConfigured, bool serviceEnabled, LocationPermission permission) {
  //   if (!manifestConfigured) return 'CRITICAL: Manifest not configured. Rebuild app.';
  //   if (!serviceEnabled) return 'GPS disabled. Enable in device settings.';
  //   if (permission == LocationPermission.deniedForever) return 'Permission permanently denied. Open app settings.';
  //   if (permission == LocationPermission.denied) return 'Permission denied. Request again.';
  //   if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
  //     return 'All permissions granted. Location should work.';
  //   }
  //   return 'Unknown state.';
  // }

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
            _currentPosition = Position(
              latitude: lat,
              longitude: lng,
              timestamp: DateTime.now(),
              accuracy: (locationData['accuracy'] as num?)?.toDouble() ?? 0.0,
              altitude: (locationData['altitude'] as num?)?.toDouble() ?? 0.0,
              altitudeAccuracy: (locationData['altitudeAccuracy'] as num?)?.toDouble() ?? 0.0,
              heading: (locationData['heading'] as num?)?.toDouble() ?? 0.0,
              headingAccuracy: (locationData['headingAccuracy'] as num?)?.toDouble() ?? 0.0,
              speed: (locationData['speed'] as num?)?.toDouble() ?? 0.0,
              speedAccuracy: (locationData['speedAccuracy'] as num?)?.toDouble() ?? 0.0,
            );
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
//   Future<ApiResponse<void>> updateFcmToken(String fcmToken, {String? deviceId}) async {
//     try {
//       final response = await _apiService.post<void>(
//         AppConfig.updateFcmTokenEndpoint,
//         body: {
//           'fcm_token': fcmToken,
//           if (deviceId != null) 'device_id': deviceId,
//         },
//         fromJson: null,
//       );
//       return response;
//     } catch (e) {
//       return ApiResponse<void>(
//         success: false,
//         message: 'فشل في تحديث رمز الإشعارات: $e',
//       );
//     }
//   }

  // الدالة الوحيدة لطلب الصلاحية — تعتمد على Geolocator فقط
  Future<bool> _requestLocationPermission() async {
    try {
      // 1. تحقق من حالة الصلاحية الحالية
      LocationPermission permission = await Geolocator.checkPermission();
      // 2. إذا كانت ممنوحة، نعود true فورًا
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        return true;
      }

      // 3. إذا كانت غير محددة أو مرفوضة، اطلبها
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        permission = await Geolocator.requestPermission();
      }

      // 4. إذا رُفضت بشكل دائم، لا نطلب فتح الإعدادات هنا (يتم من الواجهة)
      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      // 5. تحقق مما إذا تم منحها الآن
      return permission == LocationPermission.whileInUse || permission == LocationPermission.always;

    } catch (e) {
      debugPrint('💥 _requestLocationPermission error: $e');
      return false;
    }
  }

  // إزالة دالة _askUserToOpenSettings بالكامل — لا تُستخدم من الخدمة

  Future<Position?> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      _currentPosition = position;
      notifyListeners();
      return position;
    } catch (e) {
      debugPrint('💥 Failed to get current location: $e');
      return null;
    }
  }

  Future<bool> startTracking() async {
    if (_isTracking) return true;

    final hasPermission = await _requestLocationPermission();
    if (!hasPermission) return false;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    _startLocationUpdateTimer();
    _positionStream = Geolocator.getPositionStream(locationSettings: settings).listen(
          (Position position) {
        _currentPosition = position;
        notifyListeners();
        debugPrint('📍 Live position: ${position.latitude}, ${position.longitude}');
      },
      onError: (error) {
        debugPrint('Location stream error: $error');
      },
    );

    _isTracking = true;
    notifyListeners();
    return true;
  }

  void stopTracking() {
    _positionStream?.cancel();
    _stopLocationUpdateTimer();
    _isTracking = false;
    notifyListeners();
  }

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
      debugPrint('Send location error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> sendLocationManually() async {
    try {
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        final perm = await Geolocator.checkPermission();

        String msg;
        if (!serviceEnabled) {
          msg = 'يرجى تفعيل GPS في إعدادات الجهاز';
        } else if (perm == LocationPermission.deniedForever) {
          msg = 'الصلاحية مرفوضة دائمًا. افتح إعدادات التطبيق وفعّل الموقع';
        } else {
          msg = 'الصلاحية مطلوبة للوصول إلى الموقع';
        }
        return ApiResponse(success: false, message: msg);
      }

      final pos = await _getCurrentLocation();
      if (pos == null) {
        return ApiResponse(success: false, message: 'فشل في تحديد الموقع. تأكد من تفعيل GPS');
      }

      await _sendLocationUpdate(pos);
      return ApiResponse(
        success: true,
        message: 'تم إرسال الموقع بنجاح',
        data: {
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'accuracy': pos.accuracy,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'خطأ: $e');
    }
  }

  Future<ApiResponse<void>> updateDriverStatus({required bool online, String? status}) async {
    try {
      final response = await _apiService.post<void>(
        AppConfig.updateStatusEndpoint,
        body: {'online': online, if (status != null) 'status': status},
        fromJson: null,
      );
      if (response.isSuccess) {
        _isOnline = online;
        notifyListeners();
      }
      return response;
    } catch (e) {
      return ApiResponse(success: false, message: 'فشل تحديث الحالة: $e');
    }
  }

  Future<ApiResponse<void>> goOnline() async {
    final res = await updateDriverStatus(online: true);
    if (res.isSuccess) {
      await startTracking();
      // _startLocationUpdateTimer();
    }
    return res;
  }

  Future<ApiResponse<void>> goOffline() async {
    stopTracking();
    return await updateDriverStatus(online: false);
  }

  void _startLocationUpdateTimer() {
    _stopLocationUpdateTimer();
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 3), (timer) async {
      if (_isOnline && _currentPosition != null) {
        await _sendLocationUpdate(_currentPosition!);
        debugPrint('🕐 Auto location sent (3-min interval)');
      }
    });
  }

  void _stopLocationUpdateTimer() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }
  //
  // double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
  //   return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  // }
  //
  // double? getDistanceToLocation(double latitude, double longitude) {
  //   if (_currentPosition == null) return null;
  //   return calculateDistance(_currentPosition!.latitude, _currentPosition!.longitude, latitude, longitude);
  // }
  //
  // Future<bool> isLocationServiceEnabled() async {
  //   return await Geolocator.isLocationServiceEnabled();
  // }
  //
  // Future<void> openDeviceLocationSettings() async {
  //   await Geolocator.openLocationSettings();
  // }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }



  // Future<bool> startTracking2() async {
  //   if (_isTracking) return true;
  //
  //   final hasPermission = await _requestLocationPermission();
  //   if (!hasPermission) return false;
  //
  //   const settings = LocationSettings(
  //     accuracy: LocationAccuracy.high,
  //     timeLimit: Duration(minutes: 3)
  //     // distanceFilter: 10,
  //   );
  //
  //   _positionStream = Geolocator.getPositionStream(locationSettings: settings).listen(
  //         (Position position) {
  //       _currentPosition = position;
  //       notifyListeners();
  //       if (_isOnline && _currentPosition != null) {
  //          _sendLocationUpdate(_currentPosition!);
  //         debugPrint('🕐 Auto location sent (3-min interval)');
  //       }
  //       debugPrint('📍 Live position: ${position.latitude}, ${position.longitude}');
  //     },
  //     onError: (error) {
  //       debugPrint('Location stream error: $error');
  //     },
  //   );
  //
  //   _isTracking = true;
  //   notifyListeners();
  //   return true;
  // }
  //
  // void stopTracking2() {
  //   _positionStream?.cancel();
  //   // _stopLocationUpdateTimer();
  //   _isTracking = false;
  //   notifyListeners();
  // }

}
