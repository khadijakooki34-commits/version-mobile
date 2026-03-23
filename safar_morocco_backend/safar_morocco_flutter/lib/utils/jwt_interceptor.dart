import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global navigator key for navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class JwtInterceptor {
  static const String tokenKey = 'jwt_token';
  static const String userKey = 'user_data';

  /// Check if token is expired and handle logout if needed
  static Future<bool> checkAndHandleExpiry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);
      
      if (token == null) return false;
      
      if (JwtDecoder.isExpired(token)) {
        await _performLogout();
        _navigateToLogin();
        return true; // Token was expired
      }
      
      return false; // Token is valid
    } catch (e) {
      print('Error checking token expiry: $e');
      return false;
    }
  }

  /// Handle 401 Unauthorized response - token expired or invalid
  static Future<void> handleUnauthorized() async {
    await _performLogout();
    _navigateToLogin();
    _showExpiredMessage();
  }

  /// Handle 403 Forbidden response - insufficient permissions
  static void handleForbidden() {
    _showForbiddenMessage();
  }

  static Future<void> _performLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove(userKey);
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  static void _navigateToLogin() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  static void _showExpiredMessage() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please login again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  static void _showForbiddenMessage() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to perform this action.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

