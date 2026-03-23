import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';

class SearchDestinationsScreen extends StatefulWidget {
  const SearchDestinationsScreen({super.key});

  @override
  State<SearchDestinationsScreen> createState() => _SearchDestinationsScreenState();
}

class _SearchDestinationsScreenState extends State<SearchDestinationsScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  double? _minRating;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final provider = context.read<DestinationProvider>();
    if (_searchController.text.isNotEmpty) {
      await provider.searchDestinations(_searchController.text);
    }
  }

  Future<void> _performFilter() async {
    final provider = context.read<DestinationProvider>();
    await provider.filterDestinations(
      category: _selectedCategory,
      minRating: _minRating,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher et filtrer', style: TextStyle(fontSize: 18)),
      ),
      body: Consumer<DestinationProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Ville',
                  hint: 'Rechercher par nom ou mot-clé',
                  controller: _searchController,
                  prefixIcon: Icons.search,
                  onChanged: (_) => _performSearch(),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Catégorie',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Wrap(
                  spacing: AppTheme.spacingS,
                  children: AppConstants.destinationCategories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                        _performFilter();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Note minimale',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Slider(
                  value: _minRating ?? 0.0,
                  min: 0.0,
                  max: 5.0,
                  divisions: 10,
                  label: (_minRating ?? 0.0).toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      _minRating = value == 0.0 ? null : value;
                    });
                    _performFilter();
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
                if (provider.isLoading)
                  const LoadingWidget()
                else if (provider.error != null)
                  AppErrorWidget(error: provider.error)
                else if (provider.destinations.isEmpty)
                  const EmptyStateWidget(
                    icon: Icons.search_off,
                    title: 'Aucun résultat trouvé',
                    subtitle: 'Essayez d\'ajuster vos filtres',
                  )
                else
                  Column(
                    children: provider.destinations
                        .map((dest) => DestinationCard(
                              destination: dest,
                              onTap: () => Navigator.of(context).pushNamed(
                                '/destination-details',
                                arguments: dest.id,
                              ),
                            ))
                        .toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
