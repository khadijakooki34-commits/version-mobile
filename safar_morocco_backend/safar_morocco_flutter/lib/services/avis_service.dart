import 'dart:convert';
import '../models/review_model.dart';
import 'api_service.dart';

class AvisService {
  final ApiService apiService;

  AvisService({required this.apiService});

  // Récupérer tous les avis en attente (admin)
  Future<List<Avis>> getPendingAvis() async {
    try {
      final response = await apiService.client.get(
        Uri.parse('${ApiService.baseUrl}/avis/admin/pending'),
        headers: await apiService.getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Avis.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pending avis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching pending avis: $e');
    }
  }

  // Approuver un avis (admin)
  Future<Avis> approveAvis(int avisId) async {
    try {
      final response = await apiService.client.put(
        Uri.parse('${ApiService.baseUrl}/avis/admin/$avisId/approve'),
        headers: await apiService.getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return Avis.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to approve avis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error approving avis: $e');
    }
  }

  // Supprimer un avis (admin)
  Future<void> deleteAvis(int avisId) async {
    try {
      final response = await apiService.client.delete(
        Uri.parse('${ApiService.baseUrl}/avis/admin/$avisId'),
        headers: await apiService.getHeaders(includeAuth: true),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete avis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting avis: $e');
    }
  }

  // Récupérer tous les avis (admin)
  Future<List<Avis>> getAllAvis() async {
    try {
      final response = await apiService.client.get(
        Uri.parse('${ApiService.baseUrl}/avis/admin/all'),
        headers: await apiService.getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Avis.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load all avis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching all avis: $e');
    }
  }

  // Récupérer les avis par destination (public)
  Future<List<Avis>> getAvisByDestination(int destinationId) async {
    try {
      final response = await apiService.client.get(
        Uri.parse('${ApiService.baseUrl}/avis/destination/$destinationId'),
        headers: await apiService.getHeaders(includeAuth: false),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Avis.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load avis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching avis: $e');
    }
  }
}
