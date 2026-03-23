import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService favoriteService;
  
  Set<int> _favoriteIds = {};
  List<Destination> _favoriteDestinations = [];
  bool _isLoading = false;
  String? _error;

  FavoriteProvider({required this.favoriteService});

  Set<int> get favoriteIds => _favoriteIds;
  List<Destination> get favoriteDestinations => _favoriteDestinations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  bool isFavorite(int destinationId) => _favoriteIds.contains(destinationId);

  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final destinations = await favoriteService.getMyFavoriteDestinations();
      _favoriteDestinations = destinations;
      _favoriteIds = destinations.map((d) => d.id).toSet();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int destinationId, {Destination? destination}) async {
    final wasFavorite = _favoriteIds.contains(destinationId);
    
    // Optimistically update UI
    if (wasFavorite) {
      _favoriteIds.remove(destinationId);
      _favoriteDestinations.removeWhere((d) => d.id == destinationId);
    } else {
      _favoriteIds.add(destinationId);
      if (destination != null) {
        _favoriteDestinations.add(destination);
      }
    }
    notifyListeners();

    try {
      if (wasFavorite) {
        await favoriteService.removeFavorite(destinationId);
      } else {
        await favoriteService.addFavorite(destinationId);
      }
    } catch (e) {
      // Revert on error
      if (wasFavorite) {
        _favoriteIds.add(destinationId);
        if (destination != null) {
          _favoriteDestinations.add(destination);
        }
      } else {
        _favoriteIds.remove(destinationId);
        _favoriteDestinations.removeWhere((d) => d.id == destinationId);
      }
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> checkFavorite(int destinationId) async {
    try {
      final isFav = await favoriteService.isFavorite(destinationId);
      if (isFav) {
        _favoriteIds.add(destinationId);
      } else {
        _favoriteIds.remove(destinationId);
      }
      notifyListeners();
    } catch (e) {
      // Silent fail for check
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

