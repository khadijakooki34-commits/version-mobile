import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';
import '../../services/openstreetmap_service.dart';
import '../../models/itinerary_model.dart';

class ItineraryDetailScreen extends StatefulWidget {
  final int itineraryId;

  const ItineraryDetailScreen({super.key, required this.itineraryId});

  @override
  State<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends State<ItineraryDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      context.read<ItineraryProvider>().fetchItineraryDetail(widget.itineraryId, user.id);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet itinéraire ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final provider = context.read<ItineraryProvider>();
    final success = await provider.deleteItinerary(widget.itineraryId, user.id);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Itinéraire supprimé'), backgroundColor: AppTheme.successColor),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Erreur'), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail itinéraire')),
        body: const Center(child: Text('Non autorisé')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail itinéraire'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'optimize') _optimize();
              if (v == 'delete') _delete();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'optimize', child: Text('Optimiser l\'ordre')),
              const PopupMenuItem(value: 'delete', child: Text('Supprimer', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: Consumer<ItineraryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.currentDetail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.currentDetail == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error ?? 'Erreur'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
                ],
              ),
            );
          }
          final detail = provider.currentDetail;
          if (detail == null) {
            return const Center(child: Text('Itinéraire introuvable'));
          }

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.nom,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (detail.dureeEstimee != null) ...[
                        const SizedBox(height: 4),
                        Text('Durée estimée: ${detail.dureeEstimee}', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                      if (detail.distanceTotale != null) ...[
                        const SizedBox(height: 4),
                        Text('Distance: ${detail.distanceTotale!.toStringAsFixed(0)} km', style: Theme.of(context).textTheme.bodySmall),
                      ],
                      if (detail.estOptimise)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Chip(
                            label: const Text('Optimisé'),
                            backgroundColor: Colors.green[100],
                            avatar: const Icon(Icons.check_circle, size: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              _buildMapSection(detail),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'Destinations (${detail.destinations.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacingS),
              ...detail.destinations.asMap().entries.map((entry) {
                final index = entry.key;
                final destination = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    title: Text(destination.nom),
                    subtitle: destination.categorie != null ? Text(destination.categorie!) : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.navigation, color: AppTheme.primaryColor),
                      onPressed: () async {
                        if (destination.latitude != null && destination.longitude != null) {
                          final success = await OpenStreetMapService.openNavigation(
                            latitude: destination.latitude!,
                            longitude: destination.longitude!,
                            label: destination.nom,
                          );
                          if (!success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Impossible d\'ouvrir Google Maps'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Future<void> _optimize() async {
    if (!mounted) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final provider = context.read<ItineraryProvider>();
    final ok = await provider.optimizeItinerary(widget.itineraryId, user.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Itinéraire optimisé' : (provider.error ?? 'Erreur')),
        backgroundColor: ok ? AppTheme.successColor : AppTheme.errorColor,
      ),
    );
  }

  Widget _buildMapSection(ItineraryDetail detail) {
    if (detail.destinations.isEmpty || 
        detail.destinations.any((d) => d.latitude == null || d.longitude == null)) {
      return const SizedBox.shrink();
    }

    final destinationsWithCoords = detail.destinations.where((d) => 
        d.latitude != null && d.longitude != null).toList();

    if (destinationsWithCoords.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Aucune coordonnée disponible pour les destinations'),
        ),
      );
    }

    final markers = OpenStreetMapService.createDestinationMarkers(
      destinationsWithCoords.map((d) => {
        'id': d.id,
        'nom': d.nom,
        'description': d.categorie ?? 'Destination',
        'latitude': d.latitude!,
        'longitude': d.longitude!,
        'categorie': d.categorie ?? '',
      }).toList(),
    );

    final polyline = OpenStreetMapService.createPolylineFromDestinations(
      id: detail.id.toString(),
      destinations: destinationsWithCoords.map((d) => {
        'id': d.id,
        'nom': d.nom,
        'description': d.categorie ?? 'Destination',
        'latitude': d.latitude!,
        'longitude': d.longitude!,
        'categorie': d.categorie ?? '',
      }).toList(),
    );

    final bounds = OpenStreetMapService.calculateBounds(
      destinationsWithCoords.map((d) => LatLng(d.latitude!, d.longitude!)).toList(),
    );

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Text(
              'Carte de l\'itinéraire',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 300,
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
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
                markers: markers,
                polylines: [polyline],
                center: LatLng(
                  (bounds.south + bounds.north) / 2,
                  (bounds.west + bounds.east) / 2,
                ),
                zoom: 10.0,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (destinationsWithCoords.isNotEmpty) {
                    // Convertir les destinations en Map pour la navigation
                    final destinationsMap = destinationsWithCoords.map((dest) => {
                      'latitude': dest.latitude,
                      'longitude': dest.longitude,
                      'nom': dest.nom,
                    }).toList();
                    
                    final success = await OpenStreetMapService.openItineraryNavigation(
                      destinations: destinationsMap,
                    );
                    
                    if (!success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Impossible d\'ouvrir OpenStreetMap'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.navigation),
                label: const Text('Commencer la navigation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
        ],
      ),
    );
  }
}
