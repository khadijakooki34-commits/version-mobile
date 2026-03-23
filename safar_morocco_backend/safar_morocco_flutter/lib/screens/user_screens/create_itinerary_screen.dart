import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';
import 'dart:math';

class CreateItineraryScreen extends StatefulWidget {
  final int userId;
  final List<int>? initialDestinationIds;

  const CreateItineraryScreen({super.key, required this.userId, this.initialDestinationIds});

  @override
  State<CreateItineraryScreen> createState() => _CreateItineraryScreenState();
}

class _CreateItineraryScreenState extends State<CreateItineraryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late Set<int> _selectedDestinationIds;

  // Calculate distance between two GPS coordinates in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Calculate estimated duration based on distance (assuming average speed of 60 km/h)
  Duration _calculateEstimatedDuration(double distanceKm) {
    final averageSpeedKmh = 60.0; // Average speed including stops
    final hours = distanceKm / averageSpeedKmh;
    return Duration(hours: hours.round());
  }

  // Get total distance and duration for selected destinations
  Map<String, dynamic> _calculateItineraryStats() {
    final destinations = context.read<DestinationProvider>().destinations;
    final selectedDestinations = destinations
        .where((d) => _selectedDestinationIds.contains(d.id))
        .toList();

    debugPrint('=== ITINERARY STATS CALCULATION ===');
    debugPrint('Selected destination IDs: $_selectedDestinationIds');
    debugPrint('Found ${selectedDestinations.length} selected destinations');

    if (selectedDestinations.length < 2) {
      debugPrint('Need at least 2 destinations for calculation');
      return {
        'totalDistance': 0.0,
        'totalDuration': Duration.zero,
        'destinationCount': selectedDestinations.length,
      };
    }

    double totalDistance = 0.0;
    
    // Calculate distance between consecutive destinations
    for (int i = 0; i < selectedDestinations.length - 1; i++) {
      final current = selectedDestinations[i];
      final next = selectedDestinations[i + 1];
      final distance = _calculateDistance(
        current.latitude,
        current.longitude,
        next.latitude,
        next.longitude,
      );
      totalDistance += distance;
      debugPrint('Distance ${current.name} → ${next.name}: ${distance.toStringAsFixed(2)} km');
    }

    final totalDuration = _calculateEstimatedDuration(totalDistance);

    debugPrint('Total distance: ${totalDistance.toStringAsFixed(2)} km');
    debugPrint('Estimated duration: ${_formatDuration(totalDuration)}');

    return {
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
      'destinationCount': selectedDestinations.length,
    };
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  @override
  void initState() {
    super.initState();
    _selectedDestinationIds = Set.from(widget.initialDestinationIds ?? []);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DestinationProvider>().fetchDestinations();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Debug logging before validation
    debugPrint('Form submission - name: "${_nameController.text.trim()}"');
    debugPrint('Form submission - destinations: $_selectedDestinationIds');
    
    if (!_formKey.currentState!.validate()) {
      debugPrint('Form validation failed');
      return;
    }
    
    if (_selectedDestinationIds.isEmpty) {
      debugPrint('No destinations selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez au moins une destination'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    // Debug logging
    final itineraryName = _nameController.text.trim();
    debugPrint('Creating itinerary with name: "$itineraryName"');
    debugPrint('Selected destinations: $_selectedDestinationIds');
    
    // Additional validation
    if (itineraryName.isEmpty) {
      debugPrint('Name is empty after trim');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nom est requis'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    // Clear any previous errors
    context.read<ItineraryProvider>().clearError();
    
    final provider = context.read<ItineraryProvider>();
    final ok = await provider.createItinerary(
      widget.userId,
      nom: itineraryName,
      destinationIds: _selectedDestinationIds.toList(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Itinéraire créé'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      // Show more detailed error message
      String errorMessage = provider.error ?? 'Erreur';
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = context.watch<DestinationProvider>().destinations;
    final stats = _calculateItineraryStats();

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel itinéraire')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'itinéraire',
                border: OutlineInputBorder(),
                hintText: 'Ex: Tour du Sud',
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) {
                debugPrint('Validating name field: "$v"');
                if (v == null || v.trim().isEmpty) {
                  debugPrint('Name validation failed: empty');
                  return 'Le nom est requis';
                }
                if (v.trim().length < 3) {
                  debugPrint('Name validation failed: too short');
                  return 'Min. 3 caractères';
                }
                debugPrint('Name validation passed');
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacingL),
            
            // Itinerary Statistics
            if (stats['destinationCount'] >= 2)
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.route,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Résumé de l\'itinéraire',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.straighten,
                              color: AppTheme.accentColor,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${stats['totalDistance'].toStringAsFixed(1)} km',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentColor,
                              ),
                            ),
                            Text(
                              'Distance totale',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textLightColor,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppTheme.successColor,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDuration(stats['totalDuration']),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.successColor,
                              ),
                            ),
                            Text(
                              'Durée estimée',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textLightColor,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${stats['destinationCount']}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              'Destinations',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textLightColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            Text(
              'Destinations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            if (destinations.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ...destinations.map((d) {
                final selected = _selectedDestinationIds.contains(d.id);
                return CheckboxListTile(
                  title: Text(d.name),
                  subtitle: Text(d.category),
                  value: selected,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedDestinationIds.add(d.id);
                      } else {
                        _selectedDestinationIds.remove(d.id);
                      }
                    });
                  },
                );
              }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: context.watch<ItineraryProvider>().isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: context.watch<ItineraryProvider>().isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Créer l\'itinéraire'),
            ),
          ],
        ),
      ),
    );
  }
}
