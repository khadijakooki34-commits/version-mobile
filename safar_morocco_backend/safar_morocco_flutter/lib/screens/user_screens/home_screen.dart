import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedViewMode = 0; // 0 for list, 1 for grid

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDestinations();
    });
  }

  Future<void> _loadDestinations() async {
    if (mounted) {
      context.read<DestinationProvider>().fetchDestinations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Découvrir les destinations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: context.read<AuthProvider>().isAdmin,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 20),
            onPressed: () {
              Navigator.of(context).pushNamed('/search-destinations');
            },
            tooltip: 'Rechercher',
          ),
          if (context.read<AuthProvider>().isAdmin)
            IconButton(
              icon: Icon(
                _selectedViewMode == 0 ? Icons.view_list : Icons.grid_view,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _selectedViewMode = _selectedViewMode == 0 ? 1 : 0;
                });
              },
              tooltip: _selectedViewMode == 0 ? 'Vue Grille' : 'Vue Liste',
            ),
          IconButton(
            icon: const Icon(Icons.person, size: 20),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
            tooltip: 'Profil',
          ),
        ],
      ),
      body: Consumer<DestinationProvider>(
        builder: (context, destinationProvider, _) {
          if (destinationProvider.isLoading && destinationProvider.destinations.isEmpty) {
            return const LoadingWidget(message: 'Chargement des destinations...');
          }

          if (destinationProvider.error != null && destinationProvider.destinations.isEmpty) {
            return AppErrorWidget(
              error: destinationProvider.error,
              onRetry: _loadDestinations,
            );
          }

          if (destinationProvider.destinations.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.location_city,
              title: 'Aucune destination trouvée',
              subtitle: 'Essayez d\'ajuster vos filtres de recherche',
              onAction: () {
                Navigator.of(context).pushNamed('/search-destinations');
              },
              actionLabel: 'Rechercher',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadDestinations,
            child: _selectedViewMode == 0
                ? _buildListView(context, destinationProvider)
                : _buildGridView(context, destinationProvider),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/search-destinations');
        },
        icon: const Icon(Icons.search, size: 18),
        label: const Text('Rechercher', style: TextStyle(fontSize: 12)),
        elevation: 4,
      ),
    );
  }

  Widget _buildListView(BuildContext context, DestinationProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacingS,
        horizontal: 0,
      ),
      itemCount: provider.destinations.length,
      itemBuilder: (context, index) {
        final destination = provider.destinations[index];
        return DestinationCard(
          destination: destination,
          onTap: () {
            Navigator.of(context).pushNamed(
              '/destination-details',
              arguments: destination.id,
            );
          },
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, DestinationProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppTheme.spacingS,
        mainAxisSpacing: AppTheme.spacingS,
      ),
      itemCount: provider.destinations.length,
      itemBuilder: (context, index) {
        final destination = provider.destinations[index];
        return DestinationGridCard(
          destination: destination,
          onTap: () {
            Navigator.of(context).pushNamed(
              '/destination-details',
              arguments: destination.id,
            );
          },
        );
      },
    );
  }
}
