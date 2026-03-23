import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../utils/index.dart';

class WeatherWidget extends StatelessWidget {
  final int destinationId;
  final String destinationName;
  final bool showForecast;

  const WeatherWidget({
    super.key,
    required this.destinationId,
    required this.destinationName,
    this.showForecast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final weather = weatherProvider.getWeatherForDestination(destinationId);
        final forecast = weatherProvider.getForecastForDestination(destinationId);
        final isLoading = weatherProvider.isLoading;

        if (isLoading && weather == null) {
          return _buildLoadingWidget();
        }

        if (weatherProvider.error != null && weather == null) {
          return _buildErrorWidget(context, weatherProvider);
        }

        if (weather == null) {
          return _buildEmptyWidget(context, weatherProvider);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentWeather(context, weather),
            if (showForecast && forecast != null && forecast.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingM),
              _buildForecastSection(context, forecast),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, WeatherProvider weatherProvider) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Météo indisponible',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weatherProvider.error ?? 'Erreur de chargement',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => weatherProvider.fetchWeatherForDestination(destinationId),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Réessayer',
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context, WeatherProvider weatherProvider) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_outlined,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Météo',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Appuyez pour voir la météo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => weatherProvider.fetchWeatherForDestination(destinationId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Afficher',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather(BuildContext context, WeatherData weather) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.accentColor.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Center(
              child: Text(
                weather.getWeatherEmoji(),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weather.temperature.round()}°C',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ressenti ${weather.feelsLike.round()}°C',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  weather.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          _buildWeatherDetail(Icons.water_drop, '${weather.humidity}%'),
          _buildWeatherDetail(Icons.air, '${weather.windSpeed} km/h'),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: AppTheme.spacingXS),
      child: Column(
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection(BuildContext context, List<WeatherData> forecast) {
    if (forecast.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prévisions 7 jours',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          SizedBox(
            height: 65, 
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: forecast.length > 7 ? 7 : forecast.length,
              itemBuilder: (context, index) {
                final weather = forecast[index];
                return Container(
                  width: 50, 
                  margin: const EdgeInsets.only(right: AppTheme.spacingXS),
                  padding: const EdgeInsets.all(AppTheme.spacingXS),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weather.getWeatherEmoji(),
                        style: const TextStyle(fontSize: 14), 
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${weather.temperature.round()}°',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 8, 
                        ),
                      ),
                      Text(
                        _formatDate(weather.updatedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 6, 
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[date.weekday - 1];
  }
}
