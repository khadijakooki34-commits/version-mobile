import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/index.dart';

class WeatherScreen extends StatefulWidget {
  final String? initialCity;

  const WeatherScreen({super.key, this.initialCity});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCity != null) {
      _cityController.text = widget.initialCity!;
      _loadWeather();
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    if (_cityController.text.isNotEmpty) {
      context.read<WeatherProvider>().fetchWeather(_cityController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Météo'),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Ville',
                        hint: 'Entrez le nom de la ville',
                        controller: _cityController,
                        prefixIcon: Icons.location_city,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    FloatingActionButton(
                      mini: true,
                      onPressed: _loadWeather,
                      child: const Icon(Icons.search),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingL),
                if (provider.isLoading)
                  const LoadingWidget()
                else if (provider.error != null)
                  AppErrorWidget(
                    error: provider.error,
                    onRetry: _loadWeather,
                  )
                else if (provider.lastFetchedCity != null)
                  _buildWeatherCard(context, provider.getWeatherForCity(provider.lastFetchedCity!)!)
                else
                  const EmptyStateWidget(
                    icon: Icons.cloud,
                    title: 'Aucune donnée météo',
                    subtitle: 'Recherchez une ville pour voir la météo',
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, WeatherData weather) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          children: [
            Text(
              weather.city,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              weather.getWeatherEmoji(),
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              '${weather.temperature.toStringAsFixed(1)}°C',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              weather.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Ressenti ${weather.feelsLike.toStringAsFixed(1)}°C',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Divider(height: AppTheme.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _WeatherDetail(
                  icon: Icons.opacity,
                  label: 'Humidité',
                  value: '${weather.humidity}%',
                ),
                _WeatherDetail(
                  icon: Icons.air,
                  label: 'Vent',
                  value: '${weather.windSpeed} km/h',
                ),
                _WeatherDetail(
                  icon: Icons.compress,
                  label: 'Pression',
                  value: '${weather.pressure} hPa',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
