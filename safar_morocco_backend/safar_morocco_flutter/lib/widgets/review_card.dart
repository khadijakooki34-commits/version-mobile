import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/index.dart';
import '../utils/index.dart';
import 'common_widgets.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (review.userProfileImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                    child: CachedNetworkImage(
                      imageUrl: review.userProfileImage!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppTheme.secondaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppTheme.secondaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        review.userEmail,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: AppTheme.iconSmall,
                    color: AppTheme.accentColor,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Text(
                  review.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              review.comment,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: null,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              DateFormatUtil.formatRelativeTime(review.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewsSection extends StatelessWidget {
  final List<Review> reviews;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onWriteReview;

  const ReviewsSection({
    super.key,
    required this.reviews,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.onWriteReview,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingWidget(message: 'Chargement des avis...');
    }

    if (error != null) {
      return AppErrorWidget(
        error: error,
        onRetry: onRetry,
      );
    }

    if (reviews.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.rate_review,
        title: 'Aucun avis pour l\'instant',
        subtitle: 'Soyez le premier à donner votre avis sur cette destination',
        onAction: onWriteReview,
        actionLabel: 'Rédiger un avis',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Avis (${reviews.length})',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (onWriteReview != null)
              ElevatedButton.icon(
                onPressed: onWriteReview,
                icon: const Icon(Icons.add),
                label: const Text('Donner un avis'),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        ...reviews.map((review) => ReviewCard(review: review)),
      ],
    );
  }
}
