class Recommendation {
  final int id;
  final String title;
  final String description;
  final int destinationId;
  final String destinationName;
  final String destinationLocation;
  final double matchScore;
  final String reason;
  final List<String> tags;
  final String? image;
  final DateTime createdAt;

  Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.destinationId,
    required this.destinationName,
    required this.destinationLocation,
    required this.matchScore,
    required this.reason,
    required this.tags,
    this.image,
    required this.createdAt,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      destinationId: json['destinationId'] ?? 0,
      destinationName: json['destinationName'] ?? '',
      destinationLocation: json['destinationLocation'] ?? '',
      matchScore: (json['matchScore'] ?? 0.0).toDouble(),
      reason: json['reason'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      image: json['image'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'destinationId': destinationId,
      'destinationName': destinationName,
      'destinationLocation': destinationLocation,
      'matchScore': matchScore,
      'reason': reason,
      'tags': tags,
      'image': image,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get percentageScore => '${(matchScore * 100).toStringAsFixed(0)}%';
}
