import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class OpenStreetMapService {
  // Crée un marqueur pour une destination
  static Marker createDestinationMarker({
    required String id,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
  }) {
    return Marker(
      point: LatLng(latitude, longitude),
      width: 80,
      height: 80,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 24,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Génère les marqueurs pour plusieurs destinations
  static List<Marker> createDestinationMarkers(List<Map<String, dynamic>> destinations) {
    final List<Marker> markers = [];
    
    for (int i = 0; i < destinations.length; i++) {
      final destination = destinations[i];
      markers.add(createDestinationMarker(
        id: destination['id'].toString(),
        title: destination['nom'] ?? 'Destination',
        description: destination['description'] ?? '',
        latitude: destination['latitude'],
        longitude: destination['longitude'],
      ));
    }
    
    return markers;
  }

  // Crée une polyline pour visualiser un itinéraire
  static Polyline createItineraryPolyline({
    required String id,
    required List<LatLng> points,
    Color color = Colors.blue,
    double strokeWidth = 4.0,
  }) {
    return Polyline(
      points: points,
      color: color,
      strokeWidth: strokeWidth,
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
      color: Colors.blue,
    );
  }

  // Calcule les bornes pour afficher tous les marqueurs
  static LatLngBounds calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(
        const LatLng(0, 0),
        const LatLng(0, 0),
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
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  // Ouvre OpenStreetMap pour la navigation d'itinéraire complet
  static Future<bool> openItineraryNavigation({
    required List<Map<String, dynamic>> destinations,
  }) async {
    if (destinations.isEmpty || destinations.length < 2) return false;
    
    // Construire l'URL pour un itinéraire avec plusieurs points
    final firstDest = destinations.first;
    final lastDest = destinations.last;
    
    // Format: https://www.openstreetmap.org/directions?from=lat,lon&to=lat,lon
    final Uri url = Uri.parse(
      'https://www.openstreetmap.org/directions?'
      'from=${firstDest['latitude']},${firstDest['longitude']}'
      '&to=${lastDest['latitude']},${lastDest['longitude']}'
    );
    
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture d\'OpenStreetMap: $e');
      return false;
    }
  }

  // Ouvre OpenStreetMap pour la navigation (single point)
  static Future<bool> openNavigation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final Uri url = Uri.parse('https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude#map=15/$latitude/$longitude');
    
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture d\'OpenStreetMap: $e');
      return false;
    }
  }

  // Ouvre OpenStreetMap pour rechercher à proximité
  static Future<bool> searchNearby({
    required double latitude,
    required double longitude,
    required String query,
  }) async {
    final Uri url = Uri.parse('https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude&query=$query');
    
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture d\'OpenStreetMap: $e');
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

  // Crée une carte OpenStreetMap de base
  static Widget createMap({
    required List<Marker> markers,
    List<Polyline>? polylines,
    LatLng? center,
    double zoom = 13.0,
    bool showZoomControls = true,
  }) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center ?? const LatLng(33.5731, -7.5898), // Maroc par défaut
        initialZoom: zoom,
        minZoom: 3.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.safar_morocco',
        ),
        MarkerLayer(markers: markers),
        if (polylines != null) PolylineLayer(polylines: polylines),
        if (showZoomControls) const RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              textStyle: TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}
