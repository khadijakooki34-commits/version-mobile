import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';

class MyItinerariesScreen extends StatefulWidget {
  const MyItinerariesScreen({super.key});

  @override
  State<MyItinerariesScreen> createState() => _MyItinerariesScreenState();
}

class _MyItinerariesScreenState extends State<MyItinerariesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      context.read<ItineraryProvider>().fetchItineraries(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes itinéraires')),
        body: const Center(child: Text('Connectez-vous pour voir vos itinéraires')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes itinéraires'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Consumer<ItineraryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.itineraries.isEmpty) {
            return const LoadingWidget(message: 'Chargement...');
          }
          if (provider.error != null && provider.itineraries.isEmpty) {
            return AppErrorWidget(error: provider.error, onRetry: _load);
          }
          if (provider.itineraries.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.route,
              title: 'Aucun itinéraire',
              subtitle: 'Créez un itinéraire pour planifier votre voyage',
              onAction: () => _openCreate(context, user.id),
              actionLabel: 'Créer un itinéraire',
            );
          }
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              itemCount: provider.itineraries.length,
              itemBuilder: (context, index) {
                final it = provider.itineraries[index];
                return _ItineraryCard(
                  itinerary: it,
                  onTap: () => Navigator.of(context).pushNamed(
                    '/itinerary-detail',
                    arguments: it.id,
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openCreate(context, user.id),
              icon: const Icon(Icons.add),
              label: const Text('Nouveau'),
              backgroundColor: AppTheme.primaryColor,
            ),
    );
  }

  void _openCreate(BuildContext context, int userId) {
    Navigator.of(context).pushNamed('/create-itinerary', arguments: userId);
  }
}

class _ItineraryCard extends StatelessWidget {
  final Itinerary itinerary;
  final VoidCallback onTap;

  const _ItineraryCard({required this.itinerary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
          child: const Icon(Icons.route, color: AppTheme.primaryColor),
        ),
        title: Text(
          itinerary.nom,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${itinerary.nombreDestinations} destination(s)'
          '${itinerary.dureeEstimee != null ? ' • ${itinerary.dureeEstimee}' : ''}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
