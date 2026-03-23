// Conditional import for web vs non-web

export 'oauth_redirect_service_stub.dart'
    if (dart.library.html) 'oauth_redirect_service_web.dart';

