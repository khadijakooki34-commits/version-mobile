import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class RecommendationProvider extends ChangeNotifier {
  final RecommendationService recommendationService;

  List<Recommendation> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  RecommendationProvider({required this.recommendationService});

  List<Recommendation> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRecommendations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recommendations = await recommendationService.getRecommendations();
      _recommendations = recommendationService.sortByMatchScore(_recommendations);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Recommendation> getTopRecommendations({int limit = 5}) {
    return _recommendations.take(limit).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
