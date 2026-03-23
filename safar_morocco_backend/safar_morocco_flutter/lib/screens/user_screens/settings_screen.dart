import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'Français';
  bool _isDarkTheme = false;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'Français';
      _isDarkTheme = prefs.getBool('dark_theme') ?? false;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? false;
      _smsNotifications = prefs.getBool('sms_notifications') ?? false;
    });
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_theme', isDark);
    setState(() {
      _isDarkTheme = isDark;
    });
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', _pushNotifications);
    await prefs.setBool('email_notifications', _emailNotifications);
    await prefs.setBool('sms_notifications', _smsNotifications);
  }

  @override
  Widget build(BuildContext context) {
    print('SettingsScreen build called'); // Debug print
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres', style: TextStyle(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          _buildSection('Compte', [
            _buildTile(
              context,
              icon: Icons.person,
              title: 'Profil',
              subtitle: 'Modifier vos informations',
              onTap: () {
                print('Profil tapped'); // Debug print
                Navigator.of(context).pushNamed('/edit-profile');
              },
            ),
            _buildTile(
              context,
              icon: Icons.lock,
              title: 'Mot de passe',
              subtitle: 'Changer votre mot de passe',
              onTap: () {
                print('Mot de passe tapped'); // Debug print
                _showChangePasswordDialog();
              },
            ),
          ]),
          const SizedBox(height: AppTheme.spacingL),
          _buildSection('Application', [
            _buildTile(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Gérer les notifications',
              onTap: () {
                print('Notifications tapped'); // Debug print
                _showNotificationSettings();
              },
            ),
            _buildTile(
              context,
              icon: Icons.language,
              title: 'Langue',
              subtitle: _selectedLanguage,
              onTap: () {
                print('Langue tapped'); // Debug print
                _showLanguageSelector();
              },
            ),
            _buildTile(
              context,
              icon: Icons.dark_mode,
              title: 'Thème',
              subtitle: _isDarkTheme ? 'Sombre' : 'Clair',
              onTap: () {
                print('Thème tapped'); // Debug print
                _toggleTheme();
              },
            ),
          ]),
          const SizedBox(height: AppTheme.spacingL),
          _buildSection('À propos', [
            _buildTile(
              context,
              icon: Icons.info,
              title: 'Version',
              subtitle: '1.0.0',
              onTap: null,
            ),
            _buildTile(
              context,
              icon: Icons.help,
              title: 'Aide',
              subtitle: 'Centre d\'aide',
              onTap: () {
                print('Aide tapped'); // Debug print
                _showHelpCenter();
              },
            ),
          ]),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Ancien mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text == confirmPasswordController.text) {
                // Simuler l'appel API pour changer le mot de passe
                try {
                  // TODO: Remplacer par un vrai appel API
                  final success = await _changePasswordAPI(
                    oldPasswordController.text,
                    newPasswordController.text,
                  );
                  
                  Navigator.pop(context);
                  
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mot de passe changé avec succès'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ancien mot de passe incorrect'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Les nouveaux mots de passe ne correspondent pas'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  // Simuler un appel API pour changer le mot de passe
  Future<bool> _changePasswordAPI(String oldPassword, String newPassword) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(seconds: 2));
    
    // Simuler la validation (remplacer par une vraie logique)
    if (oldPassword.length < 4) {
      return false; // Ancien mot de passe invalide
    }
    
    // Simuler le succès et sauvegarder le nouveau mot de passe
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_password', newPassword);
    
    return true;
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Paramètres de notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Notifications push'),
                subtitle: const Text('Recevoir des notifications sur votre appareil'),
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() => _pushNotifications = value);
                },
              ),
              SwitchListTile(
                title: const Text('Notifications email'),
                subtitle: const Text('Recevoir des notifications par email'),
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() => _emailNotifications = value);
                },
              ),
              SwitchListTile(
                title: const Text('Notifications SMS'),
                subtitle: const Text('Recevoir des notifications par SMS'),
                value: _smsNotifications,
                onChanged: (value) {
                  setState(() => _smsNotifications = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveNotifications();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paramètres de notification sauvegardés'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    final languages = ['Français', 'English', 'Español', 'العربية'];
    final flags = ['🇫🇷', '🇬🇧', '🇪🇸', '🇸🇦'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(languages.length, (index) {
            return RadioListTile<String>(
              title: Text('${flags[index]} ${languages[index]}'),
              value: languages[index],
              groupValue: _selectedLanguage,
              onChanged: (value) async {
                await _saveLanguage(value!);
                Navigator.pop(context);
                
                // Appliquer la langue immédiatement
                _applyLanguageChange(value);
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _applyLanguageChange(String language) {
    // Simuler l'application de la langue
    switch (language) {
      case 'Français':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Langue française appliquée'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'English':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('English language applied'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'Español':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Idioma español aplicado'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'العربية':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تطبيق اللغة العربية'),
            backgroundColor: Colors.deepOrange,
            duration: Duration(seconds: 2),
          ),
        );
        break;
    }
  }

  void _toggleTheme() async {
    await _saveTheme(!_isDarkTheme);
    
    // Appliquer le thème à toute l'application
    if (_isDarkTheme) {
      // Thème sombre
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thème sombre appliqué'),
          backgroundColor: Colors.black87,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Thème clair
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thème clair appliqué'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showHelpCenter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Centre d\'aide'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comment utiliser l\'application :', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('1. Explorez les destinations marocaines'),
            Text('2. Réservez des événements et activités'),
            Text('3. Créez vos itinéraires personnalisés'),
            Text('4. Consultez la météo en temps réel'),
            SizedBox(height: 16),
            Text('Pour plus d\'aide :', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('📧 Email: support@safar.ma'),
            Text('📞 Téléphone: +212 5XX-XXX-XXX'),
            Text('🌐 Site web: www.safar.ma'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: onTap != null 
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : null,
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
