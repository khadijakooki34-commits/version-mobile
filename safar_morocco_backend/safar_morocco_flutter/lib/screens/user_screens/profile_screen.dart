import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
      _loadFavorites();
    });
  }

  Future<void> _loadProfile() async {
    context.read<UserProvider>().fetchProfile();
  }

  Future<void> _loadFavorites() async {
    context.read<FavoriteProvider>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(fontSize: 18)),
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {
              Navigator.of(context).pushNamed('/edit-profile');
            },
          ),
        ],
      ),
      body: Consumer3<UserProvider, AuthProvider, FavoriteProvider>(
        builder: (context, userProvider, authProvider, favoriteProvider, _) {
          if (userProvider.isLoading) {
            return const LoadingWidget();
          }

          if (userProvider.error != null) {
            return AppErrorWidget(
              error: userProvider.error,
              onRetry: _loadProfile,
            );
          }

          final user = userProvider.user;
          if (user == null) {
            return const EmptyStateWidget(
              icon: Icons.person,
              title: 'Profil introuvable',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              children: [
                _buildProfileHeader(context, user),
                const SizedBox(height: AppTheme.spacingL),
                _buildProfileInfo(context, user),
                const SizedBox(height: AppTheme.spacingL),
                _buildFavoritesSection(context, favoriteProvider),
                const SizedBox(height: AppTheme.spacingL),
                _buildReservationsEntry(context),
                const SizedBox(height: AppTheme.spacingL),
                _buildActionButtons(context, authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
    return Column(
      children: [
        if (user.profileImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            child: CachedNetworkImage(
              imageUrl: user.profileImage!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => _buildDefaultAvatar(),
            ),
          )
        else
          _buildDefaultAvatar(),
        const SizedBox(height: AppTheme.spacingM),
        Text(
          '${user.firstName} ${user.lastName}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingXS,
          ),
          decoration: BoxDecoration(
            color: user.role == 'ADMIN'
                ? AppTheme.errorColor
                : AppTheme.successColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: [
              BoxShadow(
                color: (user.role == 'ADMIN'
                        ? AppTheme.errorColor
                        : AppTheme.successColor)
                    .withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            user.role,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        size: 56,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFavoritesSection(BuildContext context, FavoriteProvider favoriteProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mes endroits préférés',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        if (favoriteProvider.isLoading)
          const SizedBox(
            height: 80,
            child: Center(child: LoadingWidget(size: 32)),
          )
        else if (favoriteProvider.favoriteDestinations.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.lightColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite_border,
                  color: AppTheme.textSecondary,
                  size: 40,
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Text(
                    'Explorez les destinations et ajoutez-les à vos favoris !',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: favoriteProvider.favoriteDestinations.length,
              itemBuilder: (context, index) {
                final dest = favoriteProvider.favoriteDestinations[index];
                return _FavoritePlaceCard(
                  destination: dest,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/destination-details',
                      arguments: dest.id,
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildReservationsEntry(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Réservations & Itinéraires',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: const Icon(Icons.event_available, color: AppTheme.primaryColor),
          ),
          title: const Text('Mes réservations'),
          subtitle: const Text('Voir et gérer mes réservations d\'événements'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
                print('Mes réservations tapped'); // Debug print
                Navigator.of(context).pushNamed('/my-reservations');
              },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: const Icon(Icons.route, color: AppTheme.secondaryColor),
          ),
          title: const Text('Mes itinéraires'),
          subtitle: const Text('Planifier mon voyage'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
                print('Mes itinéraires tapped'); // Debug print
                Navigator.of(context).pushNamed('/my-itineraries');
              },
        ),
      ],
    );
  }

  Widget _buildProfileInfo(BuildContext context, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations du compte',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),
        _ProfileInfoItem(
          icon: Icons.email,
          label: 'Email',
          value: user.email,
        ),
        _ProfileInfoItem(
          icon: Icons.phone,
          label: 'Téléphone',
          value: user.phoneNumber,
        ),
        _ProfileInfoItem(
          icon: Icons.calendar_today,
          label: 'Membre depuis',
          value: DateFormatUtil.formatDate(user.createdAt),
        ),
        if (user.isBlocked)
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Row(
              children: [
                const Icon(Icons.block, color: AppTheme.errorColor),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Text(
                    'Votre compte a été bloqué',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.errorColor,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AuthProvider authProvider) {
    print('User is admin: ${authProvider.isAdmin}'); // Debug print
    return Column(
      children: [
        // Bouton admin uniquement visible pour les admins
        if (authProvider.isAdmin) ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                print('Admin button tapped'); // Debug print
                Navigator.of(context).pushNamed('/admin-dashboard');
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Admin', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
        ],
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              print('Modifier button tapped'); // Debug print
              Navigator.of(context).pushNamed('/edit-profile');
            },
            icon: const Icon(Icons.edit),
            label: const Text('Modifier', style: TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler', style: TextStyle(fontSize: 12)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Déconnexion', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );

              if (confirmed == true && mounted) {
                await authProvider.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Déconnexion', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

class _FavoritePlaceCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const _FavoritePlaceCard({
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: AppTheme.spacingM),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: destination.mainImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                child: Text(
                  destination.name,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
