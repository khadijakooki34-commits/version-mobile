import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service for Google OAuth2 sign-in.
/// Works on Android, iOS, and Web (with proper configuration).
///
/// IMPORTANT: serverClientId (Web client) and Android OAuth client MUST be in
/// the SAME Google Cloud project, otherwise Google will not return an ID token.
class GoogleSignInService {
  late final GoogleSignIn _googleSignIn;

  GoogleSignInService() {
    final webClientId = _getWebClientId();
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile', 'openid'],
      clientId: kIsWeb ? webClientId : null,
      serverClientId: kIsWeb ? null : webClientId,
    );
  }

  String _getWebClientId() {
    const envClientId = String.fromEnvironment(
      'GOOGLE_WEB_CLIENT_ID',
      defaultValue: '',
    );
    if (envClientId.isNotEmpty) {
      return envClientId;
    }
    // Web client - must be in SAME project as Android OAuth client
    return '3637387413-3s9sq5frbuf4o75teqok53i3qsumgs9c.apps.googleusercontent.com';
  }

  /// Sign in with Google and return the ID token for backend verification.
  /// Returns null if user cancels or sign-in fails.
  /// 
  /// Note: On web, ID token might not be available. In that case, we use
  /// the access token to fetch user info and create a custom token.
  Future<String?> signInAndGetIdToken() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        return null; // User cancelled
      }

      // Request authentication (this gets the ID token)
      final GoogleSignInAuthentication auth = await account.authentication;

      // On web, ID token might not be available without serverClientId
      // But we can try to get it with 'openid' scope
      String? idToken = auth.idToken;

      // If ID token is not available on web, try using access token
      if (kIsWeb && (idToken == null || idToken.isEmpty)) {
        // On web without serverClientId, ID token might not be available
        // We'll need to use the backend OAuth redirect flow instead
        // For now, return null so the caller can handle it
        return null;
      }

      if (idToken == null || idToken.isEmpty) {
        throw Exception('No ID token received from Google');
      }

      return idToken;
    } catch (e) {
      // Check for user cancellation (common error codes)
      final msg = e.toString().toLowerCase();
      if (msg.contains('sign_in_canceled') ||
          msg.contains('canceled') ||
          msg.contains('cancelled') ||
          msg.contains('12501')) {
        return null;
      }
      rethrow;
    }
  }

  /// Sign out from Google (clears cached credentials)
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Disconnect (revoke access) - use when user wants to fully remove Google account
  Future<void> disconnect() async {
    await _googleSignIn.disconnect();
  }
}

