library safedest_driver.globals;

import 'package:get/get.dart';

// User data
Map<String, dynamic> user = {};

// Dashboard index
int dashboardIndex = 0;

// Base URL (will be set from AppConfig)
String baseUrl = '';

// Token
String? token;

// Notification token
String? notificationToken;

// User information
String userName = '';
int userId = 0;

// Location
double lat = 0.0;
double lng = 0.0;

// Tab index
int tabIndex = 0;

// Navigation flags
bool fromHome = false;
