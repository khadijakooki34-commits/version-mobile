class Review {
  final int id;
  final int destinationId;
  final int userId;
  final String userName;
  final String userEmail;
  final String? userProfileImage;
  final double rating;
  final String comment;
  final String status; // APPROVED, PENDING, REJECTED
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.destinationId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userProfileImage,
    required this.rating,
    required this.comment,
    this.status = 'APPROVED', // Valeur par défaut
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Backend uses: note (not rating), commentaire (not comment), auteur (user object)
    final auteur = json['auteur'] ?? {};
    final destination = json['destination'] ?? {};
    
    return Review(
      id: (json['id'] is int) ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      destinationId: (destination['id'] is int) 
          ? destination['id'] 
          : (int.tryParse(destination['id']?.toString() ?? '0') ?? 0),
      userId: (auteur['id'] is int) 
          ? auteur['id'] 
          : (int.tryParse(auteur['id']?.toString() ?? '0') ?? 0),
      userName: auteur['nom']?.toString() ?? auteur['name']?.toString() ?? '',
      userEmail: auteur['email']?.toString() ?? '',
      userProfileImage: auteur['photoUrl']?.toString() ?? auteur['profileImage']?.toString(),
      rating: (json['note'] ?? json['rating'] ?? 0).toDouble(),
      comment: json['commentaire']?.toString() ?? json['comment']?.toString() ?? '',
      status: json['status']?.toString() ?? 'APPROVED',
      createdAt: _parseDateTime(json['datePublication'] ?? json['createdAt']),
      updatedAt: _parseDateTime(json['dateModification'] ?? json['updatedAt'] ?? json['datePublication'] ?? json['createdAt']),
    );
  }
  
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destinationId': destinationId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userProfileImage': userProfileImage,
      'rating': rating,
      'comment': comment,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Méthode copyWith pour permettre la modification d'objets
  Review copyWith({
    int? id,
    int? destinationId,
    int? userId,
    String? userName,
    String? userEmail,
    String? userProfileImage,
    double? rating,
    String? comment,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      destinationId: destinationId ?? this.destinationId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Alias pour compatibilité avec le backend français
  static Review fromAvisJson(Map<String, dynamic> json) => Review.fromJson(json);
}

// Alias pour la compatibilité
typedef Avis = Review;

class CreateReviewRequest {
  final int destinationId;
  final double rating;
  final String comment;

  CreateReviewRequest({
    required this.destinationId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'destinationId': destinationId,
      'rating': rating,
      'comment': comment,
    };
  }
}
