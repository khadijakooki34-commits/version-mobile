class Event {
  final int id;
  final String title;
  final String description;
  final String location;
  final DateTime eventDate;
  final String? eventTime;
  final String? category;
  final List<String> images;
  final String? organizer;
  final String? contactEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.eventDate,
    this.eventTime,
    this.category,
    required this.images,
    this.organizer,
    this.contactEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Backend (evenements) uses: nom, dateDebut, dateFin, lieu, typeEvenement, imageUrl
  factory Event.fromJson(Map<String, dynamic> json) {
    final nom = json['nom'] ?? json['title'] ?? '';
    final dateDebut = json['dateDebut'] ?? json['eventDate'];
    final lieu = json['lieu'] ?? json['location'] ?? '';
    final imageUrl = json['imageUrl'];
    final images = json['images'] != null
        ? List<String>.from(json['images'] as List)
        : (imageUrl != null && imageUrl.toString().isNotEmpty ? [imageUrl.toString()] : <String>[]);
    DateTime eventDate = DateTime.now();
    if (dateDebut != null) {
      try {
        eventDate = DateTime.parse(dateDebut.toString());
      } catch (_) {}
    }
    return Event(
      id: json['id'] ?? 0,
      title: nom,
      description: json['description'] ?? '',
      location: lieu,
      eventDate: eventDate,
      eventTime: json['eventTime'],
      category: json['typeEvenement'] ?? json['category'],
      images: images,
      organizer: json['organizer'],
      contactEmail: json['contactEmail'],
      createdAt: dateDebut != null ? (eventDate) : DateTime.now(),
      updatedAt: json['dateFin'] != null ? DateTime.tryParse(json['dateFin'].toString()) ?? eventDate : eventDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'eventDate': eventDate.toIso8601String(),
      'eventTime': eventTime,
      'category': category,
      'images': images,
      'organizer': organizer,
      'contactEmail': contactEmail,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get mainImage => images.isNotEmpty ? images[0] : '';

  bool get isUpcoming => eventDate.isAfter(DateTime.now());
}
