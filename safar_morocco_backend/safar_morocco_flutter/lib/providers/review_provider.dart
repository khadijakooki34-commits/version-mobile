import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService reviewService;

  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _error;

  ReviewProvider({required this.reviewService});

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchReviewsByDestination(int destinationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviews = await reviewService.getReviewsByDestination(destinationId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createReview({
    required int destinationId,
    required double rating,
    required String comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final review = await reviewService.createReview(
        destinationId: destinationId,
        rating: rating,
        comment: comment,
      );
      _reviews.add(review);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double getAverageRating() {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold<double>(0.0, (sum, review) => sum + review.rating);
    return total / _reviews.length;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
