/// Résumé d'un itinéraire (liste)
class Itinerary {
  final int id;
  final String nom;
  final String? dureeEstimee;
  final DateTime? dateCreation;
  final DateTime? dateModification;
  final double? distanceTotale;
  final int nombreDestinations;
  final bool estOptimise;
  final List<String> destinations; // noms

  Itinerary({
    required this.id,
    required this.nom,
    this.dureeEstimee,
    this.dateCreation,
    this.dateModification,
    this.distanceTotale,
    required this.nombreDestinations,
    this.estOptimise = false,
    required this.destinations,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    final destList = json['destinations'];
    return Itinerary(
      id: (json['id'] is int) ? json['id'] : (json['id'] as num).toInt(),
      nom: json['nom'] ?? '',
      dureeEstimee: json['dureeEstimee'],
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'].toString())
          : null,
      dateModification: json['dateModification'] != null
          ? DateTime.tryParse(json['dateModification'].toString())
          : null,
      distanceTotale: (json['distanceTotale'] as num?)?.toDouble(),
      nombreDestinations: (json['nombreDestinations'] is int)
          ? json['nombreDestinations']
          : (json['nombreDestinations'] as num?)?.toInt() ?? 0,
      estOptimise: json['estOptimise'] ?? false,
      destinations: destList != null && destList is List
          ? List<String>.from(destList.map((e) => e.toString()))
          : [],
    );
  }
}

/// Détail d'un itinéraire (avec destinations avec ordre)
class ItineraryDetail {
  final int id;
  final String nom;
  final String? dureeEstimee;
  final DateTime? dateCreation;
  final DateTime? dateModification;
  final double? distanceTotale;
  final int nombreDestinations;
  final bool estOptimise;
  final List<ItineraryDestination> destinations;

  ItineraryDetail({
    required this.id,
    required this.nom,
    this.dureeEstimee,
    this.dateCreation,
    this.dateModification,
    this.distanceTotale,
    required this.nombreDestinations,
    this.estOptimise = false,
    required this.destinations,
  });

  factory ItineraryDetail.fromJson(Map<String, dynamic> json) {
    final destList = json['destinations'];
    List<ItineraryDestination> dests = [];
    if (destList != null && destList is List) {
      for (final e in destList) {
        if (e is Map<String, dynamic>) {
          dests.add(ItineraryDestination.fromJson(e));
        }
      }
    }
    return ItineraryDetail(
      id: (json['id'] is int) ? json['id'] : (json['id'] as num).toInt(),
      nom: json['nom'] ?? '',
      dureeEstimee: json['dureeEstimee'],
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'].toString())
          : null,
      dateModification: json['dateModification'] != null
          ? DateTime.tryParse(json['dateModification'].toString())
          : null,
      distanceTotale: (json['distanceTotale'] as num?)?.toDouble(),
      nombreDestinations: (json['nombreDestinations'] is int)
          ? json['nombreDestinations']
          : (json['nombreDestinations'] as num?)?.toInt() ?? dests.length,
      estOptimise: json['estOptimise'] ?? false,
      destinations: dests,
    );
  }
}

class ItineraryDestination {
  final int id;
  final String nom;
  final String? type;
  final String? categorie;
  final double? latitude;
  final double? longitude;
  final int ordre;

  ItineraryDestination({
    required this.id,
    required this.nom,
    this.type,
    this.categorie,
    this.latitude,
    this.longitude,
    this.ordre = 0,
  });

  factory ItineraryDestination.fromJson(Map<String, dynamic> json) {
    return ItineraryDestination(
      id: (json['id'] is int) ? json['id'] : (json['id'] as num).toInt(),
      nom: json['nom'] ?? '',
      type: json['type'],
      categorie: json['categorie'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      ordre: (json['ordre'] is int) ? json['ordre'] : (json['ordre'] as num?)?.toInt() ?? 0,
    );
  }
}
