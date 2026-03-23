import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';

/// Widget that guards routes based on user role
class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;
  final Widget? unauthorizedWidget;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
    this.unauthorizedWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Check if user is logged in
        if (!authProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if user has required role
        final userRole = authProvider.currentUser?.role ?? 'USER';
        if (!allowedRoles.contains(userRole)) {
          return unauthorizedWidget ??
              Scaffold(
                appBar: AppBar(title: const Text('Accès Refusé')),
                body: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.block, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Accès Refusé',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Vous n\'avez pas la permission d\'accéder à cette page.'),
                    ],
                  ),
                ),
              );
        }

        return child;
      },
    );
  }
}

/// Helper widget for admin-only routes
class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: const ['ADMIN'],
      child: child,
    );
  }
}

/// Helper widget for authenticated routes
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: const ['USER', 'ADMIN'],
      child: child,
    );
  }
}

