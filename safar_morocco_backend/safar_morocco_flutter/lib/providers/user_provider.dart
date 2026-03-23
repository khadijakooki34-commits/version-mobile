import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class UserProvider extends ChangeNotifier {
  final UserService userService;

  User? _user;
  bool _isLoading = false;
  String? _error;

  UserProvider({required this.userService});

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await userService.getUserProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? profileImage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await userService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profileImage: profileImage,
      );
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

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
