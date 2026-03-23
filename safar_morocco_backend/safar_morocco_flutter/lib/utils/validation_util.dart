import 'constants.dart';

class ValidationUtil {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!ValidationRegex.email.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    if (!ValidationRegex.password.hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, number, and special character';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!ValidationRegex.phone.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    return null;
  }

  static String? validateComment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le commentaire est requis';
    }
    if (value.length < 10) {
      return 'Le commentaire doit contenir au moins 10 caractères';
    }
    if (value.length > 500) {
      return 'Le commentaire ne doit pas dépasser 500 caractères';
    }
    return null;
  }

  static String? validateRating(String? value) {
    if (value == null || value.isEmpty) {
      return 'La note est requise';
    }
    final rating = double.tryParse(value);
    if (rating == null) {
      return 'Veuillez entrer une note valide';
    }
    if (rating < AppConstants.minRatingValue || rating > AppConstants.maxRatingValue) {
      return 'La note doit être entre 1 et 5';
    }
    return null;
  }

  static bool isValidEmail(String email) {
    return ValidationRegex.email.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= AppConstants.minPasswordLength;
  }

  static bool isValidPhoneNumber(String phone) {
    return ValidationRegex.phone.hasMatch(phone);
  }
}
