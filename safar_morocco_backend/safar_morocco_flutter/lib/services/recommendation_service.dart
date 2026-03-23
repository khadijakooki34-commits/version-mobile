import 'dart:convert';
import 'api_service.dart';
import '../models/index.dart';

class RecommendationService {
  final ApiService apiService;

  RecommendationService({required this.apiService});

  Future<List<Recommendation>> getRecommendations() async {
    try {
      final response = await apiService.getRecommendations();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recommendations = (data['content'] as List)
            .map((e) => Recommendation.fromJson(e))
            .toList();
        return recommendations;
      } else {
        throw Exception('Échec de la récupération des recommandations');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des recommandations: $e');
    }
  }

  List<Recommendation> sortByMatchScore(List<Recommendation> recommendations) {
    final sorted = [...recommendations];
    sorted.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return sorted;
  }

  List<Recommendation> filterByMinScore(
    List<Recommendation> recommendations,
    double minScore,
  ) {
    return recommendations.where((r) => r.matchScore >= minScore).toList();
  }
}
