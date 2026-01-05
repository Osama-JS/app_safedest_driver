import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../Helpers/LocationHelper.dart';
import '../models/api_response.dart';
import '../screens/settings/location_disclosure_screen.dart';
import '../shared_prff.dart';


enum GoOnlineResult {
  success,
  disclosureDenied,
  permissionDenied,
  serviceDisabled,
  serverError,
}

class LocationController extends GetxController {
  final LocationHelper _locationHelper = LocationHelper();



  // Reactive state
  final Rxn<Position> currentPosition = Rxn<Position>();
  final RxBool isTracking = false.obs;
  final RxBool isOnline = false.obs;
  final RxBool isFree = true.obs;

  StreamSubscription<Position>? _positionStream;
  Timer? _locationUpdateTimer;

  // Disclosure accepted?
  final RxBool hasAcceptedDisclosure = false.obs;

  static const String _disclosureKey = 'location_disclosure_accepted';

  @override
  void onInit() {
    super.onInit();

    // IMPORTANT: no "!" here to avoid crash on first launch
    hasAcceptedDisclosure.value = Bool_pref.getBool(_disclosureKey) ?? false;
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  /// Navigates to LocationDisclosureScreen (full screen), no dialogs.
  /// Returns true only if user accepted.
  Future<bool> ensureDisclosureAccepted() async {
    if (hasAcceptedDisclosure.value) return true;

    final accepted = await Get.to<bool>(() => const LocationDisclosureScreen());

    if (accepted == true) {
      await Bool_pref.setBool(_disclosureKey, true);
      hasAcceptedDisclosure.value = true;
      return true;
    }
    return false;
  }

  /// Requests location permissions from OS.
  /// For background tracking you typically need "always".
  Future<bool> requestBackgroundPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('permission(before): $permission');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint('permission(after request1): $permission');
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    // كثير من الأجهزة تعطي whileInUse فقط
    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
      debugPrint('permission(after request2): $permission');
    }

    if (permission == LocationPermission.always) return true;

    // إن لم يصل always، غالبًا يحتاج Settings
    await Geolocator.openAppSettings();
    permission = await Geolocator.checkPermission();
    debugPrint('permission(after settings): $permission');

    return permission == LocationPermission.always;
  }

  /// Start tracking (does NOT navigate by default).
  /// Use promptDisclosure=true ONLY from UI actions.
  Future<bool> startTracking({bool promptDisclosure = false}) async {
    if (isTracking.value) return true;

    // Block if disclosure not accepted
    if (!hasAcceptedDisclosure.value) {
      if (!promptDisclosure) return false;

      final okDisclosure = await ensureDisclosureAccepted();
      if (!okDisclosure) return false;
    }

    final okPerm = await requestBackgroundPermission();
    if (!okPerm) return false;

    late final LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: 'bg_location_title'.tr,
          notificationText: 'bg_location_body'.tr,
          notificationIcon: const AndroidResource(name: 'ic_launcher'),
          setOngoing: true,
          enableWakeLock: true,
        ),
      );
    } else {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    }

    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
          (position) {
        currentPosition.value = position;
      },
      onError: (e) {
        debugPrint('Location stream error: $e');
      },
    );

    _startLocationUpdateTimer();
    isTracking.value = true;
    return true;
  }

  void stopTracking() {
    debugPrint('🛑 Stopping location tracking...');
    _positionStream?.cancel();
    _positionStream = null;
    _stopLocationUpdateTimer();
    isTracking.value = false;
  }

  Future<GoOnlineResult> tryGoOnline() async {
    // 1) disclosure
    final okDisclosure = await ensureDisclosureAccepted();
    if (!okDisclosure) return GoOnlineResult.disclosureDenied;

    // 2) GPS service
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return GoOnlineResult.serviceDisabled;

    // 3) permissions
    final okPerm = await requestBackgroundPermission();
    if (!okPerm) return GoOnlineResult.permissionDenied;

    // 4) server
    final res = await _locationHelper.updateDriverStatus(online: true);
    if (!res.isSuccess) {
      isOnline.value = false;
      return GoOnlineResult.serverError;
    }

    // 5) start tracking
    isOnline.value = true;
    final started = await startTracking(promptDisclosure: false);
    if (!started) {
      isOnline.value = false;
      return GoOnlineResult.permissionDenied;
    }

    return GoOnlineResult.success;
  }

  Future<ApiResponse<void>> goOnline() async {
    final res = await _locationHelper.updateDriverStatus(online: true);

    if (res.isSuccess) {
      isOnline.value = true;

      // disclosure + permission already handled in tryGoOnline()
      // but if goOnline() called elsewhere, do not navigate:
      await startTracking(promptDisclosure: false);
    }

    return res;
  }

  Future<ApiResponse<void>> goOffline() async {
    final res = await _locationHelper.updateDriverStatus(online: false);

    if (res.isSuccess) {
      isOnline.value = false;
      stopTracking();
    }

    return res;
  }

  /// Sync from user data (do not navigate from here).
  /// If online but disclosure not accepted, we prevent tracking and keep offline locally.
  void syncWithDriverData({required bool online, required bool free}) {
    isFree.value = free;

    if (online) {
      isOnline.value = true;
      if (!hasAcceptedDisclosure.value) {
        // Prevent background start until user explicitly accepts.
        debugPrint('⚠️ Sync: Online but disclosure NOT accepted. Stopping tracking.');
        isOnline.value = false;
        stopTracking();
        return;
      }

      debugPrint('✅ Sync: Online. Starting tracking if not already active.');
      if (!isTracking.value) {
        startTracking(promptDisclosure: false);
      }
    } else {
      debugPrint('ℹ️ Sync: Offline. Stopping tracking.');
      isOnline.value = false;
      stopTracking();
    }
  }

  /// Fetch current status from server (do not navigate).
  Future<void> fetchCurrentStatus() async {
    try {
      final response = await _locationHelper.getCurrentStatus();

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final status = data['status'];

        if (status != null) {
          final online = status['online'] ?? false;
          final free = status['free'] ?? true;

          // Apply safely without navigation
          syncWithDriverData(online: online, free: free);
        }
      }
    } catch (e) {
      debugPrint('Error fetching location status: $e');
    }
  }

  /// Manual one-shot update (keeps your logic, but no disclosure navigation here)
  Future<ApiResponse<Map<String, dynamic>>> sendLocationManually() async {
    try {
      final okDisclosure = hasAcceptedDisclosure.value;
      if (!okDisclosure) {
        return ApiResponse(success: false, message: 'يجب قبول شاشة التوضيح أولاً');
      }

      final okPerm = await requestBackgroundPermission();
      if (!okPerm) {
        return ApiResponse(success: false, message: 'الصلاحية مطلوبة');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      currentPosition.value = pos;
      await _locationHelper.updateLocation(pos);

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
      return ApiResponse(success: false, message: e.toString());
    }
  }

  void _startLocationUpdateTimer() {
    _stopLocationUpdateTimer();

    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 3), (timer) async {
      if (isOnline.value && currentPosition.value != null) {
        try {
          await _locationHelper.updateLocation(currentPosition.value!);
        } catch (e) {
          debugPrint('Timer updateLocation error: $e');
        }
      }
    });
  }

  void _stopLocationUpdateTimer() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }
}
