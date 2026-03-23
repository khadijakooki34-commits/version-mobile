import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitChanges() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = context.read<UserProvider>();
      await userProvider.updateProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneController.text,
      );

      if (mounted) {
        if (userProvider.error == null) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userProvider.error ?? 'Échec de la mise à jour du profil'),
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
        title: const Text('Modifier le profil'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Prénom',
                    controller: _firstNameController,
                    validator: ValidationUtil.validateName,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  CustomTextField(
                    label: 'Nom',
                    controller: _lastNameController,
                    validator: ValidationUtil.validateName,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  CustomTextField(
                    label: 'Numéro de téléphone',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: ValidationUtil.validatePhoneNumber,
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _submitChanges,
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Enregistrer les modifications'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
