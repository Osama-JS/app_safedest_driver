import 'package:get/get.dart';
import 'package:safedest_driver/services/api_service.dart';
import 'package:safedest_driver/shared_prff.dart';
import 'package:safedest_driver/Globals/global.dart' as globals;
import 'package:safedest_driver/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:safedest_driver/Controllers/AuthController.dart';
import 'package:safedest_driver/Controllers/SettingsController.dart';

import 'package:safedest_driver/Controllers/TaskController.dart';
import 'package:safedest_driver/Controllers/WalletController.dart';
import 'package:safedest_driver/Controllers/NotificationController.dart';
import 'package:safedest_driver/Controllers/LocationController.dart';
import 'package:safedest_driver/Controllers/TaskAdsController.dart';

class InitialService extends GetxService {
  Future<InitialService> init() async {
    debugPrint('🚀 Initializing InitialService...');

    // Initialize SharedPreferences helpers
    await Selected_Language.init();
    await Theme_pref.init();
    await Token_pref.init();
    await User_pref.init();
    await Bool_pref.init();

    // Initialize ApiService
    final api = ApiService();
    await api.initialize();

    // Register Core Controllers
    Get.put(SettingsController());
    Get.put(AuthController());

    // Register Business Controllers
    Get.put(TaskController());
    Get.put(WalletController());
    Get.put(NotificationController());
    Get.put(LocationController());
    Get.put(TaskAdsController());

    // Set global variables from storage
    _loadGlobals();

    debugPrint('✅ InitialService initialized successfully');
    return this;
  }

  void _loadGlobals() {
    globals.baseUrl = AppConfig.baseUrl; // Using AppConfig instead of hardcoded
    globals.token = Token_pref.getToken();

    // We can load more from User_pref if needed later
    // For now this is enough for Phase 1
  }
}
