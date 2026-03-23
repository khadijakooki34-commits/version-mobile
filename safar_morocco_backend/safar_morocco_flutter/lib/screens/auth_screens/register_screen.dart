import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez accepter les conditions générales'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les mots de passe ne correspondent pas'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();

      await authProvider.register(
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (authProvider.isLoggedIn) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (authProvider.error != null) {
          // Show error in a more visible way
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error!),
              backgroundColor: AppTheme.errorColor,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Fermer',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
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
        title: const Text('Créer un compte'),
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rejoindre Safar Morocco',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Créez votre compte pour découvrir des destinations incroyables',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingXL),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Prénom',
                        hint: 'Jean',
                        controller: _firstNameController,
                        prefixIcon: Icons.person,
                        validator: ValidationUtil.validateName,
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      CustomTextField(
                        label: 'Nom',
                        hint: 'Dupont',
                        controller: _lastNameController,
                        prefixIcon: Icons.person,
                        validator: ValidationUtil.validateName,
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      CustomTextField(
                        label: 'Adresse Email',
                        hint: 'votre.email@exemple.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email,
                        validator: ValidationUtil.validateEmail,
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      CustomTextField(
                        label: 'Numéro de téléphone',
                        hint: '+212 600000000',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone,
                        validator: ValidationUtil.validatePhoneNumber,
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      CustomTextField(
                        label: 'Mot de passe',
                        hint: 'Entrez un mot de passe fort',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock,
                        validator: ValidationUtil.validatePassword,
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      CustomTextField(
                        label: 'Confirmer le mot de passe',
                        hint: 'Réentrez votre mot de passe',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        prefixIcon: Icons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez confirmer votre mot de passe';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('J\'accepte les termes et conditions'),
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _handleRegister,
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
                                  'Créer un compte',
                                  style: TextStyle(fontSize: 14),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Vous avez déjà un compte? '),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Se connecter',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
        },
      ),
    );
  }
}
