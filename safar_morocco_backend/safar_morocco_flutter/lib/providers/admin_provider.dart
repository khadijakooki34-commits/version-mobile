import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService adminService;

  List<User> _users = [];
  Statistics? _statistics;
  bool _isLoading = false;
  String? _error;

  AdminProvider({required this.adminService});

  List<User> get users => _users;
  Statistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers({int page = 0, int size = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await adminService.getUsers(page: page, size: size);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeUserRole(int userId, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await adminService.changeUserRole(userId, role);
      _users = _users.map((user) {
        if (user.id == userId) {
          return User(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            profileImage: user.profileImage,
            phoneNumber: user.phoneNumber,
            role: role.toUpperCase(),
            isBlocked: user.isBlocked,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
          );
        }
        return user;
      }).toList();
    } catch (e) {
      // Keep the users screen visible; role-change failures are shown via snackbar.
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDestination(int destinationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await adminService.deleteDestination(destinationId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _statistics = await adminService.getStatistics();
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
}
