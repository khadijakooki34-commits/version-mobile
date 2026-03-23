// Stub file for non-web platforms

class OAuthRedirectService {
  static void redirectToGoogleOAuth() {
    throw UnsupportedError('OAuth redirect is only supported on web');
  }
}

