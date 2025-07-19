import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Dynamic base URL based on platform
  static String get baseUrl {
    if (kIsWeb) {
      // Web platform
      return 'https://tasksphere-mobile-backend.onrender.com';
    } else if (Platform.isAndroid) {
      // Android emulator
      return 'https://tasksphere-mobile-backend.onrender.com';
    } else if (Platform.isIOS) {
      // iOS simulator
      return 'https://tasksphere-mobile-backend.onrender.com';
    } else {
      // Desktop platforms
      return 'https://tasksphere-mobile-backend.onrender.com';
    }
  }

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Headers
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<Map<String, String>> get _authHeaders async {
    final token = await _storage.read(key: 'access_token');
    final headers = Map<String, String>.from(_headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // GET request
  static Future<ApiResponse> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _authHeaders;

      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        data: null,
      );
    }
  }

  // POST request
  static Future<ApiResponse> post(String endpoint,
      {Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _authHeaders;

      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        data: null,
      );
    }
  }

  // PATCH request
  static Future<ApiResponse> patch(String endpoint,
      {Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _authHeaders;

      final response = await http.patch(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        data: null,
      );
    }
  }

  // DELETE request
  static Future<ApiResponse> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _authHeaders;

      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        data: null,
      );
    }
  }

  // Handle HTTP response
  static ApiResponse _handleResponse(http.Response response) {
    try {
      final data = response.body.isNotEmpty ? json.decode(response.body) : null;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          message: 'Success',
          data: data,
          statusCode: response.statusCode,
        );
      } else {
        String message = 'Request failed';
        if (data != null && data is Map<String, dynamic>) {
          if (data.containsKey('message')) {
            message = data['message'];
          } else if (data.containsKey('error')) {
            message = data['error'];
          } else if (data.containsKey('detail')) {
            message = data['detail'];
          }
        }

        return ApiResponse(
          success: false,
          message: message,
          data: data,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to parse response: ${e.toString()}',
        data: null,
        statusCode: response.statusCode,
      );
    }
  }

  // Token management
  static Future<void> saveTokens(
      String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}
