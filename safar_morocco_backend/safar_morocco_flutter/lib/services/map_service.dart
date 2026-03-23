import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:math' as math;

class MapService {
  static const String _googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=';
  static const String _googleMapsDirectionsUrl = 'https://www.google.com/maps/dir/?api=1&destination=';

  // Génère un marqueur personnalisé pour une destination
  static Marker createDestinationMarker({
    required String id,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    BitmapDescriptor? icon,
  }) {
    return Marker(
      markerId: MarkerId(id),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: title,
        snippet: description,
      ),
      icon: icon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
  }

  // Génère les marqueurs pour plusieurs destinations
  static Set<Marker> createDestinationMarkers(List<Map<String, dynamic>> destinations) {
    final Set<Marker> markers = {};
    
    for (int i = 0; i < destinations.length; i++) {
      final destination = destinations[i];
      markers.add(createDestinationMarker(
        id: destination['id'].toString(),
        title: destination['nom'] ?? 'Destination',
        description: destination['description'] ?? '',
        latitude: destination['latitude'],
        longitude: destination['longitude'],
        icon: i == 0 
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }
    
    return markers;
  }

  // Crée une polyline pour visualiser un itinéraire
  static Polyline createItineraryPolyline({
    required String id,
    required List<LatLng> points,
    Color color = const Color(0xFF2196F3),
    double width = 5.0,
  }) {
    return Polyline(
      polylineId: PolylineId(id),
      color: color,
      width: width.toInt(),
      points: points,
      patterns: [
        PatternItem.dash(20.0),
        PatternItem.gap(10.0),
      ],
    );
  }

  // Génère une polyline à partir des coordonnées des destinations
  static Polyline createPolylineFromDestinations({
    required String id,
    required List<Map<String, dynamic>> destinations,
  }) {
    final List<LatLng> points = destinations.map((dest) {
      return LatLng(dest['latitude'], dest['longitude']);
    }).toList();

    return createItineraryPolyline(
      id: id,
      points: points,
      color: const Color(0xFF2196F3),
    );
  }

  // Calcule les bornes pour afficher tous les marqueurs
  static LatLngBounds calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(0, 0),
        northeast: const LatLng(0, 0),
      );
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // Ouvre Google Maps pour la navigation vers une destination
  static Future<bool> openNavigation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final Uri url = Uri.parse('$_googleMapsDirectionsUrl$latitude,$longitude');
    
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture de Google Maps: $e');
      return false;
    }
  }

  // Ouvre Google Maps pour rechercher à proximité
  static Future<bool> searchNearby({
    required double latitude,
    required double longitude,
    required String query,
  }) async {
    final Uri url = Uri.parse('$_googleMapsUrl$query&location=$latitude,$longitude');
    
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture de Google Maps: $e');
      return false;
    }
  }

  // Calcule la distance approximative entre deux points (en km)
  static double calculateDistance(
    double lat1, 
    double lon1, 
    double lat2, 
    double lon2
  ) {
    const double earthRadius = 6371; // Rayon de la Terre en km
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = 
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
      math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  // Convertit les degrés en radians
  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // Génère une couleur de marqueur basée sur la catégorie
  static BitmapDescriptor getMarkerIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'plage':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case 'montagne':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'ville':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'monument':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'museum':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
  }
}
