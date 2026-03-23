import '../utils/image_url_helper.dart';

class Destination {
  final int id;
  final String name;
  final String description;
  final String histoire;
  final String location;
  final double latitude;
  final double longitude;
  final String category;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final String? openingHours;
  final String? entranceFee;
  final DateTime createdAt;
  final DateTime updatedAt;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.histoire,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.images,
    this.openingHours,
    this.entranceFee,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    // Backend uses French field names: nom, categorie, type
    // Also handles nested relationships: medias, avis
    
    // Handle id - could be int or Long (from backend)
    int idValue = 0;
    if (json['id'] != null) {
      if (json['id'] is int) {
        idValue = json['id'];
      } else if (json['id'] is num) {
        idValue = json['id'].toInt();
      } else {
        idValue = int.tryParse(json['id'].toString()) ?? 0;
      }
    }
    
    // Handle name - backend uses 'nom'
    final nameValue = json['name']?.toString() ?? json['nom']?.toString() ?? '';
    
    // Handle category - backend uses 'categorie', also check 'type'
    final categoryValue = json['category']?.toString() ?? 
                         json['categorie']?.toString() ?? 
                         json['type']?.toString() ?? '';
    
    // Handle images from medias relationship
    // Backend returns relative paths like /uploads/filename.jpg - resolve to full URLs
    List<String> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = (json['images'] as List).map((e) {
        String raw = '';
        if (e is String) {
          raw = e;
        } else if (e is Map) raw = e['url']?.toString() ?? e['chemin']?.toString() ?? '';
        else raw = e.toString();
        return resolveImageUrl(raw);
      }).where((e) => e.isNotEmpty).toList();
    } else if (json['medias'] != null && json['medias'] is List) {
      imagesList = (json['medias'] as List).map((e) {
        String raw = '';
        if (e is Map) {
          raw = e['url']?.toString() ?? 
                e['chemin']?.toString() ?? 
                e['nom']?.toString() ?? '';
        } else {
          raw = e.toString();
        }
        return resolveImageUrl(raw);
      }).where((e) => e.isNotEmpty).toList();
    }
    
    // Handle rating - calculate from avis (reviews) if not directly provided
    double ratingValue = 0.0;
    if (json['rating'] != null) {
      ratingValue = _parseDouble(json['rating']);
    } else if (json['avis'] != null && json['avis'] is List) {
      // Calculate average rating from reviews
      final avis = json['avis'] as List;
      if (avis.isNotEmpty) {
        double sum = 0.0;
        int count = 0;
        for (var avisItem in avis) {
          if (avisItem is Map && avisItem['note'] != null) {
            sum += _parseDouble(avisItem['note']);
            count++;
          }
        }
        if (count > 0) ratingValue = sum / count;
      }
    }
    
    // Handle reviewCount - count from avis if not directly provided
    int reviewCountValue = 0;
    if (json['reviewCount'] != null) {
      if (json['reviewCount'] is int) {
        reviewCountValue = json['reviewCount'];
      } else {
        reviewCountValue = int.tryParse(json['reviewCount'].toString()) ?? 0;
      }
    } else if (json['avis'] != null && json['avis'] is List) {
      reviewCountValue = (json['avis'] as List).length;
    }
    
    // Handle location - backend doesn't have location field, use coordinates or empty
    final locationValue = json['location']?.toString() ?? 
                         json['lieu']?.toString() ?? 
                         (json['latitude'] != null && json['longitude'] != null
                             ? '${json['latitude']}, ${json['longitude']}'
                             : '');
    
    return Destination(
      id: idValue,
      name: nameValue,
      description: json['description']?.toString() ?? '',
      histoire: json['histoire']?.toString() ?? json['historicalDescription']?.toString() ?? '',
      location: locationValue,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      category: categoryValue,
      rating: ratingValue,
      reviewCount: reviewCountValue,
      images: imagesList,
      openingHours: json['openingHours']?.toString() ?? json['heuresOuverture']?.toString(),
      entranceFee: json['entranceFee']?.toString() ?? json['prixEntree']?.toString(),
      createdAt: _parseDateTime(json['createdAt'] ?? json['dateCreation']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['dateModification']),
    );
  }
  
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
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
      'name': name,
      'description': description,
      'histoire': histoire,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'images': images,
      'openingHours': openingHours,
      'entranceFee': entranceFee,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get mainImage => images.isNotEmpty ? images[0] : '';
}

class DestinationFilter {
  final String? category;
  final double? minRating;
  final String? searchQuery;

  DestinationFilter({
    this.category,
    this.minRating,
    this.searchQuery,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (category != null && category!.isNotEmpty) {
      params['category'] = category!;
    }
    if (minRating != null) {
      params['minRating'] = minRating.toString();
    }
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery!;
    }
    return params;
  }
}
