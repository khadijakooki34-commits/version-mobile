import 'dart:convert';
import 'api_service.dart';
import '../models/index.dart';

class ReservationService {
  final ApiService apiService;

  ReservationService({required this.apiService});

  Future<List<Reservation>> getMyReservations() async {
    try {
      final response = await apiService.getMyReservations();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data is List ? data : (data['content'] as List? ?? []);
        return list
            .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Échec de la récupération des réservations');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réservations: $e');
    }
  }

  Future<Reservation> createReservation(int evenementId) async {
    try {
      final response = await apiService.createReservation(evenementId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Reservation.fromJson(data);
      } else {
        final body = response.body;
        if (body.contains('déjà réservé') || body.contains('already')) {
          throw Exception('Vous avez déjà réservé cet événement.');
        }
        throw Exception('Échec de la création de la réservation: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelReservation(int reservationId) async {
    final response = await apiService.cancelReservation(reservationId);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Échec de l\'annulation');
    }
  }
}
