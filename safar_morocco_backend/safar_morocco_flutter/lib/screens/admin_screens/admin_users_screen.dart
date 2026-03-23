import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  static const String _mainAdminEmail = 'admin@safar.com';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    context.read<AdminProvider>().fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = context.select<AuthProvider, String?>(
      (auth) => auth.currentUser?.email,
    );
    final canChangeRoles =
        currentUserEmail != null &&
        currentUserEmail.toLowerCase() == _mainAdminEmail;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les utilisateurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Tableau de bord',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/admin-dashboard');
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.error != null) {
            return AppErrorWidget(
              error: provider.error,
              onRetry: _loadUsers,
            );
          }

          if (provider.users.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.people,
              title: 'Aucun utilisateur',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            itemCount: provider.users.length,
            itemBuilder: (context, index) {
              final user = provider.users[index];
              final canChangeThisUserRole = canChangeRoles &&
                  user.email.toLowerCase() != _mainAdminEmail;
              return _UserCard(
                user: user,
                canChangeRole: canChangeThisUserRole,
                onRoleChanged: (newRole) => _handleChangeUserRole(
                  context,
                  user.id,
                  user.email,
                  user.role,
                  newRole,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleChangeUserRole(
    BuildContext context,
    int userId,
    String targetUserEmail,
    String currentRole,
    String newRole,
  ) async {
    final currentUserEmail = context.read<AuthProvider>().currentUser?.email;
    final canChangeRoles =
        currentUserEmail != null &&
        currentUserEmail.toLowerCase() == _mainAdminEmail;
    if (!canChangeRoles) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Seul admin@safar.com peut modifier les rôles des utilisateurs.',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (targetUserEmail.toLowerCase() == _mainAdminEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Le rôle de l\'administrateur principal ne peut pas être modifié.',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (currentRole.toUpperCase() == newRole.toUpperCase()) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le rôle de l\'utilisateur'),
        content: Text(
          'Êtes-vous sûr de vouloir modifier le rôle de ${currentRole.toUpperCase()} à ${newRole.toUpperCase()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<AdminProvider>().changeUserRole(userId, newRole);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la mise à jour du rôle : $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final bool canChangeRole;
  final ValueChanged<String> onRoleChanged;

  const _UserCard({
    required this.user,
    required this.canChangeRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (user.profileImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    child: CachedNetworkImage(
                      imageUrl: user.profileImage!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => _buildDefaultAvatar(),
                    ),
                  )
                else
                  _buildDefaultAvatar(),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                        maxLines: 1,
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.phoneNumber,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.role == 'ADMIN' ? AppTheme.errorColor : AppTheme.successColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Text(
                    user.role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (canChangeRole)
              SizedBox(
                width: double.infinity,
                child: PopupMenuButton<String>(
                  onSelected: onRoleChanged,
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'USER',
                      child: Text('Définir comme utilisateur'),
                    ),
                    PopupMenuItem<String>(
                      value: 'ADMIN',
                      child: Text('Définir comme administrateur'),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      border: Border.all(color: AppTheme.primaryColor, width: 1.2),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Rôle',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: const Icon(Icons.person, color: Colors.white),
    );
  }
}
