import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../Helpers/LocationHelper.dart';
import '../models/api_response.dart';

class LocationController extends GetxController {
  final LocationHelper _locationHelper = LocationHelper();

  // Reactive state
  final Rxn<Position> currentPosition = Rxn<Position>();
  final RxBool isTracking = false.obs;
  final RxBool isOnline = false.obs;
  final RxBool isFree = true.obs;

  StreamSubscription<Position>? _positionStream;
  Timer? _locationUpdateTimer;

  @override
  void onInit() {
    super.onInit();
    // getCurrentStatus();
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  // Sync with user data
  void syncWithDriverData({required bool online, required bool free}) {
    isOnline.value = online;
    isFree.value = free;

    if (online) {
      startTracking();
    } else {
      stopTracking();
    }
  }

  // Get current status from server
  Future<void> fetchCurrentStatus() async {
    try {
      final response = await _locationHelper.getCurrentStatus();
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        if (data['status'] != null) {
          isOnline.value = data['status']['online'] ?? false;
          isFree.value = data['status']['free'] ?? true;
        }

        if (isOnline.value) {
          startTracking();
        }
      }
    } catch (e) {
      debugPrint('Error fetching location status: $e');
    }
  }

  // Request permission
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.unableToDetermine) {
      // Show disclosure dialog before requesting permission
      final bool userAccepted = await _showDisclosureDialog();
      if (!userAccepted) return false;

      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle permanently denied
      return false;
    }

    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  Future<bool> _showDisclosureDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('locationDisclosureTitle'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text('locationDisclosureMessage'.tr),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('deny'.tr, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: Text('accept'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  // Start tracking
  Future<bool> startTracking() async {
    if (isTracking.value) return true;

    bool hasPermission = await requestPermission();
    if (!hasPermission) return false;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      (Position position) {
        currentPosition.value = position;
        debugPrint('📍 Live position: ${position.latitude}, ${position.longitude}');
      },
      onError: (e) => debugPrint('Location stream error: $e'),
    );

    _startLocationUpdateTimer();
    isTracking.value = true;
    return true;
  }

  // Stop tracking
  void stopTracking() {
    _positionStream?.cancel();
    _stopLocationUpdateTimer();
    isTracking.value = false;
  }

  // Go Online
  Future<ApiResponse<void>> goOnline() async {
    final res = await _locationHelper.updateDriverStatus(online: true);
    if (res.isSuccess) {
      isOnline.value = true;
      await startTracking();
    }
    return res;
  }

  // Go Offline
  Future<ApiResponse<void>> goOffline() async {
    final res = await _locationHelper.updateDriverStatus(online: false);
    if (res.isSuccess) {
      isOnline.value = false;
      stopTracking();
    }
    return res;
  }

  // Manual update
  Future<ApiResponse<Map<String, dynamic>>> sendLocationManually() async {
    try {
      bool hasPermission = await requestPermission();
      if (!hasPermission) return ApiResponse(success: false, message: 'الصلاحية مطلوبة');

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
        }
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  void _startLocationUpdateTimer() {
    _stopLocationUpdateTimer();
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 3), (timer) async {
      if (isOnline.value && currentPosition.value != null) {
        await _locationHelper.updateLocation(currentPosition.value!);
      }
    });
  }

  void _stopLocationUpdateTimer() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }
}
