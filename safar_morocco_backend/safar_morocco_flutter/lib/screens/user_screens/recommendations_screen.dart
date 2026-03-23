import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecommendations();
    });
  }

  Future<void> _loadRecommendations() async {
    context.read<RecommendationProvider>().fetchRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended for You'),
      ),
      body: Consumer<RecommendationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.error != null) {
            return AppErrorWidget(
              error: provider.error,
              onRetry: _loadRecommendations,
            );
          }

          if (provider.recommendations.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.explore,
              title: 'No Recommendations Yet',
              subtitle: 'Check back later for personalized recommendations',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            itemCount: provider.recommendations.length,
            itemBuilder: (context, index) {
              final rec = provider.recommendations[index];
              return _RecommendationCard(recommendation: rec);
            },
          );
        },
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;

  const _RecommendationCard({
    required this.recommendation,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.destinationName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppTheme.spacingXS),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: AppTheme.iconSmall,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: AppTheme.spacingXS),
                          Expanded(
                            child: Text(
                              recommendation.destinationLocation,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        recommendation.percentageScore,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Match',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Why recommended:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              recommendation.reason,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (recommendation.tags.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingM),
              Wrap(
                spacing: AppTheme.spacingS,
                children: recommendation.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: AppTheme.spacingM),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/destination-details',
                    arguments: recommendation.destinationId,
                  );
                },
                child: const Text('View Destination'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
