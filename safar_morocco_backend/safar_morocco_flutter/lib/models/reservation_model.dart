import 'event_model.dart';

class Reservation {
  final int id;
  final Event event;
  final DateTime dateReservation;
  final String status;

  Reservation({
    required this.id,
    required this.event,
    required this.dateReservation,
    required this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final evenement = json['evenement'];
    final event = evenement != null
        ? Event.fromJson(evenement as Map<String, dynamic>)
        : Event.fromJson({
            'id': json['evenementId'],
            'nom': '',
            'description': '',
            'lieu': '',
            'dateDebut': json['dateReservation'],
          });

    DateTime dateReservation = DateTime.now();
    final dr = json['dateReservation'];
    if (dr != null) {
      try {
        dateReservation = DateTime.parse(dr.toString());
      } catch (_) {}
    }

    return Reservation(
      id: json['id'] ?? 0,
      event: event,
      dateReservation: dateReservation,
      status: json['status'] ?? 'CONFIRMED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'evenement': event.toJson(),
      'dateReservation': dateReservation.toIso8601String(),
      'status': status,
    };
  }
}
