import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';
import '../../services/openstreetmap_service.dart';

class DestinationDetailsScreen extends StatefulWidget {
  final int destinationId;

  const DestinationDetailsScreen({
    super.key,
    required this.destinationId,
  });

  @override
  State<DestinationDetailsScreen> createState() => _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadDestinationDetails();
        _loadReviews();
        _checkFavoriteStatus();
        _loadWeather();
      }
    });
  }

  Future<void> _loadDestinationDetails() async {
    if (mounted) {
      context.read<DestinationProvider>().getDestinationById(widget.destinationId);
    }
  }

  Future<void> _loadReviews() async {
    if (mounted) {
      context.read<ReviewProvider>().fetchReviewsByDestination(widget.destinationId);
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (mounted) {
      await context.read<FavoriteProvider>().checkFavorite(widget.destinationId);
    }
  }

  Future<void> _loadWeather() async {
    if (mounted) {
      // Also load forecast for better UX
      await context.read<WeatherProvider>().fetchWeatherForDestination(widget.destinationId);
      // Load forecast in background
      context.read<WeatherProvider>().fetchForecastForDestination(widget.destinationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la destination'),
      ),
      body: Consumer3<DestinationProvider, ReviewProvider, FavoriteProvider>(
        builder: (context, destinationProvider, reviewProvider, favoriteProvider, _) {
          if (destinationProvider.isLoading) {
            return const LoadingWidget();
          }

          if (destinationProvider.error != null) {
            return AppErrorWidget(
              error: destinationProvider.error,
              onRetry: _loadDestinationDetails,
            );
          }

          final destination = destinationProvider.selectedDestination;
          if (destination == null) {
            return const EmptyStateWidget(
              icon: Icons.location_off,
              title: 'Destination introuvable',
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSlider(destination),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, destination),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildDetails(context, destination),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildMapSection(context, destination),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildWeatherSection(context),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildActionButtons(context),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildDescriptionSection(context, destination),
                      const SizedBox(height: AppTheme.spacingM),
                      ReviewsSection(
                        reviews: reviewProvider.reviews,
                        isLoading: reviewProvider.isLoading,
                        error: reviewProvider.error,
                        onRetry: _loadReviews,
                        onWriteReview: () {
                          Navigator.of(context).pushNamed(
                            '/write-review',
                            arguments: destination.id,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSlider(Destination destination) {
    if (destination.images.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 50),
        ),
      );
    }

    return Stack(
      children: [
        // Utiliser un PageView pour afficher toutes les images
        SizedBox(
          height: 250,
          child: PageView.builder(
            itemCount: destination.images.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: destination.images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              );
            },
          ),
        ),
        // Indicateur de pages et compteur de photos
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${destination.images.length} photos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                // Indicateurs de pages
                Row(
                  children: List.generate(
                    destination.images.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == 0 ? Colors.white : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Destination destination) {
    return Column(
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
                    destination.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 20, // Réduit pour mobile
                      fontWeight: FontWeight.bold,
                    ),
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
                          destination.location,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11, // Réduit pour mobile
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: AppTheme.iconSmall, // Utilise iconSmall au lieu de iconS
                        color: Colors.white,
                      ),
                      Text(
                        destination.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // Réduit de 16 à 14
                        ),
                      ),
                      Text(
                        '${destination.reviewCount} avis',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10, // Réduit de 12 à 10
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context, Destination destination) {
    return Column(
      children: [
        if (destination.category.isNotEmpty)
          _DetailItem(
            icon: Icons.category,
            label: 'Catégorie',
            value: destination.category,
          ),
        if (destination.openingHours != null)
          _DetailItem(
            icon: Icons.access_time,
            label: 'Heures d\'ouverture',
            value: destination.openingHours!,
          ),
        if (destination.entranceFee != null)
          _DetailItem(
            icon: Icons.money,
            label: 'Frais d\'entrée',
            value: destination.entranceFee!,
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, _) {
        final isFavorite = favoriteProvider.isFavorite(widget.destinationId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/write-review',
                        arguments: widget.destinationId,
                      );
                    },
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Avis', style: TextStyle(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await favoriteProvider.toggleFavorite(widget.destinationId);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavorite
                                    ? 'Retiré des favoris'
                                    : 'Ajouté aux favoris'
                              ),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                        }
                      }
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    label: Text(isFavorite ? 'Favori' : 'Favori', style: const TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isFavorite ? Colors.red : null,
                      side: BorderSide(
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            OutlinedButton.icon(
              onPressed: () => _showAddToItinerarySheet(context),
              icon: const Icon(Icons.route),
              label: const Text('Ajouter à itinéraire', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddToItinerarySheet(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connectez-vous pour gérer vos itinéraires')),
      );
      return;
    }
    final itineraryProvider = context.read<ItineraryProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      itineraryProvider.fetchItineraries(user.id);
      if (context.mounted) {
        showModalBottomSheet<void>(
          context: context,
          builder: (ctx) => _AddToItinerarySheetContent(
            userId: user.id,
            destinationId: widget.destinationId,
          ),
        );
      }
    });
  }

  Widget _buildDescriptionSection(BuildContext context, Destination destination) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'À propos de cette destination',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingM),
        // Afficher la description
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                destination.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        // Afficher l'historique si disponible
        if (destination.histoire.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.history,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Historique',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  destination.histoire,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeatherSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.cloud_outlined,
              color: AppTheme.primaryColor,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'Météo',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        WeatherWidget(
          destinationId: widget.destinationId,
          destinationName: '', // Will be fetched from destination
          showForecast: true,
        ),
      ],
    );
  }

  Widget _buildMapSection(BuildContext context, Destination destination) {
    if (destination.latitude == false || destination.longitude == false) {
      return const SizedBox.shrink();
    }

    final marker = OpenStreetMapService.createDestinationMarker(
      id: destination.id.toString(),
      title: destination.name,
      description: destination.category,
      latitude: destination.latitude,
      longitude: destination.longitude,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Localisation',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            child: OpenStreetMapService.createMap(
                markers: [marker],
                center: LatLng(destination.latitude, destination.longitude),
                zoom: 15.0,
              ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final success = await OpenStreetMapService.openNavigation(
                latitude: destination.latitude,
                longitude: destination.longitude,
                label: destination.name,
              );
              
              if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Impossible d\'ouvrir OpenStreetMap'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.navigation),
            label: const Text('Y aller avec OpenStreetMap'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// Widget pour les détails
class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: AppTheme.iconM,
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pour le contenu de la feuille modale
class _AddToItinerarySheetContent extends StatelessWidget {
  final int userId;
  final int destinationId;

  const _AddToItinerarySheetContent({required this.userId, required this.destinationId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ItineraryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.itineraries.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            Text(
              'Ajouter à un itinéraire',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ...provider.itineraries.map((it) {
              return ListTile(
                leading: const Icon(Icons.route),
                title: Text(it.nom),
                subtitle: Text('${it.nombreDestinations} destination(s)'),
                onTap: () async {
                  Navigator.pop(context);
                  final ok = await provider.addDestination(
                    it.id,
                    destinationId,
                    userId,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok ? 'Destination ajoutée à "${it.nom}"' : (provider.error ?? 'Erreur'),
                        ),
                        backgroundColor: ok ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                    );
                  }
                },
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Créer un itinéraire avec cette destination'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(
                  '/create-itinerary',
                  arguments: {'userId': userId, 'destinationId': destinationId},
                );
              },
            ),
          ],
        );
      },
    );
  }
}
