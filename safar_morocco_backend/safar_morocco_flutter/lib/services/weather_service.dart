import 'dart:convert';
import 'api_service.dart';
import '../models/index.dart';
import 'package:flutter/foundation.dart';

class WeatherService {
  final ApiService apiService;
  final Map<int, WeatherData> _weatherCache = {};

  WeatherService({required this.apiService});

  Future<WeatherData> getWeatherByDestinationId(int destinationId) async {
    try {
      // Check cache first
      if (_weatherCache.containsKey(destinationId)) {
        final cachedData = _weatherCache[destinationId]!;
        final now = DateTime.now();
        final diff = now.difference(cachedData.updatedAt).inMinutes;
        if (diff < 30) {
          // Cache valid for 30 minutes
          debugPrint('Using cached weather for destination $destinationId');
          return cachedData;
        }
      }

      debugPrint('Fetching weather for destination $destinationId');
      final response = await apiService.getWeatherByDestination(destinationId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = WeatherData.fromJson(data);
        _weatherCache[destinationId] = weather;
        debugPrint('Weather data cached for destination $destinationId');
        return weather;
      } else {
        throw Exception('Échec de la récupération des données météo: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      throw Exception('Erreur lors de la récupération des données météo: $e');
    }
  }

  Future<List<WeatherData>> getAllWeatherByDestinationId(int destinationId) async {
    try {
      debugPrint('Fetching all weather data for destination $destinationId');
      final response = await apiService.getAllWeatherByDestination(destinationId);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<WeatherData> weatherList = data
            .map((weatherJson) => WeatherData.fromJson(weatherJson))
            .toList();
        
        // Cache the latest weather data
        if (weatherList.isNotEmpty) {
          _weatherCache[destinationId] = weatherList.first;
        }
        
        debugPrint('Retrieved ${weatherList.length} weather records');
        return weatherList;
      } else {
        throw Exception('Échec de la récupération des prévisions météo: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching weather forecast: $e');
      throw Exception('Erreur lors de la récupération des prévisions météo: $e');
    }
  }

  Future<List<WeatherData>> getWeatherByDateRange(
    int destinationId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      debugPrint('Fetching weather for destination $destinationId from $startDate to $endDate');
      final response = await apiService.getWeatherByDateRange(
        destinationId, 
        startDate, 
        endDate
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<WeatherData> weatherList = data
            .map((weatherJson) => WeatherData.fromJson(weatherJson))
            .toList();
        
        debugPrint('Retrieved ${weatherList.length} weather records for date range');
        return weatherList;
      } else {
        throw Exception('Échec de la récupération des données météo par plage de dates: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching weather by date range: $e');
      throw Exception('Erreur lors de la récupération des données météo par plage de dates: $e');
    }
  }

  void clearCache() {
    _weatherCache.clear();
    debugPrint('Weather cache cleared');
  }

  void clearDestinationCache(int destinationId) {
    _weatherCache.remove(destinationId);
    debugPrint('Weather cache cleared for destination $destinationId');
  }

  // Legacy method for backward compatibility
  Future<WeatherData> getWeather(String city) async {
    try {
      debugPrint('Fetching weather for city: $city');
      final response = await apiService.getWeather(city);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = WeatherData.fromJson(data);
        return weather;
      } else {
        throw Exception('Échec de la récupération des données météo: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching weather for city: $e');
      throw Exception('Erreur lors de la récupération des données météo: $e');
    }
  }
}
