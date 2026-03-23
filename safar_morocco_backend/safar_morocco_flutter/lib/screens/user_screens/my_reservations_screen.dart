import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ReservationProvider>().fetchMyReservations();
    });
  }

  /// Rafraîchit la liste au retour sur l'écran (ex. après avoir réservé depuis l'agenda).
  Future<void> _goToAddReservation() async {
    await Navigator.of(context).pushNamed('/events');
    if (mounted) _refresh();
  }

  Future<void> _refresh() async {
    await context.read<ReservationProvider>().fetchMyReservations();
  }

  Future<void> _cancelReservation(BuildContext context, int reservationId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la réservation ?'),
        content: const Text('Vous pourrez réserver à nouveau si des places sont disponibles.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Non')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final success = await context.read<ReservationProvider>().cancelReservation(reservationId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Réservation annulée' : (context.read<ReservationProvider>().error ?? 'Erreur')),
        backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations', style: TextStyle(fontSize: 18)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _refresh,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.reservations.isEmpty) {
            return const LoadingWidget(message: 'Chargement des réservations...');
          }

          if (provider.error != null && provider.reservations.isEmpty) {
            return AppErrorWidget(
              error: provider.error,
              onRetry: _refresh,
            );
          }

          if (provider.reservations.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.event_busy,
              title: 'Aucune réservation',
              subtitle: 'Réservez des événements depuis l\'agenda culturel',
              onAction: () => Navigator.of(context).pushReplacementNamed('/events'),
              actionLabel: 'Voir les événements',
            );
          }

          final confirmedList = provider.reservations.where((r) => r.status == 'CONFIRMED').toList();
          if (confirmedList.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.event_busy,
              title: 'Aucune réservation active',
              subtitle: 'Réservez des événements depuis l\'agenda culturel',
              onAction: () => Navigator.of(context).pushReplacementNamed('/events'),
              actionLabel: 'Voir les événements',
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: OutlinedButton.icon(
                    onPressed: _goToAddReservation,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Réserver un autre événement'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                      side: const BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                ...List.generate(confirmedList.length, (index) {
                  final reservation = confirmedList[index];
                  return _ReservationCard(
                    reservation: reservation,
                    onCancel: () => _cancelReservation(context, reservation.id),
                    onTap: () => Navigator.of(context).pushNamed(
                      '/event-detail',
                      arguments: reservation.event.id,
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  const _ReservationCard({required this.reservation, this.onCancel, this.onTap});

  @override
  Widget build(BuildContext context) {
    final event = reservation.event;
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          if (event.mainImage.isNotEmpty)
            CachedNetworkImage(
              imageUrl: resolveImageUrl(event.mainImage),
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 160,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 160,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 48),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: reservation.status == 'CONFIRMÉ'
                            ? AppTheme.successColor.withOpacity(0.15)
                            : AppTheme.warningColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        reservation.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: reservation.status == 'CONFIRMÉ'
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Réservé le ${DateFormatUtil.formatDate(reservation.dateReservation)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textHintColor,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: AppTheme.iconSmall, color: AppTheme.textLightColor),
                    const SizedBox(width: AppTheme.spacingXS),
                    Text(
                      DateFormatUtil.formatDate(event.eventDate),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (event.location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: AppTheme.iconSmall, color: AppTheme.textLightColor),
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
                ],
                if (onCancel != null) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel, size: 20),
                    label: const Text('Annuler la réservation'),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
