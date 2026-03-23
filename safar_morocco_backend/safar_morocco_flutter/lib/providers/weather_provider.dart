import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/index.dart';
import '../services/index.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService weatherService;

  final Map<int, WeatherData> _destinationWeather = {};
  final Map<int, List<WeatherData>> _destinationForecast = {};
  bool _isLoading = false;
  String? _error;
  int? _lastFetchedDestinationId;

  WeatherProvider({required this.weatherService});

  Map<int, WeatherData> get destinationWeather => _destinationWeather;
  Map<int, List<WeatherData>> get destinationForecast => _destinationForecast;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get lastFetchedDestinationId => _lastFetchedDestinationId;

  // Fetch current weather for a destination
  Future<void> fetchWeatherForDestination(int destinationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🌤️ Provider: Fetching weather for destination $destinationId');
      final weather = await weatherService.getWeatherByDestinationId(destinationId);
      _destinationWeather[destinationId] = weather;
      _lastFetchedDestinationId = destinationId;
      debugPrint('🌤️ Provider: Weather fetched successfully for destination $destinationId');
    } catch (e) {
      debugPrint('🌤️ Provider: Error fetching weather for destination $destinationId: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch weather forecast for a destination
  Future<void> fetchForecastForDestination(int destinationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🌤️ Provider: Fetching forecast for destination $destinationId');
      final forecast = await weatherService.getAllWeatherByDestinationId(destinationId);
      
      // Si seulement un jour disponible, générer 6 jours supplémentaires
      if (forecast.length == 1) {
        final baseWeather = forecast.first;
        final List<WeatherData> fullForecast = [];
        
        for (int i = 0; i < 7; i++) {
          final dayForecast = WeatherData(
            city: baseWeather.city,
            temperature: baseWeather.temperature + (i - 3) * 1.5, // Variation de température
            feelsLike: baseWeather.feelsLike + (i - 3) * 1.2,
            humidity: (baseWeather.humidity + (i % 3 - 1) * 5).clamp(30, 90),
            windSpeed: (baseWeather.windSpeed + (i % 2) * 2).clamp(0, 50),
            description: baseWeather.description,
            weatherIcon: baseWeather.weatherIcon,
            pressure: baseWeather.pressure,
            visibility: baseWeather.visibility,
            updatedAt: DateTime.now().add(Duration(days: i)),
          );
          fullForecast.add(dayForecast);
        }
        
        _destinationForecast[destinationId] = fullForecast;
        debugPrint('🌤️ Provider: Generated 7-day forecast for destination $destinationId');
      } else {
        _destinationForecast[destinationId] = forecast;
      }
      
      debugPrint('🌤️ Provider: Forecast fetched successfully for destination $destinationId (${_destinationForecast[destinationId]!.length} days)');
    } catch (e) {
      debugPrint('🌤️ Provider: Error fetching forecast for destination $destinationId: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch weather for date range
  Future<void> fetchWeatherForDateRange(
    int destinationId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🌤️ Provider: Fetching weather for destination $destinationId from $startDate to $endDate');
      final weatherList = await weatherService.getWeatherByDateRange(
        destinationId, 
        startDate, 
        endDate
      );
      _destinationForecast[destinationId] = weatherList;
      debugPrint('🌤️ Provider: Weather range fetched successfully for destination $destinationId (${weatherList.length} records)');
    } catch (e) {
      debugPrint('🌤️ Provider: Error fetching weather range for destination $destinationId: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch weather for multiple destinations
  Future<void> fetchWeatherForDestinations(List<int> destinationIds) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🌤️ Provider: Fetching weather for ${destinationIds.length} destinations');
      for (final destinationId in destinationIds) {
        try {
          final weather = await weatherService.getWeatherByDestinationId(destinationId);
          _destinationWeather[destinationId] = weather;
        } catch (e) {
          debugPrint('🌤️ Provider: Error fetching weather for destination $destinationId: $e');
        }
      }
      debugPrint('🌤️ Provider: Batch weather fetch completed');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  WeatherData? getWeatherForDestination(int destinationId) {
    return _destinationWeather[destinationId];
  }

  List<WeatherData>? getForecastForDestination(int destinationId) {
    return _destinationForecast[destinationId];
  }

  // Legacy methods for backward compatibility
  final Map<String, WeatherData> _weatherData = {};
  String? _lastFetchedCity;

  Map<String, WeatherData> get weatherData => _weatherData;
  String? get lastFetchedCity => _lastFetchedCity;

  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🌤️ Provider: Fetching weather for city $city');
      final weather = await weatherService.getWeather(city);
      _weatherData[city] = weather;
      _lastFetchedCity = city;
    } catch (e) {
      debugPrint('🌤️ Provider: Error fetching weather for city $city: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMultipleCities(List<String> cities) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🌤️ Provider: Fetching weather for ${cities.length} cities');
      for (final city in cities) {
        try {
          final weather = await weatherService.getWeather(city);
          _weatherData[city] = weather;
        } catch (e) {
          debugPrint('🌤️ Provider: Error fetching weather for city $city: $e');
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  WeatherData? getWeatherForCity(String city) {
    return _weatherData[city];
  }

  void clearCache() {
    weatherService.clearCache();
    _destinationWeather.clear();
    _destinationForecast.clear();
    _weatherData.clear();
    _lastFetchedDestinationId = null;
    _lastFetchedCity = null;
    debugPrint('🌤️ Provider: All caches cleared');
    notifyListeners();
  }

  void clearDestinationCache(int destinationId) {
    weatherService.clearDestinationCache(destinationId);
    _destinationWeather.remove(destinationId);
    _destinationForecast.remove(destinationId);
    if (_lastFetchedDestinationId == destinationId) {
      _lastFetchedDestinationId = null;
    }
    debugPrint('🌤️ Provider: Cache cleared for destination $destinationId');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
