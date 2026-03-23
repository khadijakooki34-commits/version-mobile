import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';
import 'admin_avis_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatistics();
    });
  }

  Future<void> _loadStatistics() async {
    context.read<AdminProvider>().fetchStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord administrateur'),
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            tooltip: 'Actualiser',
            onPressed: _loadStatistics,
          ),
          IconButton(
            icon: const Icon(Icons.person, size: 24),
            tooltip: 'Profil',
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading || provider.statistics == null) {
            return const LoadingWidget();
          }

          final stats = provider.statistics!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with greeting
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenue, Administrateur',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gérez votre application et surveillez les statistiques',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXL),
                // Statistics section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Indicateurs clés',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingL),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppTheme.spacingM,
                  mainAxisSpacing: AppTheme.spacingM,
                  childAspectRatio: 0.95,
                  children: [
                    _StatCard(
                      title: 'Total des utilisateurs',
                      value: stats.totalUsers.toString(),
                      icon: Icons.people,
                      color: AppTheme.primaryColor,
                    ),
                    _StatCard(
                      title: 'Utilisateurs actifs',
                      value: stats.activeUsers.toString(),
                      icon: Icons.check_circle,
                      color: AppTheme.successColor,
                    ),
                    _StatCard(
                      title: 'Total des destinations',
                      value: stats.totalDestinations.toString(),
                      icon: Icons.location_on,
                      color: AppTheme.secondaryColor,
                    ),
                    _StatCard(
                      title: 'Total des avis',
                      value: stats.totalReviews.toString(),
                      icon: Icons.rate_review,
                      color: AppTheme.accentColor,
                    ),
                    _StatCard(
                      title: 'Total des événements',
                      value: stats.totalEvents.toString(),
                      icon: Icons.calendar_today,
                      color: AppTheme.infoColor,
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXL),
                // Quick Actions section
                Text(
                  'Actions rapides',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),
                _buildManagementButton(
                  context,
                  icon: Icons.people,
                  label: 'Gérer les utilisateurs',
                  description: 'Voir et gérer les comptes utilisateurs',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/admin-users');
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildManagementButton(
                  context,
                  icon: Icons.location_city,
                  label: 'Gérer les destinations',
                  description: 'Ajouter, modifier ou supprimer des destinations',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/admin-destinations');
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildManagementButton(
                  context,
                  icon: Icons.event,
                  label: 'Gérer les événements',
                  description: 'Ajouter, modifier ou supprimer des événements culturels',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/admin-events');
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildManagementButton(
                  context,
                  icon: Icons.rate_review,
                  label: 'Gérer les avis',
                  description: 'Voir et modérer les avis des utilisateurs',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminAvisScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildManagementButton(
                  context,
                  icon: Icons.bar_chart,
                  label: 'Voir les statistiques',
                  description: 'Analytiques détaillées et rapports',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/admin-statistics');
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildManagementButton(
                  context,
                  icon: Icons.home,
                  label: 'Retour à l\'application',
                  description: 'Retourner au tableau de bord utilisateur',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/home');
                  },
                  isOutlined: true,
                ),
                const SizedBox(height: AppTheme.spacingL),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildManagementButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return isOutlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingS,
                vertical: AppTheme.spacingS,
              ),
              side: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 24, color: AppTheme.primaryColor),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textLightColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: AppTheme.primaryColor),
              ],
            ),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingS,
                vertical: AppTheme.spacingS,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              elevation: 2,
            ),
            child: Row(
              children: [
                Icon(icon, size: 24, color: Colors.white),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.white),
              ],
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
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingM,
              AppTheme.spacingXL,
              AppTheme.spacingM,
              AppTheme.spacingM,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Icon(Icons.admin_panel_settings, size: 28, color: Colors.white),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Panneau Admin',
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
                    Navigator.pop(context);
                  },
                ),
                const Divider(height: 1),
                
                // Manage Destinations
                _buildDrawerItem(
                  context,
                  icon: Icons.location_city,
                  label: 'Gérer les destinations',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed('/admin-destinations');
                  },
                ),

                // Manage Events
                _buildDrawerItem(
                  context,
                  icon: Icons.event,
                  label: 'Gérer les événements',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed('/admin-events');
                  },
                ),
                
                // Manage Reviews
                _buildDrawerItem(
                  context,
                  icon: Icons.rate_review,
                  label: 'Gérer les avis',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminAvisScreen(),
                      ),
                    );
                  },
                ),
                
                // Manage Users
                _buildDrawerItem(
                  context,
                  icon: Icons.people,
                  label: 'Gérer les utilisateurs',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed('/admin-users');
                  },
                ),
                
                // Statistics
                _buildDrawerItem(
                  context,
                  icon: Icons.bar_chart,
                  label: 'Statistiques',
                  onTap: () {
                    Navigator.pop(context);
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
                  Navigator.pop(context);
                  _logout(context);
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
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
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textLightColor,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

