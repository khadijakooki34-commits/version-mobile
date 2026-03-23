class WeatherData {
  final String city;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String weatherIcon;
  final double pressure;
  final double visibility;
  final DateTime updatedAt;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.weatherIcon,
    required this.pressure,
    required this.visibility,
    required this.updatedAt,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['destinationNom'] ?? json['city'] ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      feelsLike: (json['temperatureRessentie'] ?? json['temperatureRessentie'] ?? json['feelsLike'] ?? 0.0).toDouble(),
      humidity: (json['humidite'] ?? json['humidity'] ?? 0).toInt(),
      windSpeed: (json['vitesseVent'] ?? json['windSpeed'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      weatherIcon: json['iconeCode'] ?? json['weatherIcon'] ?? '01d',
      pressure: (json['pressionAtmospherique'] ?? json['pressure'] ?? 0.0).toDouble(),
      visibility: (json['visibilite'] ?? json['visibility'] ?? 0.0).toDouble(),
      updatedAt: DateTime.parse(json['derniereMiseAJour'] ?? json['updatedAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'description': description,
      'weatherIcon': weatherIcon,
      'pressure': pressure,
      'visibility': visibility,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String getWeatherEmoji() {
    if (weatherIcon.contains('01d')) return '☀️';
    if (weatherIcon.contains('01n')) return '🌙';
    if (weatherIcon.contains('02d') || weatherIcon.contains('02n')) return '⛅';
    if (weatherIcon.contains('03d') || weatherIcon.contains('03n')) return '☁️';
    if (weatherIcon.contains('04d') || weatherIcon.contains('04n')) return '☁️';
    if (weatherIcon.contains('09d') || weatherIcon.contains('09n')) return '🌧️';
    if (weatherIcon.contains('10d') || weatherIcon.contains('10n')) return '🌦️';
    if (weatherIcon.contains('11d') || weatherIcon.contains('11n')) return '⛈️';
    if (weatherIcon.contains('13d') || weatherIcon.contains('13n')) return '❄️';
    if (weatherIcon.contains('50d') || weatherIcon.contains('50n')) return '🌫️';
    return '🌡️';
  }
}
