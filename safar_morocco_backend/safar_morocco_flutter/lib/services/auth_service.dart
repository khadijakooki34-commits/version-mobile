import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'google_sign_in_service.dart';
import 'oauth_redirect_service_stub.dart'
    if (dart.library.html) 'oauth_redirect_service_web.dart';
import '../models/index.dart';

class AuthService {
  final ApiService apiService;

  AuthService({required this.apiService});

  Future<AuthResponse> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await apiService.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        password: password,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        await apiService.setToken(authResponse.token);
        return authResponse;
      } else {
        String errorMessage = 'Registration failed';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 
                        errorData['error'] ?? 
                        'Registration failed with status ${response.statusCode}';
        } catch (_) {
          errorMessage = 'Registration failed with status ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } on FormatException catch (e) {
      throw Exception('Invalid server response format: $e');
    } catch (e) {
      // Re-throw if it's already an Exception with a message
      if (e.toString().contains('Network error') || 
          e.toString().contains('Failed to connect')) {
        rethrow;
      }
      throw Exception('Registration error: $e');
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiService.login(
        email: email,
        password: password,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        await apiService.setToken(authResponse.token);
        return authResponse;
      } else {
        String errorMessage = 'Login failed';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 
                        errorData['error'] ?? 
                        'Login failed with status ${response.statusCode}';
        } catch (_) {
          errorMessage = 'Login failed with status ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } on FormatException catch (e) {
      throw Exception('Invalid server response format: $e');
    } catch (e) {
      // Re-throw if it's already an Exception with a message
      if (e.toString().contains('Network error') || 
          e.toString().contains('Failed to connect')) {
        rethrow;
      }
      throw Exception('Login error: $e');
    }
  }

  /// Redirect to Spring Boot OAuth2 endpoint for web
  /// For mobile, use googleSignInLogin() instead
  Future<void> redirectToGoogleOAuth() async {
    if (kIsWeb) {
      // Web: Redirect to Spring Boot OAuth2 endpoint
      // Spring Boot will handle the entire OAuth flow
      OAuthRedirectService.redirectToGoogleOAuth();
    } else {
      // Mobile should use googleSignInLogin() instead
      throw UnsupportedError('redirectToGoogleOAuth() is only for web. Use googleSignInLogin() for mobile.');
    }
  }

  /// Handle OAuth callback from Spring Boot (web only)
  /// Called when Spring Boot redirects back to Flutter with JWT token
  Future<AuthResponse> handleOAuthCallback({
    required String accessToken,
    String? refreshToken,
    required int userId,
    required String email,
    required String nom,
    required String role,
  }) async {
    try {
      // Store the token
      await apiService.setToken(accessToken);
      
      // Split 'nom' into firstName and lastName for User model
      final nameParts = nom.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : email.split('@')[0];
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      
      // Create User object from OAuth data
      final user = User(
        id: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        profileImage: null, // OAuth doesn't provide profile image in callback
        phoneNumber: '', // OAuth doesn't provide phone number
        role: role,
        isBlocked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Create AuthResponse with User object
      return AuthResponse(
        token: accessToken,
        refreshToken: refreshToken,
        user: user,
        message: 'OAuth authentication successful',
      );
    } catch (e) {
      throw Exception('Failed to handle OAuth callback: $e');
    }
  }

  /// Legacy method - kept for backward compatibility
  /// For web, redirects to OAuth. For mobile, uses google_sign_in.
  @Deprecated('Use redirectToGoogleOAuth() for web or handle mobile separately')
  Future<AuthResponse> googleSignInLogin() async {
    if (kIsWeb) {
      await redirectToGoogleOAuth();
      throw Exception('OAuth redirect initiated - handle callback separately');
    } else {
      // Mobile implementation (same as before)
      try {
        final googleSignInService = GoogleSignInService();
        final idToken = await googleSignInService.signInAndGetIdToken();
        
        if (idToken == null || idToken.isEmpty) {
          throw Exception('Google sign-in was cancelled');
        }

        final response = await apiService.googleSignIn(idToken: idToken);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final authResponse = AuthResponse.fromJson(data);
          await apiService.setToken(authResponse.token);
          return authResponse;
        } else {
          String errorMessage = 'Google sign-in failed';
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? 
                          errorData['error'] ?? 
                          'Google sign-in failed with status ${response.statusCode}';
          } catch (_) {
            errorMessage = 'Google sign-in failed with status ${response.statusCode}';
          }
          throw Exception(errorMessage);
        }
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<AuthResponse> verify2FA({
    required String email,
    required String code,
  }) async {
    try {
      final response = await apiService.verify2FA(
        email: email,
        code: code,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        await apiService.setToken(authResponse.token);
        return authResponse;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? '2FA verification failed');
      }
    } catch (e) {
      throw Exception('2FA verification error: $e');
    }
  }

  Future<void> logout() async {
    try {
      // Sign out from Google so the account picker is shown next time
      final googleSignInService = GoogleSignInService();
      await googleSignInService.signOut();
    } catch (e) {
      debugPrint('Error signing out from Google: $e');
    }
    await apiService.logout();
  }

  /// Request password reset. Returns the reset token (for dev - in prod would send email).
  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await apiService.forgotPassword(email: email);
      if (response.statusCode == 200) {
        // Backend returns: "Token de réinitialisation (DEV ONLY): <token>"
        final body = response.body;
        if (body.contains(':')) {
          final parts = body.split(': ');
          if (parts.length >= 2) {
            return parts.last.trim();
          }
        }
        return body;
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(errorData['message'] ?? errorData['error'] ?? 'Failed to send reset link');
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Failed to send reset link');
        }
      }
    } catch (e) {
      if (e.toString().contains('Network error') || e.toString().contains('Failed to connect')) {
        rethrow;
      }
      throw Exception('Forgot password error: $e');
    }
  }

  Future<void> resetPassword({required String token, required String newPassword}) async {
    try {
      final response = await apiService.resetPassword(token: token, newPassword: newPassword);
      if (response.statusCode != 200) {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(errorData['message'] ?? errorData['error'] ?? 'Failed to reset password');
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Failed to reset password');
        }
      }
    } catch (e) {
      if (e.toString().contains('Network error') || e.toString().contains('Failed to connect')) {
        rethrow;
      }
      throw Exception('Reset password error: $e');
    }
  }

  bool isLoggedIn() {
    return apiService.isLoggedIn();
  }

  String? getToken() {
    return apiService.getToken();
  }
}
