import 'dart:convert';
import 'api_service.dart';
import '../models/index.dart';

class AdminService {
  final ApiService apiService;

  AdminService({required this.apiService});

  Future<List<User>> getUsers({int page = 0, int size = 10}) async {
    try {
      final response = await apiService.getAdminUsers(page: page, size: size);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = (data['content'] as List)
            .map((e) => User.fromJson(e))
            .toList();
        return users;
      } else {
        throw Exception('Échec de la récupération des utilisateurs');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des utilisateurs: $e');
    }
  }

  Future<void> blockUser(int userId) async {
    try {
      final response = await apiService.blockUser(userId);

      if (response.statusCode != 200) {
        throw Exception('Échec du blocage de l\'utilisateur');
      }
    } catch (e) {
      throw Exception('Erreur lors du blocage de l\'utilisateur: $e');
    }
  }

  Future<void> changeUserRole(int userId, String role) async {
    try {
      final response = await apiService.changeUserRole(userId, role);

      if (response.statusCode != 200) {
        throw Exception(
          'Échec du changement de rôle d\'utilisateur (status: ${response.statusCode}) ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erreur lors du changement de rôle d\'utilisateur: $e');
    }
  }

  Future<void> deleteDestination(int destinationId) async {
    try {
      final response = await apiService.deleteDestination(destinationId);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Échec de la suppression de la destination');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la destination: $e');
    }
  }

  Future<Statistics> getStatistics() async {
    try {
      final response = await apiService.getAdminStatistics();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Statistics.fromJson(data);
      } else {
        throw Exception('Échec de la récupération des statistiques');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
}
