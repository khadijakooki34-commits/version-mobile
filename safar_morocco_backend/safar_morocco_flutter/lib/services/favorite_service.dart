import 'dart:convert';
import 'api_service.dart';
import '../models/index.dart';

class FavoriteService {
  final ApiService apiService;

  FavoriteService({required this.apiService});

  Future<void> addFavorite(int destinationId) async {
    try {
      final response = await apiService.addFavorite(destinationId);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Échec de l\'ajout aux favoris');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout aux favoris: $e');
    }
  }

  Future<void> removeFavorite(int destinationId) async {
    try {
      final response = await apiService.removeFavorite(destinationId);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Échec du retrait des favoris');
      }
    } catch (e) {
      throw Exception('Erreur lors du retrait des favoris: $e');
    }
  }

  Future<bool> isFavorite(int destinationId) async {
    try {
      final response = await apiService.checkFavorite(destinationId);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data == true || data['isFavorite'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<int>> getFavoriteDestinationIds() async {
    try {
      final response = await apiService.getMyFavorites();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<int> ids = [];
        if (data is List) {
          for (var item in data) {
            if (item is Map) {
              final dest = item['destination'] ?? {};
              final id = dest['id'];
              if (id != null) {
                ids.add(id is int ? id : int.tryParse(id.toString()) ?? 0);
              }
            }
          }
        }
        return ids;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Returns full Destination objects for the user's favorites
  Future<List<Destination>> getMyFavoriteDestinations() async {
    try {
      final response = await apiService.getMyFavorites();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Destination> destinations = [];
        if (data is List) {
          for (var item in data) {
            if (item is Map) {
              final dest = item['destination'];
              if (dest is Map) {
                destinations.add(Destination.fromJson(Map<String, dynamic>.from(dest)));
              }
            }
          }
        }
        return destinations;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

