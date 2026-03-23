import 'package:flutter/material.dart';
import '../../utils/index.dart';

class MapConfigScreen extends StatefulWidget {
  const MapConfigScreen({super.key});

  @override
  State<MapConfigScreen> createState() => _MapConfigScreenState();
}

class _MapConfigScreenState extends State<MapConfigScreen> {
  bool _useGoogleMaps = false;

  @override
  void initState() {
    super.initState();
    _checkMapConfiguration();
  }

  void _checkMapConfiguration() {
    // Vérifier si Google Maps est configuré
    // Pour Android, vérifier AndroidManifest.xml
    // Pour iOS, vérifier AppDelegate.swift
    setState(() {
      _useGoogleMaps = true; // Supposer que Google Maps est configuré
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration des cartes'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type de carte',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    RadioListTile<bool>(
                      title: const Text('Google Maps'),
                      subtitle: const Text('Recommandé - Nécessite une clé API'),
                      value: _useGoogleMaps,
                      groupValue: true,
                      onChanged: (value) {
                        setState(() {
                          _useGoogleMaps = value!;
                        });
                      },
                    ),
                    RadioListTile<bool>(
                      title: const Text('OpenStreetMap'),
                      subtitle: const Text('Gratuit - Aucune clé requise'),
                      value: !_useGoogleMaps,
                      groupValue: true,
                      onChanged: (value) {
                        setState(() {
                          _useGoogleMaps = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration Google Maps',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Étapes pour ajouter votre clé API Google Maps :',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          _buildStep('1', 'Créer un compte Google Cloud Console'),
                          _buildStepDescription('Allez sur https://console.cloud.google.com/'),
                          const SizedBox(height: 4),
                          _buildStep('2', 'Activer les APIs Maps SDK for Android/iOS'),
                          _buildStepDescription('Dans votre projet, activez "Maps SDK for Android" et "Maps SDK for iOS"'),
                          const SizedBox(height: 4),
                          _buildStep('3', 'Créer une clé API'),
                          _buildStepDescription('Générez une clé API dans "Identifiants et identifiants" > "Clés API"'),
                          const SizedBox(height: 4),
                          _buildStep('4', 'Ajouter la clé au projet'),
                          _buildStepDescription('Pour Android : Ajoutez dans android/app/src/main/AndroidManifest.xml'),
                          _buildStepDescription('Pour iOS : Ajoutez dans ios/Runner/AppDelegate.swift'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration OpenStreetMap',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OpenStreetMap est déjà configuré !',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aucune configuration requise. OpenStreetMap fonctionne directement avec les packages flutter_map et latlong2.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Avantages : 100% gratuit, pas de clé API requise, cartes du monde entier.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check),
                label: const Text('Continuer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDescription(String description) {
    return Padding(
      padding: const EdgeInsets.only(left: 36.0, bottom: 4.0),
      child: Text(
        description,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.blue,
        ),
      ),
    );
  }
}
