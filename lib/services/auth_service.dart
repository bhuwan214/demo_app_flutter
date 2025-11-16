import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to manage authentication tokens and user data
class AuthService {
  // Keys for SharedPreferences
  static const String _tokenKey = 'api_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // In-memory fallback storage (for when SharedPreferences fails)
  static String? _memoryToken;
  static Map<String, dynamic>? _memoryUserData;
  static bool _memoryIsLoggedIn = false;
  static bool _useMemoryFallback = false;

  /// Get SharedPreferences instance with error handling
  static Future<SharedPreferences?> _getPrefs() async {
    if (_useMemoryFallback) {
      return null; // Skip SharedPreferences if we know it's not working
    }

    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      print('⚠️ SharedPreferences not available, using in-memory storage');
      _useMemoryFallback = true;
      return null;
    }
  }

  /// Save authentication token
  static Future<void> saveToken(String token) async {
    _memoryToken = token;
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString(_tokenKey, token);
      }
    } catch (e) {
      print('Error saving token to storage: $e');
    }
  }

  /// Get authentication token
  static Future<String?> getToken() async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        return prefs.getString(_tokenKey);
      }
    } catch (e) {
      print('Error getting token from storage: $e');
    }
    // Fallback to memory
    return _memoryToken;
  }

  /// Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    _memoryUserData = userData; // Always save in memory
    _memoryIsLoggedIn = true;
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString(_userDataKey, jsonEncode(userData));
        await prefs.setBool(_isLoggedInKey, true);
      }
    } catch (e) {
      print('Error saving user data to storage: $e');
    }
  }

  /// Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        final userDataString = prefs.getString(_userDataKey);
        if (userDataString != null) {
          return jsonDecode(userDataString) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('Error getting user data from storage: $e');
    }
    // Fallback to memory
    return _memoryUserData;
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        return prefs.getBool(_isLoggedInKey) ?? false;
      }
    } catch (e) {
      print('Error checking login status from storage: $e');
    }
    // Fallback to memory
    return _memoryIsLoggedIn;
  }

  /// Clear all authentication data (logout)
  static Future<void> clearAuth() async {
    // Clear memory
    _memoryToken = null;
    _memoryUserData = null;
    _memoryIsLoggedIn = false;

    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.remove(_tokenKey);
        await prefs.remove(_userDataKey);
        await prefs.setBool(_isLoggedInKey, false);
      }
    } catch (e) {
      print('Error clearing auth from storage: $e');
    }
  }

  /// Get authenticated user's ID
  static Future<int?> getUserId() async {
    final userData = await getUserData();
    return userData?['id'];
  }

  /// Get authenticated user's full name
  static Future<String?> getFullName() async {
    final userData = await getUserData();
    if (userData != null) {
      final firstName = userData['first_name'] ?? '';
      final lastName = userData['last_name'] ?? '';
      return '$firstName $lastName'.trim();
    }
    return null;
  }

  /// Get authenticated user's mobile number
  static Future<String?> getMobileNumber() async {
    final userData = await getUserData();
    return userData?['mobile_no'];
  }

  /// Get authenticated user's email
  static Future<String?> getEmail() async {
    final userData = await getUserData();
    return userData?['email'];
  }

  /// Save complete login response
  static Future<void> saveLoginResponse({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    await saveToken(token);
    await saveUserData(userData);
  }
}