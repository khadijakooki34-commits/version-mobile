import 'package:flutter/foundation.dart';
import '../models/index.dart';
import '../services/index.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;

  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  AuthProvider({required this.authService}) {
    _isLoggedIn = authService.isLoggedIn();
    _token = authService.getToken();
  }

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await authService.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        password: password,
      );

      _currentUser = response.user;
      _token = response.token;
      _isLoggedIn = true;
      _error = null;
    } catch (e) {
      // Extract clean error message from nested exceptions
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        // Remove "Exception: " prefix
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
        // If there are nested exceptions, get the innermost one
        final parts = errorMessage.split(': ');
        if (parts.length > 1) {
          errorMessage = parts.last;
        }
      }
      // Clean up common error patterns
      errorMessage = errorMessage.replaceAll('Exception: ', '');
      _error = errorMessage;
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await authService.login(email: email, password: password);

      _currentUser = response.user;
      _token = response.token;
      _isLoggedIn = true;
      _error = null;
    } catch (e) {
      // Extract clean error message from nested exceptions
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        // Remove "Exception: " prefix
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
        // If there are nested exceptions, get the innermost one
        final parts = errorMessage.split(': ');
        if (parts.length > 1) {
          errorMessage = parts.last;
        }
      }
      // Clean up common error patterns
      errorMessage = errorMessage.replaceAll('Exception: ', '');
      _error = errorMessage;
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Redirect to Spring Boot OAuth for web, or use google_sign_in for mobile
  Future<void> redirectToGoogleOAuth() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kIsWeb) {
        // Web: Redirect to Spring Boot OAuth endpoint
        await authService.redirectToGoogleOAuth();
        // Note: After redirect, user won't return here
        // OAuth callback will be handled by oauth_callback_screen.dart
      } else {
        // Mobile: Use google_sign_in plugin
        final response = await authService.googleSignInLogin();
        _currentUser = response.user;
        _token = response.token;
        _isLoggedIn = true;
        _error = null;
      }
    } catch (e) {
      _error = 'Google Sign-In: ${e.toString()}';
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle OAuth callback from Spring Boot (web only)
  Future<void> handleOAuthCallback({
    required String accessToken,
    String? refreshToken,
    required int userId,
    required String email,
    required String nom,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await authService.handleOAuthCallback(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
        email: email,
        nom: nom,
        role: role,
      );

      // Create user object from OAuth data
      // Split 'nom' into firstName and lastName
      final nameParts = nom.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : email.split('@')[0];
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      
      _currentUser = User(
        id: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        profileImage: null, // Will be fetched from profile if needed
        phoneNumber: '', // OAuth doesn't provide phone number
        role: role,
        isBlocked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _token = response.token;
      _isLoggedIn = true;
      _error = null;
    } catch (e) {
      _error = 'OAuth callback failed: ${e.toString()}';
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Legacy method - kept for backward compatibility
  @Deprecated('Use redirectToGoogleOAuth() instead')
  Future<void> googleSignIn() async {
    await redirectToGoogleOAuth();
  }

  Future<void> verify2FA({required String email, required String code}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await authService.verify2FA(email: email, code: code);

      _currentUser = response.user;
      _token = response.token;
      _isLoggedIn = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await authService.logout();
      _currentUser = null;
      _token = null;
      _isLoggedIn = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
