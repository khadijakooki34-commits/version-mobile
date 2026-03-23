import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';
import '../../utils/url_helper_stub.dart'
    if (dart.library.html) '../../utils/url_helper_web.dart';

/// Screen to handle OAuth callback from Spring Boot
/// Spring Boot redirects here with JWT token in query parameters
class OAuthCallbackScreen extends StatefulWidget {
  const OAuthCallbackScreen({super.key});

  @override
  State<OAuthCallbackScreen> createState() => _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends State<OAuthCallbackScreen> {
  bool _isProcessing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // CRITICAL: Clear hash fragment IMMEDIATELY and SYNCHRONOUSLY
      // This must happen before Flutter's router processes the hash
      UrlHelper.clearHashImmediately();
      _handleOAuthCallback();
    } else {
      _error = 'OAuth callback is only supported on web';
      _isProcessing = false;
    }
  }

  Future<void> _handleOAuthCallback() async {
    try {
      // Get query parameters from URL
      if (!kIsWeb) {
        setState(() {
          _error = 'OAuth callback is only supported on web';
          _isProcessing = false;
        });
        return;
      }
      
      // Get URI without hash to read query parameters
      // (Hash is already cleared, but this ensures we get clean params)
      final uri = UrlHelper.getCurrentUriWithoutHash();
      final params = uri.queryParameters;
      
      // Debug: Print received parameters
      print('OAuth Callback - Received params: ${params.keys.toList()}');
      print('OAuth Callback - AccessToken present: ${params.containsKey('accessToken')}');

      // Check for error
      if (params.containsKey('error')) {
        String rawMessage = params['message'] ?? params['error'] ?? 'OAuth authentication failed';
        
        // Parse and simplify error message
        String userFriendlyMessage = _parseErrorMessage(rawMessage);
        
        setState(() {
          _error = userFriendlyMessage;
          _isProcessing = false;
        });
        
        // Clear URL to remove error parameters and hash
        UrlHelper.clearUrlAndHash();
        
        // Show error snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OAuth Error: $userFriendlyMessage'),
              backgroundColor: AppTheme.errorColor,
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
        return;
      }

      // Extract token and user info from query parameters
      final accessToken = params['accessToken'];
      final refreshToken = params['refreshToken'];
      final userIdStr = params['userId'];
      final email = params['email'];
      final nom = params['nom'];
      final role = params['role'];

      if (accessToken == null || userIdStr == null || email == null || nom == null || role == null) {
        setState(() {
          _error = 'Missing required OAuth parameters';
          _isProcessing = false;
        });
        return;
      }

      final userId = int.tryParse(userIdStr);
      if (userId == null) {
        setState(() {
          _error = 'Invalid user ID';
          _isProcessing = false;
        });
        return;
      }

      // Handle OAuth callback through provider
      final authProvider = context.read<AuthProvider>();
      
      print('OAuth Callback - Processing authentication...');
      await authProvider.handleOAuthCallback(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
        email: email,
        nom: nom,
        role: role,
      );

      // Wait a bit to ensure state is updated and token is saved
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify authentication state
      print('OAuth Callback - isLoggedIn: ${authProvider.isLoggedIn}');
      print('OAuth Callback - token: ${authProvider.token != null ? "present" : "null"}');
      print('OAuth Callback - user: ${authProvider.currentUser?.email}');
      print('OAuth Callback - role: ${authProvider.currentUser?.role}');

      // Clear URL parameters and hash fragment
      UrlHelper.clearUrlAndHash();

      // Navigate to appropriate screen
      if (mounted) {
        // Double-check login status after state update
        if (authProvider.isLoggedIn && authProvider.token != null && authProvider.currentUser != null) {
          // Navigate to appropriate screen based on role
          final targetRoute = authProvider.isAdmin ? '/admin-dashboard' : '/home';
          print('OAuth Callback - Navigating to: $targetRoute');
          
          // Use pushNamedAndRemoveUntil to completely clear navigation stack
          // This ensures we don't go back to login or any previous route
          Navigator.of(context).pushNamedAndRemoveUntil(
            targetRoute,
            (route) => false, // Remove all previous routes
          );
        } else {
          print('OAuth Callback - Authentication failed. Error: ${authProvider.error}');
          setState(() {
            _error = authProvider.error ?? 'Authentication failed. Token or user not set.';
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to process OAuth callback: $e';
        _isProcessing = false;
      });
    }
  }

  /// Parse technical OAuth error messages into user-friendly text
  String _parseErrorMessage(String rawMessage) {
    // Decode URL-encoded characters
    String decoded = Uri.decodeComponent(rawMessage);
    
    // Check for specific error types
    if (decoded.contains('invalid_client')) {
      return 'Invalid OAuth client configuration. Please check the Client Secret in the backend configuration.';
    }
    
    if (decoded.contains('invalid_token_response')) {
      if (decoded.contains('invalid_client')) {
        return 'OAuth Client Secret is incorrect. Please update it in application.properties to match Google Cloud Console.';
      }
      return 'Failed to exchange OAuth token. Please try again or contact support.';
    }
    
    if (decoded.contains('access_denied')) {
      return 'OAuth access was denied. Please try again.';
    }
    
    if (decoded.contains('unauthorized')) {
      return 'OAuth authentication failed: Unauthorized. Please check your Google OAuth configuration.';
    }
    
    // Extract the main error if it's a JSON-like error
    if (decoded.contains('"error"')) {
      try {
        // Try to extract error from JSON-like string
        final errorMatch = RegExp(r'"error"\s*:\s*"([^"]+)"').firstMatch(decoded);
        if (errorMatch != null) {
          final errorType = errorMatch.group(1);
          if (errorType == 'invalid_client') {
            return 'OAuth Client Secret is incorrect. Please update it in application.properties.';
          }
          return 'OAuth Error: $errorType';
        }
      } catch (e) {
        // If parsing fails, continue with default message
      }
    }
    
    // Return a simplified version if message is too long
    if (decoded.length > 200) {
      return 'OAuth authentication failed. Please check your Google OAuth configuration in the backend.';
    }
    
    return decoded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isProcessing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    'Completing authentication...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                    child: Text(
                      _error ?? 'Authentication failed',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                    child: Text(
                      'Please check the OAuth Client Secret in your backend configuration (application.properties) and ensure it matches Google Cloud Console.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textLightColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Return to Login'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingXL,
                        vertical: AppTheme.spacingM,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

