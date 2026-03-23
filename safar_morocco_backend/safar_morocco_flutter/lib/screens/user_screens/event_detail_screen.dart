import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Event? _event;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final event = await context.read<EventProvider>().getEventById(widget.eventId);
    if (mounted) {
      setState(() {
        _event = event;
        _loading = false;
        _error = event == null ? 'Événement introuvable' : null;
      });
    }
  }

  Future<void> _onReserve() async {
    if (_event == null) return;
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connectez-vous pour réserver')),
      );
      return;
    }
    final resProvider = context.read<ReservationProvider>();
    if (resProvider.hasReservedEvent(_event!.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous avez déjà réservé cet événement.')),
      );
      return;
    }
    final success = await resProvider.reserveEvent(_event!.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Réservation confirmée !' : (resProvider.error ?? 'Erreur')),
        backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail événement')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail événement')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'Non trouvé'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Retour', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      );
    }

    final event = _event!;
    final resProvider = context.watch<ReservationProvider>();
    final alreadyReserved = resProvider.hasReservedEvent(event.id);

    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (event.mainImage.isNotEmpty)
              CachedNetworkImage(
                imageUrl: resolveImageUrl(event.mainImage),
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 220,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 48),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.category != null && event.category!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Chip(
                        label: Text(event.category!),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                      ),
                    ),
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: AppTheme.textLightColor),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatUtil.formatDate(event.eventDate),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  if (event.location.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20, color: AppTheme.textLightColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.location,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppTheme.spacingL),
                  if (event.description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: alreadyReserved
                        ? OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Réservé', style: TextStyle(fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.successColor,
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: resProvider.isReserving ? null : _onReserve,
                            icon: resProvider.isReserving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.event_available),
                            label: Text(resProvider.isReserving ? 'Réservation...' : 'Réserver', style: const TextStyle(fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
