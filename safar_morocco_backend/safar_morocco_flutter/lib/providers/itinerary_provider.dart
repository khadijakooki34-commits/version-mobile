import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class ItineraryProvider extends ChangeNotifier {
  final ItineraryService itineraryService;

  List<Itinerary> _itineraries = [];
  ItineraryDetail? _currentDetail;
  bool _isLoading = false;
  String? _error;
  bool _isSaving = false;

  ItineraryProvider({required this.itineraryService});

  List<Itinerary> get itineraries => _itineraries;
  ItineraryDetail? get currentDetail => _currentDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSaving => _isSaving;

  int? _userId;
  void setUserId(int id) => _userId = id;
  int? get userId => _userId;

  Future<void> fetchItineraries(int userId) async {
    _userId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _itineraries = await itineraryService.getItineraries(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchItineraryDetail(int id, int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentDetail = await itineraryService.getItineraryById(id, userId);
    } catch (e) {
      _error = e.toString();
      _currentDetail = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createItinerary(int userId, {required String nom, required List<int> destinationIds}) async {
    if (destinationIds.isEmpty) {
      _error = 'Ajoutez au moins une destination';
      notifyListeners();
      return false;
    }
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      final it = await itineraryService.createItinerary(userId, nom: nom, destinationIds: destinationIds);
      _itineraries = [..._itineraries, it];
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItinerary(int id, int userId) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await itineraryService.deleteItinerary(id, userId);
      _itineraries = _itineraries.where((i) => i.id != id).toList();
      if (_currentDetail?.id == id) _currentDetail = null;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addDestination(int itineraryId, int destinationId, int userId) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await itineraryService.addDestinationToItinerary(itineraryId, destinationId, userId);
      await fetchItineraryDetail(itineraryId, userId);
      await fetchItineraries(userId);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeDestination(int itineraryId, int destinationId, int userId) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await itineraryService.removeDestinationFromItinerary(itineraryId, destinationId, userId);
      await fetchItineraryDetail(itineraryId, userId);
      await fetchItineraries(userId);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> optimizeItinerary(int id, int userId) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await itineraryService.optimizeItinerary(id, userId);
      await fetchItineraryDetail(id, userId);
      await fetchItineraries(userId);
      _isSaving = false;
      notifyListeners();
      return true;
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

  void clearCurrentDetail() {
    _currentDetail = null;
    notifyListeners();
  }
}
