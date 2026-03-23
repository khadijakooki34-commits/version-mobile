import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';
import '../../models/index.dart';
import 'admin_avis_screen.dart';

class AdminDestinationsScreen extends StatefulWidget {
  const AdminDestinationsScreen({super.key});

  @override
  State<AdminDestinationsScreen> createState() => _AdminDestinationsScreenState();
}

class _AdminDestinationsScreenState extends State<AdminDestinationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDestinations();
    });
  }

  Future<void> _loadDestinations() async {
    if (mounted) {
      // Forcer un rafraîchissement complet des destinations
      await context.read<DestinationProvider>().fetchDestinations();
    }
  }

  Future<void> _updateAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mettre à jour l\'historique'),
        content: const Text('Cette action va mettre à jour l\'historique de toutes les destinations qui n\'en ont pas. Voulez-vous continuer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Confirmer', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Appeler l'endpoint pour mettre à jour l'historique
        final response = await http.put(
          Uri.parse('http://localhost:8080/api/destinations/update-history'),
          headers: {
            'Content-Type': 'application/json',
            // Ajouter le token d'authentification si nécessaire
            'Authorization': 'Bearer ${context.read<AuthProvider>().token}',
          },
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Historique mis à jour avec succès!'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            // Rafraîchir les destinations
            _loadDestinations();
          }
        } else {
          throw Exception('Erreur serveur: ${response.statusCode}');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la mise à jour: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteDestination(int destinationId, String destinationName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la destination'),
        content: Text('Êtes-vous sûr de vouloir supprimer "$destinationName"? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Supprimer', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<DestinationProvider>();
      try {
        await provider.deleteDestination(destinationId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Destination deleted successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          _loadDestinations();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting destination: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gérer les destinations',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard, size: 20),
            tooltip: 'Tableau de bord',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/admin-dashboard');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_location, size: 20),
            tooltip: 'Ajouter une destination',
            onPressed: () {
              _showAddDestinationDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Actualiser',
            onPressed: _loadDestinations,
          ),
          IconButton(
            icon: const Icon(Icons.history, size: 20),
            tooltip: 'Mettre à jour l\'historique',
            onPressed: _updateAllHistory,
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Consumer<DestinationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.destinations.isEmpty) {
            return const LoadingWidget(message: 'Chargement des destinations...');
          }

          if (provider.error != null && provider.destinations.isEmpty) {
            return AppErrorWidget(
              error: provider.error,
              onRetry: _loadDestinations,
            );
          }

          if (provider.destinations.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.location_off,
              title: 'Aucune destination',
              subtitle: 'Ajoutez votre première destination pour commencer',
              onAction: () => _showAddDestinationDialog(),
              actionLabel: 'Ajouter une destination',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadDestinations,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spacingM,
                horizontal: AppTheme.spacingS,
              ),
              itemCount: provider.destinations.length,
              itemBuilder: (context, index) {
                final destination = provider.destinations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/destination-details',
                        arguments: destination.id,
                      );
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      child: Row(
                        children: [
                          // Image/Avatar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            child: destination.images.isNotEmpty
                                ? Image.network(
                                  destination.images[0],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        color: AppTheme.primaryColor,
                                        size: 40,
                                      ),
                                    );
                                  },
                                )
                                : Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: AppTheme.primaryColor,
                                    size: 40,
                                  ),
                                ),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  destination.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.secondaryColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        destination.category,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 14, color: Colors.amber),
                                        const SizedBox(width: 3),
                                        Text(
                                          destination.rating.toStringAsFixed(1),
                                          style: Theme.of(context).textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: AppTheme.textLightColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        destination.location,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textLightColor,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${destination.reviewCount} avis',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color: AppTheme.textLightColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Action menu
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Modifier'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditDestinationDialog(destination);
                              } else if (value == 'delete') {
                                _deleteDestination(destination.id, destination.name);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDestinationDialog(),
        icon: const Icon(Icons.add_location),
        label: const Text('Ajouter une destination'),
        elevation: 6,
      ),
    );
  }

  void _showAddDestinationDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AddDestinationModal(
          onDestinationAdded: _loadDestinations,
        ),
      ),
    );
  }

  void _showEditDestinationDialog(Destination destination) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _EditDestinationModal(
          destination: destination,
          onDestinationUpdated: _loadDestinations,
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                  child: const Icon(Icons.admin_panel_settings, size: 32, color: Colors.white),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Panneau d\'administration',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gérez votre application',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
              children: [
                // Dashboard
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  label: 'Tableau de bord',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.of(context).pushReplacementNamed('/admin-dashboard');
                  },
                ),
                const Divider(height: 1),
                
                // Manage Destinations
                _buildDrawerItem(
                  context,
                  icon: Icons.location_city,
                  label: 'Gérer les destinations',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                  },
                ),
                
                // Manage Users
                _buildDrawerItem(
                  context,
                  icon: Icons.people,
                  label: 'Gérer les utilisateurs',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.of(context).pushNamed('/admin-users');
                  },
                ),
                
                // Manage Reviews
                _buildDrawerItem(
                  context,
                  icon: Icons.rate_review,
                  label: 'Gérer les avis',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminAvisScreen(),
                      ),
                    );
                  },
                ),
                
                // Statistics
                _buildDrawerItem(
                  context,
                  icon: Icons.bar_chart,
                  label: 'Statistiques',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.of(context).pushNamed('/admin-statistics');
                  },
                ),
                const Divider(height: 1),
                
                // Settings - Supprimé
              ],
            ),
          ),
          // Logout button
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close drawer
                  _logout(context);
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: 4,
      ),
      minLeadingWidth: 0,
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Déconnexion', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _AddDestinationModal extends StatefulWidget {
  final VoidCallback? onDestinationAdded;

  const _AddDestinationModal({this.onDestinationAdded});

  @override
  State<_AddDestinationModal> createState() => _AddDestinationModalState();
}

class _AddDestinationModalState extends State<_AddDestinationModal> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  TextEditingController historyController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final typeController = TextEditingController();
  String selectedCategory = 'Cultural';
  bool isLoading = false;
  
  // Image variables
  XFile? selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    historyController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    typeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );
      
      if (image != null) {
        setState(() {
          selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> _submitForm() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final provider = context.read<DestinationProvider>();
      await provider.createDestination(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        latitude: double.parse(latitudeController.text.trim()),
        longitude: double.parse(longitudeController.text.trim()),
        category: selectedCategory,
        history: historyController.text.trim().isEmpty
            ? null
            : historyController.text.trim(),
        type: typeController.text.trim().isEmpty
            ? null
            : typeController.text.trim(),
        imageFile: selectedImage != null ? File(selectedImage!.path) : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Destination ajoutée avec succès'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Si une image a été uploadée, montrer un message supplémentaire
        if (selectedImage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image téléchargée avec succès'),
              backgroundColor: AppTheme.successColor,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        widget.onDestinationAdded?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter une nouvelle destination',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image picker section
                _buildImagePickerSection(),
                const SizedBox(height: AppTheme.spacingXL),

                // Name field
                _buildFormField(
                  label: 'Nom de la destination *',
                  controller: nameController,
                  icon: Icons.location_city,
                  hint: 'Ex: Marrakech Medina',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ce champ est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingL),

                // Description field
                _buildFormField(
                  label: 'Description *',
                  controller: descriptionController,
                  icon: Icons.description,
                  hint: 'Décrivez la destination...',
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ce champ est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingL),

                // Category dropdown
                _buildCategoryDropdown(),
                const SizedBox(height: AppTheme.spacingL),

                // History field
                _buildFormField(
                  label: 'Historique (Optionnel)',
                  controller: historyController,
                  icon: Icons.history,
                  hint: 'Contexte historique...',
                  maxLines: 3,
                ),
                const SizedBox(height: AppTheme.spacingL),

                // Type field
                _buildFormField(
                  label: 'Type (Optionnel)',
                  controller: typeController,
                  icon: Icons.label,
                  hint: 'Ex: Monument, Parc, Marché',
                ),
                const SizedBox(height: AppTheme.spacingL),

                // Location coordinates
                _buildLocationCoordinates(),
                const SizedBox(height: AppTheme.spacingXL),

                // Submit buttons
                _buildActionButtons(),
                const SizedBox(height: AppTheme.spacingL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          if (selectedImage == null)
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.3),
                          AppTheme.primaryColor.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.image,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'Image de la destination',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Appuyez pour sélectionner une image depuis la galerie',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLightColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.upload_file, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Choisir une image',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    child: FutureBuilder<Uint8List>(
                      future: selectedImage!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.red[100],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, size: 40, color: Colors.red[700]),
                                const SizedBox(height: 8),
                                const Text('Error loading image'),
                              ],
                            ),
                          );
                        }
                        return Image.memory(
                          snapshot.data!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedImage!.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.edit),
                          label: const Text('Changer l\'image', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _removeImage,
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(
                color: AppTheme.textLightColor.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            prefixIcon: Icon(icon, color: AppTheme.primaryColor),
            filled: true,
            fillColor: AppTheme.backgroundColor,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(
                color: AppTheme.textLightColor.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            prefixIcon: const Icon(Icons.category, color: AppTheme.primaryColor),
            filled: true,
            fillColor: AppTheme.backgroundColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
          items: [
            'Cultural',
            'Nature',
            'Historical',
            'Beach',
            'Desert',
            'Mountain',
            'City',
          ]
              .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat),
              ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedCategory = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildLocationCoordinates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coordonnées géographiques *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Latitude',
                  hintText: '31.6295',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    borderSide: BorderSide(
                      color: AppTheme.textLightColor.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.map, color: AppTheme.primaryColor),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  final lat = double.tryParse(value);
                  if (lat == null || lat < -90 || lat > 90) {
                    return 'Valeur invalide';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: TextFormField(
                controller: longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Longitude',
                  hintText: '-7.9891',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    borderSide: BorderSide(
                      color: AppTheme.textLightColor.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.map, color: AppTheme.primaryColor),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  final lng = double.tryParse(value);
                  if (lng == null || lng < -180 || lng > 180) {
                    return 'Valeur invalide';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(
              isLoading ? 'Enregistrement...' : 'Enregistrer',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
            icon: const Icon(Icons.cancel),
            label: const Text('Annuler', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

class _EditDestinationModal extends StatefulWidget {
  final Destination destination;
  final VoidCallback? onDestinationUpdated;

  const _EditDestinationModal({
    required this.destination,
    this.onDestinationUpdated,
  });

  @override
  State<_EditDestinationModal> createState() => _EditDestinationModalState();
}

class _EditDestinationModalState extends State<_EditDestinationModal> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController latitudeController;
  late final TextEditingController longitudeController;
  TextEditingController historyController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  String selectedCategory = 'Cultural';
  bool isLoading = false;
  XFile? selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.destination.name);
    descriptionController = TextEditingController(text: widget.destination.description);
    historyController = TextEditingController(text: widget.destination.histoire);
    latitudeController = TextEditingController(
      text: widget.destination.latitude.toString(),
    );
    longitudeController = TextEditingController(
      text: widget.destination.longitude.toString(),
    );
    final categories = {
      'Cultural',
      'Nature',
      'Historical',
      'Beach',
      'Desert',
      'Mountain',
      'City',
    };
    selectedCategory = categories.contains(widget.destination.category)
        ? widget.destination.category
        : 'Cultural';
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    historyController.dispose();
    typeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (image != null) {
        setState(() => selectedImage = image);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      await context.read<DestinationProvider>().updateDestination(
        id: widget.destination.id,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        latitude: double.parse(latitudeController.text.trim()),
        longitude: double.parse(longitudeController.text.trim()),
        category: selectedCategory,
        history: historyController.text.trim().isEmpty ? null : historyController.text.trim(),
        type: typeController.text.trim().isEmpty ? null : typeController.text.trim(),
        imageFile: selectedImage != null ? File(selectedImage!.path) : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Destination mise à jour avec succès'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      
      // Attendre un peu pour s'assurer que l'image est bien enregistrée côté backend
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Rafraîchir les destinations
      widget.onDestinationUpdated?.call();
      
      // Si l'utilisateur a uploadé une image, montrer un message supplémentaire
      if (selectedImage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image téléchargée avec succès'),
              backgroundColor: AppTheme.successColor,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Erreur lors de la mise à jour';
      
      // Vérifier si c'est une erreur d'upload d'image
      if (e.toString().contains('image upload failed')) {
        errorMessage = 'Destination mise à jour mais erreur lors de l\'upload de l\'image';
      } else if (selectedImage != null && e.toString().contains('Failed to update destination')) {
        errorMessage = 'Erreur lors de la mise à jour de la destination';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorMessage: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la destination'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nom de la destination *'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Le nom est requis' : null,
                ),
                const SizedBox(height: AppTheme.spacingM),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description *'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'La description est requise' : null,
                ),
                const SizedBox(height: AppTheme.spacingM),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Catégorie *'),
                  items: const [
                    'Cultural',
                    'Nature',
                    'Historical',
                    'Beach',
                    'Desert',
                    'Mountain',
                    'City',
                  ].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
                TextFormField(
                  controller: historyController,
                  decoration: const InputDecoration(labelText: 'Historique (Optionnel)'),
                ),
                const SizedBox(height: AppTheme.spacingM),
                TextFormField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Type (Optionnel)'),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: latitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(labelText: 'Latitude *'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Requis';
                          final lat = double.tryParse(value);
                          if (lat == null || lat < -90 || lat > 90) return 'Invalide';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: TextFormField(
                        controller: longitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(labelText: 'Longitude *'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Requis';
                          final lng = double.tryParse(value);
                          if (lng == null || lng < -180 || lng > 180) return 'Invalide';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingL),
                OutlinedButton.icon(
                  onPressed: isLoading ? null : _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    selectedImage == null ? 'Télécharger image' : selectedImage!.name,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXL),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _submitForm,
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(isLoading ? 'Enregistrement...' : 'Enregistrer', style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

