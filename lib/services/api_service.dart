import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../shared_prff.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();
  String? _authToken;

  // Headers
  Map<String, String> get _baseHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': '${AppConfig.appName}/${AppConfig.appVersion}',
      };

  Map<String, String> get _authHeaders => {
        ..._baseHeaders,
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // Initialize service
  Future<void> initialize() async {
    _authToken = Token_pref.getToken();
  }

  // Set auth token
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await Token_pref.setToken(token);

    // Also save to SecureStorage for fallback/consistency
    await _storage.write(key: AppConfig.tokenKey, value: token);

    debugPrint('Auth token saved to both SharedPreferences and SecureStorage');
  }

  // Clear auth token
  Future<void> clearAuthToken() async {
    _authToken = null;
    await Token_pref.removeToken();
    await _storage.delete(key: AppConfig.tokenKey);
  }

  // Get auth token
  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null;

  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = requiresAuth ? _authHeaders : _baseHeaders;

      final response = await http
          .get(uri, headers: headers)
          .timeout(Duration(seconds: AppConfig.requestTimeout));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = requiresAuth ? _authHeaders : _baseHeaders;

      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(Duration(seconds: AppConfig.requestTimeout));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = requiresAuth ? _authHeaders : _baseHeaders;

      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(Duration(seconds: AppConfig.requestTimeout));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = requiresAuth ? _authHeaders : _baseHeaders;

      final response = await http
          .delete(uri, headers: headers)
          .timeout(Duration(seconds: AppConfig.requestTimeout));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Build URI with query parameters
  Uri _buildUri(String endpoint, Map<String, String>? queryParams) {
    final url = AppConfig.getApiUrl(endpoint);
    final uri = Uri.parse(url);

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }

    return uri;
  }

  // Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      final Map<String, dynamic> jsonData = json.decode(response.body);

      // Add status code to response
      jsonData['status_code'] = response.statusCode;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('API Response Success: ${jsonData['success']}');
        debugPrint('API Response Data: ${jsonData['data']}');
        return ApiResponse<T>.fromJson(jsonData, fromJson);
      } else {
        // Handle authentication errors
        if (response.statusCode == 401) {
          final errorCode = jsonData['error_code'] as String?;
          final action = jsonData['action'] as String?;

          debugPrint(
              'Authentication error detected: $errorCode, action: $action');

          if (action == 'logout' || errorCode == 'TOKEN_INVALID') {
            // Trigger logout in AuthService
            _handleAuthenticationError();
          }
        }

        return ApiResponse<T>(
          success: false,
          message: jsonData['message'] ?? 'Request failed',
          errors: jsonData['errors'],
          errorCode: jsonData['error_code'],
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('API Response Parse Error: $e');
      return ApiResponse<T>(
        success: false,
        message: 'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }

  // Callback for authentication errors
  static Function()? _onAuthenticationError;

  // Set authentication error callback
  static void setAuthenticationErrorCallback(Function() callback) {
    _onAuthenticationError = callback;
  }

  // Handle authentication errors
  void _handleAuthenticationError() {
    debugPrint(
        '🚨 Authentication error detected - clearing token and triggering logout');

    // Clear token immediately
    clearAuthToken();

    // Trigger callback if set
    if (_onAuthenticationError != null) {
      _onAuthenticationError!();
    }
  }

  // Handle errors
  ApiResponse<T> _handleError<T>(dynamic error) {
    String message = 'Network error occurred';

    if (error is SocketException) {
      message = 'No internet connection';
    } else if (error is HttpException) {
      message = 'HTTP error: ${error.message}';
    } else if (error is FormatException) {
      message = 'Invalid response format';
    } else {
      message = error.toString();
    }

    return ApiResponse<T>(
      success: false,
      message: message,
    );
  }

  // Upload file (for future use)
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    File file, {
    Map<String, String>? fields,
    String fieldName = 'file',
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, null);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(_authHeaders);

      // Add file
      request.files
          .add(await http.MultipartFile.fromPath(fieldName, file.path));

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request
          .send()
          .timeout(Duration(seconds: AppConfig.requestTimeout * 2));

      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // PUT request with file upload (using POST with _method=PUT for Laravel compatibility)
  Future<ApiResponse<T>> putWithFile<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, File>? files,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, null);
      final request =
          http.MultipartRequest('POST', uri); // Use POST instead of PUT

      // Add headers
      request.headers.addAll(_authHeaders);

      // Add _method field to simulate PUT request
      request.fields['_method'] = 'PUT';

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }
      }

      // Add body fields
      if (body != null) {
        body.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });
      }

      final streamedResponse = await request
          .send()
          .timeout(Duration(seconds: AppConfig.requestTimeout * 2));

      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // POST request with file upload
  Future<ApiResponse<T>> postWithFile<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, File>? files,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, null);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(_authHeaders);

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }
      }

      // Add body fields
      if (body != null) {
        body.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });
      }

      final streamedResponse = await request
          .send()
          .timeout(Duration(seconds: AppConfig.requestTimeout * 2));

      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Check network connectivity
  Future<bool> checkConnectivity() async {
    try {
      final response = await http
          .get(
            Uri.parse('${AppConfig.baseUrl}/driver/health'),
            headers: _baseHeaders,
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Refresh token (if needed)
  Future<ApiResponse<String>> refreshToken() async {
    if (!isAuthenticated) {
      return ApiResponse<String>(
        success: false,
        message: 'No auth token available',
      );
    }

    final response = await post<String>(
      AppConfig.refreshTokenEndpoint,
      fromJson: (data) => data['token'] as String,
    );

    if (response.isSuccess && response.data != null) {
      await setAuthToken(response.data!);
    }

    return response;
  }

  // Delete account
  Future<ApiResponse<String>> deleteAccount({
    required String password,
    required String confirmation,
  }) async {
    if (!isAuthenticated) {
      return ApiResponse<String>(
        success: false,
        message: 'No auth token available',
      );
    }

    final response = await post<String>(
      AppConfig.deleteAccountEndpoint,
      body: {
        'password': password,
        'confirmation': confirmation,
      },
      fromJson: (data) => data['message'] as String,
    );

    return response;
  }
}
