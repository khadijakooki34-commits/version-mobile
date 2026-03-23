import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/index.dart';

class DestinationService {
  final ApiService apiService;

  DestinationService({required this.apiService});

  Future<List<Destination>> getDestinations({int page = 0, int size = 10}) async {
    try {
      final response = await apiService.getDestinations(page: page, size: size);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns List<Destination> directly, not paginated
        List<Destination> destinations;
        if (data is List) {
          destinations = data.map((e) => Destination.fromJson(e)).toList();
        } else if (data['content'] != null) {
          // Handle paginated response if backend changes
          destinations = (data['content'] as List)
              .map((e) => Destination.fromJson(e))
              .toList();
        } else {
          destinations = [];
        }
        
        // Debug: Print all available categories
        final categories = destinations.map((d) => d.category).toSet().toList();
        debugPrint('Available categories: $categories');
        
        return destinations;
      } else {
        throw Exception('Échec de la récupération des destinations');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des destinations: $e');
    }
  }

  Future<Destination> getDestinationById(int id) async {
    try {
      final response = await apiService.getDestinationById(id);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Destination.fromJson(data);
      } else {
        throw Exception('Failed to fetch destination');
      }
    } catch (e) {
      throw Exception('Error fetching destination: $e');
    }
  }

  Future<List<Destination>> searchDestinations(String query) async {
    try {
      // Backend doesn't have /search endpoint, fetch all and filter client-side
      final allDestinations = await getDestinations();
      
      // Filter by query (search in name, description, location)
      if (query.isEmpty) {
        return allDestinations;
      }
      
      final queryLower = query.toLowerCase();
      return allDestinations.where((destination) {
        return destination.name.toLowerCase().contains(queryLower) ||
               destination.description.toLowerCase().contains(queryLower) ||
               destination.location.toLowerCase().contains(queryLower);
      }).toList();
    } catch (e) {
      throw Exception('Error searching destinations: $e');
    }
  }

  Future<List<Destination>> filterDestinations({
    String? category,
    double? minRating,
  }) async {
    try {
      List<Destination> destinations;
      
      // First try the filter endpoint
      if (category != null && category.isNotEmpty) {
        try {
          final response = await apiService.filterDestinations(
            category: category,
            minRating: minRating,
          );
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data is List) {
              destinations = data.map((e) => Destination.fromJson(e)).toList();
            } else if (data['content'] != null) {
              destinations = (data['content'] as List)
                  .map((e) => Destination.fromJson(e))
                  .toList();
            } else {
              destinations = [];
            }
            debugPrint('Filter endpoint returned ${destinations.length} results');
            return destinations;
          }
        } catch (e) {
          debugPrint('Filter endpoint failed, trying category endpoint: $e');
        }
        
        // Try category endpoint as fallback
        try {
          final response = await apiService.getDestinationsByCategory(category);
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data is List) {
              destinations = data.map((e) => Destination.fromJson(e)).toList();
            } else if (data['content'] != null) {
              destinations = (data['content'] as List)
                  .map((e) => Destination.fromJson(e))
                  .toList();
            } else {
              destinations = [];
            }
            debugPrint('Category endpoint returned ${destinations.length} results');
            return destinations;
          }
        } catch (e) {
          debugPrint('Category endpoint failed, fetching all: $e');
        }
        
        // If both endpoints fail, fetch all and filter client-side
        destinations = await getDestinations();
      } else {
        // No category filter, fetch all destinations
        destinations = await getDestinations();
      }
      
      // Apply client-side category filter with intelligent matching
      if (category != null && category.isNotEmpty) {
        final categoryLower = category.toLowerCase().trim();
        destinations = destinations.where((d) {
          final destCategoryLower = d.category.toLowerCase().trim();
          
          // Exact match
          if (destCategoryLower == categoryLower) return true;
          
          // Contains match
          if (destCategoryLower.contains(categoryLower) || 
              categoryLower.contains(destCategoryLower)) return true;
          
          // Smart matching for common variations
          return _matchesCategory(destCategoryLower, categoryLower);
        }).toList();
        
        debugPrint('Filtered "$category" -> ${destinations.length} results');
      }
      
      // Filter by minRating if provided
      if (minRating != null && minRating > 0) {
        destinations = destinations
            .where((d) => d.rating >= minRating)
            .toList();
        debugPrint('Filtered by rating >= $minRating -> ${destinations.length} results');
      }
      
      return destinations;
    } on FormatException catch (e) {
      throw Exception('Format de réponse serveur invalide: $e');
    } catch (e) {
      // Re-throw network errors as-is
      if (e.toString().contains('Network error') || 
          e.toString().contains('Failed to connect')) {
        rethrow;
      }
      throw Exception('Erreur lors du filtrage des destinations: $e');
    }
  }
  
  // Smart category matching helper
  bool _matchesCategory(String destinationCategory, String filterCategory) {
    // Define category mappings for better matching
    final Map<String, List<String>> categoryMappings = {
      'cultural': ['cultural', 'culture', 'art', 'museum', 'gallery'],
      'historical': ['historical', 'history', 'monument', 'heritage', 'site historique'],
      'religious': ['religious', 'temple', 'mosque', 'church', 'sacred'],
      'nature': ['nature', 'natural', 'park', 'garden', 'reserve', 'plage', 'montagne'],
    };
    
    // Check all mappings
    for (final entry in categoryMappings.entries) {
      if (entry.value.any((term) => 
          destinationCategory.contains(term) && filterCategory.contains(term))) {
        return true;
      }
    }
    
    return false;
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
    try {
      final destinationData = {
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'category': category,
        if (history != null) 'history': history,
        if (type != null) 'type': type,
      };

      // Backend expects JSON for destination creation.
      final response = await apiService.createDestination(destinationData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final created = Destination.fromJson(jsonDecode(response.body));

        // Optional image upload is handled by dedicated media endpoint.
        if (imageFile != null) {
          final uploadResponse = await apiService.uploadDestinationMedia(
            destinationId: created.id,
            imageFile: imageFile,
            description: 'Main image for ${created.name}',
          );
          if (uploadResponse.statusCode != 201 && uploadResponse.statusCode != 200) {
            throw Exception(
              'Destination created but image upload failed: ${uploadResponse.statusCode} ${uploadResponse.body}',
            );
          }

          // Re-fetch to include uploaded image in medias list.
          return await getDestinationById(created.id);
        }

        return created;
      } else {
        throw Exception(
          'Failed to create destination: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error creating destination: $e');
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
    try {
      final destinationData = {
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'category': category,
        if (history != null) 'history': history,
        if (type != null) 'type': type,
      };

      final response = await apiService.updateDestination(id, destinationData);
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update destination: ${response.statusCode} ${response.body}',
        );
      }

      if (imageFile != null) {
        final uploadResponse = await apiService.uploadDestinationMedia(
          destinationId: id,
          imageFile: imageFile,
          description: 'Updated image for $name',
        );
        if (uploadResponse.statusCode != 201 && uploadResponse.statusCode != 200) {
          throw Exception(
            'Destination updated but image upload failed: ${uploadResponse.statusCode} ${uploadResponse.body}',
          );
        }
      }

      return await getDestinationById(id);
    } catch (e) {
      throw Exception('Error updating destination: $e');
    }
  }

  Future<void> deleteDestination(int id) async {
    try {
      final response = await apiService.deleteDestination(id);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete destination');
      }
    } catch (e) {
      throw Exception('Error deleting destination: $e');
    }
  }
}
