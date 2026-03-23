import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (authProvider.isLoggedIn) {
          Navigator.of(context).pushReplacementNamed(
            authProvider.isAdmin ? '/admin-dashboard' : '/home',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Échec de connexion'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    
    await authProvider.redirectToGoogleOAuth();
    
    if (mounted) {
      if (authProvider.isLoggedIn) {
        Navigator.of(context).pushReplacementNamed(
          authProvider.isAdmin ? '/admin-dashboard' : '/home',
        );
      } else if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Échec de connexion Google'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFEEF2FF),
              Color(0xFFF8FAFC),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppTheme.spacingXXL),
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.secondaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.explore,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      Text(
                        'Bienvenue sur Safar Morocco',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        'Découvrez les meilleures destinations du Maroc',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.2,
                            ),
                        textAlign: TextAlign.center,
                      ),
                  const SizedBox(height: AppTheme.spacingXXL),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Adresse Email',
                          hint: 'email@exemple.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email,
                          validator: ValidationUtil.validateEmail,
                        ),
                        const SizedBox(height: AppTheme.spacingL),
                        CustomTextField(
                          label: 'Mot de passe',
                          hint: 'Entrez votre mot de passe',
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: Icons.lock,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le mot de passe est requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: CheckboxListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Se souvenir de moi'),
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/forgot-password');
                              },
                              child: const Text('Mot de passe oublié?', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingL),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: authProvider.isLoading ? null : _handleLogin,
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Se connecter',
                                    style: TextStyle(fontSize: 14),
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppTheme.borderColor)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingM,
                              ),
                              child: Text('OU', style: Theme.of(context).textTheme.bodySmall),
                            ),
                            const Expanded(child: Divider(color: AppTheme.borderColor)),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        // Google Sign-in - available on all platforms (web, Android, iOS)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: const BorderSide(
                                color: AppTheme.borderColor,
                                width: 1.5,
                              ),
                            ),
                            onPressed: authProvider.isLoading ? null : _handleGoogleSignIn,
                            icon: const Icon(Icons.g_mobiledata, size: 24),
                            label: const Text('Google', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingL),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Vous n'avez pas de compte? "),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/register');
                              },
                              child: const Text('S\'inscrire', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  ),
);
  }
}
