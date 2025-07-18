import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';

  // Register new user
  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String? displayName,
    String? bio,
    bool isDiscoverable = true,
  }) async {
    try {
      final response = await ApiClient.post('/api/auth/register/', body: {
        'username': username,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        'display_name': displayName ?? '',
        'bio': bio ?? '',
        'is_discoverable': isDiscoverable,
      });

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        // Save tokens
        final tokens = data['tokens'] as Map<String, dynamic>;
        await ApiClient.saveTokens(
          tokens['access'],
          tokens['refresh'],
        );

        // Save user data
        final userData = data['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        await _saveCurrentUser(user);

        return AuthResult(
          success: true,
          message: data['message'] ?? 'Registration successful',
          user: user,
        );
      } else {
        return AuthResult(
          success: false,
          message: response.message,
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  // Login user
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post('/api/auth/login/', body: {
        'username': username,
        'password': password,
      });

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        // Save tokens
        final tokens = data['tokens'] as Map<String, dynamic>;
        await ApiClient.saveTokens(
          tokens['access'],
          tokens['refresh'],
        );

        // Save user data
        final userData = data['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        await _saveCurrentUser(user);

        return AuthResult(
          success: true,
          message: data['message'] ?? 'Login successful',
          user: user,
        );
      } else {
        return AuthResult(
          success: false,
          message: response.message,
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      final refreshToken = await ApiClient.getRefreshToken();
      
      if (refreshToken != null) {
        await ApiClient.post('/api/auth/logout/', body: {
          'refresh_token': refreshToken,
        });
      }

      // Clear local data
      await ApiClient.clearTokens();
      await _clearCurrentUser();
      
      return true;
    } catch (e) {
      // Even if API call fails, clear local data
      await ApiClient.clearTokens();
      await _clearCurrentUser();
      return true;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await ApiClient.getAccessToken();
    final user = await getCurrentUser();
    return token != null && user != null;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userData = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get user profile from API
  Future<User?> fetchUserProfile() async {
    try {
      final response = await ApiClient.get('/api/auth/profile/');
      
      if (response.success && response.data != null) {
        final user = User.fromJson(response.data as Map<String, dynamic>);
        await _saveCurrentUser(user);
        return user;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<AuthResult> updateProfile({
    String? email,
    String? displayName,
    String? bio,
    String? avatar,
    bool? isDiscoverable,
  }) async {
    try {
      final body = <String, dynamic>{};
      
      if (email != null) body['email'] = email;
      if (displayName != null) body['display_name'] = displayName;
      if (bio != null) body['bio'] = bio;
      if (avatar != null) body['avatar'] = avatar;
      if (isDiscoverable != null) body['is_discoverable'] = isDiscoverable;

      final response = await ApiClient.patch('/api/auth/profile/', body: body);

      if (response.success && response.data != null) {
        final user = User.fromJson(response.data as Map<String, dynamic>);
        await _saveCurrentUser(user);
        
        return AuthResult(
          success: true,
          message: 'Profile updated successfully',
          user: user,
        );
      } else {
        return AuthResult(
          success: false,
          message: response.message,
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Profile update failed: ${e.toString()}',
      );
    }
  }

  // Search users by User ID
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await ApiClient.get('/api/auth/search/?q=$query');
      
      if (response.success && response.data != null) {
        final List<dynamic> usersData = response.data as List<dynamic>;
        return usersData.map((userData) => User.fromJson(userData as Map<String, dynamic>)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  // Private methods
  Future<void> _saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<void> _clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}

class AuthResult {
  final bool success;
  final String message;
  final User? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}
