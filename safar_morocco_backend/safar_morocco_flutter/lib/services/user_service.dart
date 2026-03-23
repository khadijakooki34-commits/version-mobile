import 'dart:convert';
import 'api_service.dart';
import '../models/index.dart';

class UserService {
  final ApiService apiService;

  UserService({required this.apiService});

  Future<User> getUserProfile() async {
    try {
      final response = await apiService.getUserProfile();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns UtilisateurDTO with 'nom', 'telephone', 'photoUrl', etc.
        return User.fromBackendJson(data);
      } else {
        final errorBody = response.body;
        throw Exception('Échec de la récupération du profil: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? profileImage,
  }) async {
    try {
      final response = await apiService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profileImage: profileImage,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns UtilisateurDTO with 'nom', 'telephone', 'photoUrl', etc.
        return User.fromBackendJson(data);
      } else {
        final errorBody = response.body;
        throw Exception('Échec de la mise à jour du profil: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }
}
