import 'dart:convert';
import 'api_service.dart';
import '../models/index.dart';

class ReviewService {
  final ApiService apiService;

  ReviewService({required this.apiService});

  Future<Review> createReview({
    required int destinationId,
    required double rating,
    required String comment,
  }) async {
    try {
      final response = await apiService.createReview(
        destinationId: destinationId,
        rating: rating,
        comment: comment,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Review.fromJson(data);
      } else {
        throw Exception('Échec de la création de l\'avis');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'avis: $e');
    }
  }

  Future<List<Review>> getReviewsByDestination(int destinationId) async {
    try {
      final response = await apiService.getReviewsByDestination(destinationId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns List<Avis> directly, not paginated
        List<Review> reviews;
        if (data is List) {
          reviews = data.map((e) => Review.fromJson(e)).toList();
        } else if (data['content'] != null) {
          reviews = (data['content'] as List)
              .map((e) => Review.fromJson(e))
              .toList();
        } else {
          reviews = [];
        }
        return reviews;
      } else {
        throw Exception('Échec de la récupération des avis');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des avis: $e');
    }
  }
}
