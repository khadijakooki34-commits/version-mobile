// Web-specific URL helper
import 'dart:html' as html;

class UrlHelper {
  static Uri getCurrentUri() {
    return Uri.parse(html.window.location.href);
  }
  
  /// Get the current URL without the hash fragment (synchronously)
  /// This is useful for reading query parameters before the router processes the hash
  static Uri getCurrentUriWithoutHash() {
    final href = html.window.location.href;
    final hashIndex = href.indexOf('#');
    if (hashIndex != -1) {
      return Uri.parse(href.substring(0, hashIndex));
    }
    return Uri.parse(href);
  }
  
  /// Clear hash fragment immediately and synchronously
  /// This prevents Flutter's router from processing the hash
  static void clearHashImmediately() {
    // Clear hash synchronously using replaceState to prevent router navigation
    final currentUrl = html.window.location.href;
    final hashIndex = currentUrl.indexOf('#');
    if (hashIndex != -1) {
      final urlWithoutHash = currentUrl.substring(0, hashIndex);
      html.window.history.replaceState(null, '', urlWithoutHash);
    }
  }
  
  static void clearUrlAndHash() {
    // Clear query parameters and hash fragment, keep only the pathname
    html.window.history.replaceState(null, '', html.window.location.pathname);
  }
  
  // Legacy methods for backward compatibility
  static void clearUrl() {
    clearUrlAndHash();
  }
  
  static void clearHash() {
    html.window.location.hash = '';
  }
}

