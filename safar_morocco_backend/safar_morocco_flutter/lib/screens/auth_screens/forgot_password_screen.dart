import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String? _resetToken;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final authService = context.read<AuthProvider>().authService;
        final token = await authService.forgotPassword(
          email: _emailController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _emailSent = true;
            _resetToken = token;
            _isLoading = false;
            _error = null;
          });
        }
      } catch (e) {
        String msg = e.toString();
        if (msg.contains('Exception: ')) {
          msg = msg.replaceFirst('Exception: ', '').split(': ').last;
        }
        if (mounted) {
          setState(() {
            _error = msg;
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _error = 'Les mots de passe ne correspondent pas';
        });
        return;
      }

      if (_resetToken == null || _resetToken!.isEmpty) {
        setState(() {
          _error = 'Le token de réinitialisation est manquant. Veuillez en demander un nouveau.';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final authService = context.read<AuthProvider>().authService;
        await authService.resetPassword(
          token: _resetToken!,
          newPassword: _passwordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mot de passe réinitialisé avec succès ! Vous pouvez maintenant vous connecter.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } catch (e) {
        String msg = e.toString();
        if (msg.contains('Exception: ')) {
          msg = msg.replaceFirst('Exception: ', '').split(': ').last;
        }
        if (mounted) {
          setState(() {
            _error = msg;
            _isLoading = false;
          });
        }
      }
    }
  }

  void _startOver() {
    setState(() {
      _emailSent = false;
      _resetToken = null;
      _error = null;
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppTheme.spacingXL),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),
                Text(
                  _emailSent ? 'Réinitialiser votre mot de passe' : 'Mot de passe oublié?',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  _emailSent
                      ? 'Entrez votre nouveau mot de passe ci-dessous.'
                      : 'Entrez votre adresse email et nous vous enverrons un lien de réinitialisation.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textLightColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingXL),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.errorColor),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: AppTheme.errorColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                ],
                if (!_emailSent) ...[
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Adresse Email',
                      hintText: 'votre.email@exemple.com',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: ValidationUtil.validateEmail,
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRequestReset,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Envoyer le lien de réinitialisation', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ] else ...[
                  if (_resetToken != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jeton de réinitialisation (pour développement) :',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            _resetToken!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                  ],
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      hintText: 'Entrez le nouveau mot de passe (min 8 caractères)',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Le mot de passe est requis';
                      if (v.length < 8) return 'Le mot de passe doit contenir au moins 8 caractères';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      hintText: 'Réentrez votre nouveau mot de passe',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Veuillez confirmer votre mot de passe';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleResetPassword,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Réinitialiser le mot de passe', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  TextButton(
                    onPressed: _startOver,
                    child: const Text('Demander un nouveau lien de réinitialisation'),
                  ),
                ],
                const SizedBox(height: AppTheme.spacingXL),
                Column(
                  children: [
                    const Text('Vous souvenez-vous de votre mot de passe ?'),
                    const SizedBox(height: AppTheme.spacingS),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          ),
                        ),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

