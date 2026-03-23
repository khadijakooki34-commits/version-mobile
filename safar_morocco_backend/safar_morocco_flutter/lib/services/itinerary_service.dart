import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/index.dart';

class ItineraryService {
  final ApiService apiService;

  ItineraryService({required this.apiService});

  Future<List<Itinerary>> getItineraries(int userId) async {
    final response = await apiService.getItineraries(userId);
    if (response.statusCode != 200) throw Exception('Échec du chargement des itinéraires');
    final data = jsonDecode(response.body);
    final list = data is List ? data : (data['content'] as List? ?? []);
    return list.map((e) => Itinerary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ItineraryDetail?> getItineraryById(int id, int userId) async {
    final response = await apiService.getItineraryById(id, userId);
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ItineraryDetail.fromJson(data);
  }

  Future<Itinerary> createItinerary(int userId, {required String nom, required List<int> destinationIds}) async {
    final body = {
      'nom': nom,
      'destinationIds': destinationIds,
      'optimiser': false,
    };
    // Debug logging
    debugPrint('📡 Create Itinerary: Creating itinerary for user $userId');
    debugPrint('📡 Create Itinerary body: $body');
    final response = await apiService.createItinerary(userId, body);
    debugPrint('✅ Create Itinerary status: ${response.statusCode}');
    debugPrint('📦 Create Itinerary response: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      // Extraire le message d'erreur du backend
      String errorMessage = 'Échec de la création de l\'itinéraire';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        }
      } catch (_) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw Exception(errorMessage);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Itinerary.fromJson(data);
  }

  Future<void> deleteItinerary(int id, int userId) async {
    final response = await apiService.deleteItinerary(id, userId);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Échec de la suppression de l\'itinéraire');
    }
  }

  Future<Itinerary> addDestinationToItinerary(int itineraryId, int destinationId, int userId) async {
    final response = await apiService.addDestinationToItinerary(itineraryId, destinationId, userId);
    if (response.statusCode != 200) throw Exception('Échec de l\'ajout de la destination');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Itinerary.fromJson(data);
  }

  Future<Itinerary> removeDestinationFromItinerary(int itineraryId, int destinationId, int userId) async {
    final response = await apiService.removeDestinationFromItinerary(itineraryId, destinationId, userId);
    if (response.statusCode != 200) throw Exception('Échec du retrait de la destination');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Itinerary.fromJson(data);
  }

  Future<Itinerary> optimizeItinerary(int id, int userId) async {
    final response = await apiService.optimizeItinerary(id, userId);
    if (response.statusCode != 200) throw Exception('Échec de l\'optimisation');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Itinerary.fromJson(data);
  }
}