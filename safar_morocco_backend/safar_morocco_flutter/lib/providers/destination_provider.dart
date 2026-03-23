import 'package:flutter/material.dart';
import 'dart:io';
import '../models/index.dart';
import '../services/index.dart';

class DestinationProvider extends ChangeNotifier {
  final DestinationService destinationService;

  List<Destination> _destinations = [];
  Destination? _selectedDestination;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;

  DestinationProvider({required this.destinationService});

  List<Destination> get destinations => _destinations;
  Destination? get selectedDestination => _selectedDestination;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> fetchDestinations({int page = 0}) async {
    if (page == 0) {
      _isLoading = true;
      _destinations = [];
    }
    _error = null;
    notifyListeners();

    try {
      final destinations = await destinationService.getDestinations(page: page, size: 10);
      if (page == 0) {
        _destinations = destinations;
      } else {
        _destinations.addAll(destinations);
      }
      // Backend doesn't paginate, so we won't have more pages
      _hasMore = false;
      _currentPage = page;
    } catch (e) {
      // Extract clean error message
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
        final parts = errorMessage.split(': ');
        if (parts.length > 1) {
          errorMessage = parts.last;
        }
      }
      errorMessage = errorMessage.replaceAll('Exception: ', '');
      _error = errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getDestinationById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedDestination = await destinationService.getDestinationById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchDestinations(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _destinations = await destinationService.searchDestinations(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterDestinations({String? category, double? minRating}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _destinations = await destinationService.filterDestinations(
        category: category,
        minRating: minRating,
      );
      _hasMore = false; // Filtered results don't support pagination
      _currentPage = 0;
    } catch (e) {
      // Extract clean error message
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
        final parts = errorMessage.split(': ');
        if (parts.length > 1) {
          errorMessage = parts.last;
        }
      }
      errorMessage = errorMessage.replaceAll('Exception: ', '');
      _error = errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    await fetchDestinations(page: _currentPage + 1);
  }

  Future<Destination> createDestination({
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required String category,
    String? history,
    String? type,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final destination = await destinationService.createDestination(
        name: name,
        description: description,
        latitude: latitude,
        longitude: longitude,
        category: category,
        history: history,
        type: type,
        imageFile: imageFile,
      );
      // Add to local list
      _destinations.insert(0, destination);
      return destination;
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
        final parts = errorMessage.split(': ');
        if (parts.length > 1) {
          errorMessage = parts.last;
        }
      }
      errorMessage = errorMessage.replaceAll('Exception: ', '');
      _error = errorMessage;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDestination(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await destinationService.deleteDestination(id);
      // Remove from local list
      _destinations.removeWhere((d) => d.id == id);
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
        final parts = errorMessage.split(': ');
        if (parts.length > 1) {
          errorMessage = parts.last;
        }
      }
      errorMessage = errorMessage.replaceAll('Exception: ', '');
      _error = errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Destination> updateDestination({
    required int id,
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required String category,
    String? history,
    String? type,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final destination = await destinationService.updateDestination(
        id: id,
        name: name,
        description: description,
        latitude: latitude,
        longitude: longitude,
        category: category,
        history: history,
        type: type,
        imageFile: imageFile,
      );

      final index = _destinations.indexWhere((d) => d.id == id);
      if (index != -1) {
        _destinations[index] = destination;
      }
      return destination;
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
        final parts = errorMessage.split(': ');
        if (parts.length > 1) {
          errorMessage = parts.last;
        }
      }
      errorMessage = errorMessage.replaceAll('Exception: ', '');
      _error = errorMessage;
      rethrow;
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
