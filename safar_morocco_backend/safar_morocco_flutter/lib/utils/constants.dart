class AppConstants {
  static const String appName = 'Safar Morocco';
  static const String appVersion = '1.0.0';
  
  // Durations
  static const Duration defaultDuration = Duration(seconds: 3);
  
  // API
  static const String baseUrl = 'http://192.168.1.107:8088/api';
  static const String serverBaseUrl = 'http://192.168.1.107:8088';
  static const int apiTimeoutSeconds = 30;

  // Roles
  static const String roleUser = 'USER';
  static const String roleAdmin = 'ADMIN';

  // Categories - Match backend categories exactly
  static const List<String> destinationCategories = [
    'Cultural',
    'Historical', 
    'Religious',
    'Nature',
  ];

  static const List<String> eventCategories = [
    'Festival',
    'Concert',
    'Exposition',
    'Atelier',
    'Conférence',
    'Sport',
  ];

  // Messages
  static const String loginSuccess = 'Login successful';
  static const String registerSuccess = 'Registration successful';
  static const String logoutSuccess = 'Logged out successfully';
  static const String tokenExpired = 'Your session has expired. Please login again.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String unknownError = 'An unknown error occurred.';

  // Numbers
  static const int pageSize = 10;
  static const int minPasswordLength = 8;
  static const double minRatingValue = 1.0;
  static const double maxRatingValue = 5.0;
}

class ValidationRegex {
  static final email = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  static final phone = RegExp(r'^[0-9]{10,}$');
  static final password = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
}

class Durations {
  static const animationDuration = Duration(milliseconds: 300);
  static const shortDuration = Duration(seconds: 2);
  static const mediumDuration = Duration(seconds: 5);
  static const splashScreenDuration = Duration(seconds: 3);
  static const tokenRefreshInterval = Duration(minutes: 30);
}
