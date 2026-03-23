import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
      context.read<ReservationProvider>().fetchMyReservations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    context.read<EventProvider>().fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda culturel', style: TextStyle(fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontSize: 14),
          tabs: const [
            Tab(text: 'Tous les événements'),
            Tab(text: 'À venir'),
          ],
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.error != null) {
            return AppErrorWidget(
              error: provider.error,
              onRetry: _loadEvents,
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildEventsList(provider.events),
              _buildEventsList(provider.upcomingEvents),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventsList(List<Event> events) {
    if (events.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.calendar_today,
        title: 'Aucun événement',
        subtitle: 'Aucun événement disponible pour le moment',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _EventCard(
          event: event,
          onReserve: _onReserve,
          onTap: () => Navigator.of(context).pushNamed('/event-detail', arguments: event.id),
        );
      },
    );
  }

  Future<void> _onReserve(Event event) async {
    final provider = context.read<ReservationProvider>();
    if (provider.hasReservedEvent(event.id)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous avez déjà réservé cet événement.'),
            backgroundColor: AppTheme.infoColor,
          ),
        );
      }
      return;
    }
    final success = await provider.reserveEvent(event.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation confirmée !'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erreur lors de la réservation'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final void Function(Event event) onReserve;
  final VoidCallback? onTap;

  const _EventCard({required this.event, required this.onReserve, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusM),
              topRight: Radius.circular(AppTheme.radiusM),
            ),
            child: CachedNetworkImage(
              imageUrl: resolveImageUrl(event.mainImage),
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: AppTheme.iconSmall,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: AppTheme.spacingXS),
                    Text(
                      DateFormatUtil.formatDate(event.eventDate),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (event.eventTime != null) ...[
                      const SizedBox(width: AppTheme.spacingM),
                      const Icon(
                        Icons.access_time,
                        size: AppTheme.iconSmall,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppTheme.spacingXS),
                      Text(
                        event.eventTime!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
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
                        event.location,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Consumer<ReservationProvider>(
                  builder: (context, resProvider, _) {
                    final alreadyReserved = resProvider.hasReservedEvent(event.id);
                    final isReserving = resProvider.isReserving;
                    return Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: alreadyReserved
                              ? OutlinedButton.icon(
                                  onPressed: null,
                                  icon: const Icon(Icons.check_circle, size: 20),
                                  label: const Text('Déjà réservé'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.successColor,
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: isReserving ? null : () => onReserve(event),
                                  icon: isReserving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.event_available, size: 20),
                                  label: Text(isReserving ? 'Réservation...' : 'Réserver'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                  ),
                                ),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed('/my-reservations'),
                          icon: const Icon(Icons.list, size: 18),
                          label: const Text('Mes réservations'),
                        ),
                      ],
                    );
                  },
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
