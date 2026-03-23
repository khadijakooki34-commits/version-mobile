// Web-specific implementation
import 'dart:html' as html;
import '../utils/constants.dart';

class OAuthRedirectService {
  static void redirectToGoogleOAuth() {
    const oauthUrl = '${AppConstants.serverBaseUrl}/oauth2/authorization/google';
    html.window.location.href = oauthUrl;
  }
}

