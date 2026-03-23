import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/avis_provider.dart';
import '../../models/review_model.dart';
import '../../utils/app_theme.dart';

class AdminAvisScreen extends StatefulWidget {
  const AdminAvisScreen({super.key});

  @override
  State<AdminAvisScreen> createState() => _AdminAvisScreenState();
}

class _AdminAvisScreenState extends State<AdminAvisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<AvisProvider>().refresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestion des avis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('En attente'),
                  const SizedBox(width: 8),
                  Consumer<AvisProvider>(
                    builder: (context, provider, _) {
                      if (provider.pendingCount > 0) {
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            provider.pendingCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            const Tab(text: 'Tous les avis'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            tooltip: 'Actualiser',
            onPressed: _loadData,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingAvisTab(),
          _buildAllAvisTab(),
        ],
      ),
    );
  }

  Widget _buildPendingAvisTab() {
    return Consumer<AvisProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.pendingAvis.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.pendingAvis.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Réessayer', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          );
        }

        if (provider.pendingAvis.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
                const SizedBox(height: 16),
                Text(
                  'Aucun avis en attente',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tous les avis ont été traités',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            itemCount: provider.pendingAvis.length,
            itemBuilder: (context, index) {
              final avis = provider.pendingAvis[index];
              return _buildAvisCard(avis, isPending: true);
            },
          ),
        );
      },
    );
  }

  Widget _buildAllAvisTab() {
    return Consumer<AvisProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.allAvis.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.allAvis.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Réessayer', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          );
        }

        if (provider.allAvis.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Aucun avis trouvé'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            itemCount: provider.allAvis.length,
            itemBuilder: (context, index) {
              final avis = provider.allAvis[index];
              return _buildAvisCard(avis, isPending: false);
            },
          ),
        );
      },
    );
  }

  Widget _buildAvisCard(Avis avis, {required bool isPending}) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec utilisateur et statut
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    avis.userName.isNotEmpty ? avis.userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        avis.userName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        avis.userEmail,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(avis.status),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            // Note
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < avis.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  avis.rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            // Commentaire
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                avis.comment,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            // Actions
            if (isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveAvis(avis),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approuver', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _deleteAvis(avis),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Supprimer', style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Bouton de suppression pour les avis déjà approuvés
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _deleteAvis(avis),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Supprimer', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
            
            // Date
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Posté le ${_formatDate(avis.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case 'APPROVED':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        text = 'Approuvé';
        break;
      case 'PENDING':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        text = 'En attente';
        break;
      case 'REJECTED':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        text = 'Rejeté';
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _approveAvis(Avis avis) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approuver l\'avis'),
        content: Text('Voulez-vous approuver l\'avis de ${avis.userName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approuver', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<AvisProvider>().approveAvis(avis.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Avis approuvé avec succès' : 'Erreur lors de l\'approbation'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAvis(Avis avis) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'avis'),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'avis de ${avis.userName}? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<AvisProvider>().deleteAvis(avis.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Avis supprimé avec succès' : 'Erreur lors de la suppression'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
