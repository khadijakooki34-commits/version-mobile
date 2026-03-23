// Stub for non-web platforms
class UrlHelper {
  static Uri getCurrentUri() {
    throw UnsupportedError('URL helper is only supported on web');
  }
  
  static Uri getCurrentUriWithoutHash() {
    throw UnsupportedError('URL helper is only supported on web');
  }
  
  static void clearHashImmediately() {
    throw UnsupportedError('URL helper is only supported on web');
  }
  
  static void clearUrlAndHash() {
    throw UnsupportedError('URL helper is only supported on web');
  }
  
  // Legacy methods for backward compatibility
  static void clearUrl() {
    throw UnsupportedError('URL helper is only supported on web');
  }
  
  static void clearHash() {
    throw UnsupportedError('clearHash is only supported on web');
  }
}

