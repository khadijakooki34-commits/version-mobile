import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class ReservationProvider extends ChangeNotifier {
  final ReservationService reservationService;

  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String? _error;
  bool _isReserving = false;

  ReservationProvider({required this.reservationService});

  List<Reservation> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isReserving => _isReserving;

  Future<void> fetchMyReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await reservationService.getMyReservations();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns true if reservation succeeded, false otherwise. Error message in [error].
  Future<bool> reserveEvent(int evenementId) async {
    _isReserving = true;
    _error = null;
    notifyListeners();

    try {
      final reservation = await reservationService.createReservation(evenementId);
      _reservations = [..._reservations, reservation];
      _isReserving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      _isReserving = false;
      notifyListeners();
      return false;
    }
  }

  bool hasReservedEvent(int evenementId) {
    return _reservations.any((r) => r.event.id == evenementId && r.status != 'CANCELLED');
  }

  Future<bool> cancelReservation(int reservationId) async {
    _error = null;
    try {
      await reservationService.cancelReservation(reservationId);
      _reservations = _reservations.where((r) => r.id != reservationId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
