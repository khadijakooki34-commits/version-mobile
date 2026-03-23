import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class AdminEventProvider extends ChangeNotifier {
  final EventService eventService;
  final ApiService apiService;

  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  bool _isSaving = false;

  AdminEventProvider({
    required this.eventService,
    required this.apiService,
  });

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSaving => _isSaving;

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await eventService.getEvents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEvent({
    required int destinationId,
    required String nom,
    required DateTime dateDebut,
    required DateTime dateFin,
    required String lieu,
    required String typeEvenement,
    String description = '',
    String imageUrl = '',
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final body = {
        'nom': nom,
        'dateDebut': dateDebut.toIso8601String(),
        'dateFin': dateFin.toIso8601String(),
        'lieu': lieu,
        'typeEvenement': typeEvenement,
        'description': description,
        if (imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      };
      final response = await apiService.adminCreateEvent(
        destinationId: destinationId,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isSaving = false;
        await fetchEvents();
        notifyListeners();
        return true;
      }
      _error = 'Create failed: ${response.statusCode}';
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent({
    required int id,
    required String nom,
    required DateTime dateDebut,
    required DateTime dateFin,
    required String lieu,
    required String typeEvenement,
    String description = '',
    String imageUrl = '',
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final body = {
        'nom': nom,
        'dateDebut': dateDebut.toIso8601String(),
        'dateFin': dateFin.toIso8601String(),
        'lieu': lieu,
        'typeEvenement': typeEvenement,
        'description': description,
        if (imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      };
      final response = await apiService.adminUpdateEvent(id, body);

      if (response.statusCode == 200) {
        _isSaving = false;
        await fetchEvents();
        notifyListeners();
        return true;
      }
      _error = 'Update failed: ${response.statusCode}';
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEvent(int id) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.adminDeleteEvent(id);

      if (response.statusCode == 200 || response.statusCode == 204) {
        _events = _events.where((e) => e.id != id).toList();
        _isSaving = false;
        notifyListeners();
        return true;
      }
      _error = 'Delete failed: ${response.statusCode}';
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
