import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async'; 
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../utils/jwt_interceptor.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;
  static const String tokenKey = 'jwt_token';
  static const String userKey = 'user_data';

  final http.Client client;
  late SharedPreferences _prefs;
  String? _token;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _token = _prefs.getString(tokenKey);
    _checkTokenExpiry();
    await JwtInterceptor.checkAndHandleExpiry();
  }

  void _checkTokenExpiry() {
    if (_token != null) {
      try {
        if (JwtDecoder.isExpired(_token!)) {
          _token = null;
          _prefs.remove(tokenKey);
          _prefs.remove(userKey);
        }
      } catch (e) {
        debugPrint('Error checking token expiry: $e');
      }
    }
  }

  Future<Map<String, String>> getHeaders({bool includeAuth = true}) async {
    if (includeAuth) {
      await JwtInterceptor.checkAndHandleExpiry();
    }
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _token != null) {
      _checkTokenExpiry();
      if (_token != null) {
        headers['Authorization'] = 'Bearer $_token';
      }
    }

    return headers;
  }

  Future<http.Response> _interceptResponse(Future<http.Response> responseFuture) async {
    try {
      final response = await responseFuture;
      
      if (response.statusCode == 401) {
        await JwtInterceptor.handleUnauthorized();
        throw Exception('Unauthorized: Your session has expired. Please login again.');
      }
      
      if (response.statusCode == 403) {
        JwtInterceptor.handleForbidden();
        throw Exception('Forbidden: You do not have permission to perform this action.');
      }
      
      return response;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }

  Future<void> setToken(String token) async {
    _token = token;
    await _prefs.setString(tokenKey, token);
  }

  String? getToken() {
    return _token;
  }

  bool isLoggedIn() {
    if (_token == null) return false;
    _checkTokenExpiry();
    return _token != null;
  }

  Future<void> logout() async {
    _token = null;
    await _prefs.remove(tokenKey);
    await _prefs.remove(userKey);
  }

  // ============ AUTHENTICATION ENDPOINTS ============

  Future<http.Response> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');
    final body = {
      'email': email,
      'nom': '$firstName $lastName'.trim(),
      'motDePasse': password,
      'telephone': phoneNumber,
      'langue': 'fr',
    };

    try {
      debugPrint('Register URL: $uri');
      final response = await client
          .post(
            uri,
            headers: await getHeaders(includeAuth: false),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      
      debugPrint('Register status: ${response.statusCode}');
      return response;
    } on http.ClientException catch (e) {
      debugPrint('Register ClientException: $e');
      throw Exception('Network error: Failed to connect to server. Please check if the backend is running.');
    } on SocketException catch (e) {
      debugPrint('Register SocketException: $e');
      throw Exception('Network error: Cannot reach backend at $baseUrl');
    } on TimeoutException catch (e) {
      debugPrint('Register TimeoutException: $e');
      throw Exception('Network error: Request timeout. Backend may be slow or unreachable.');
    } catch (e) {
      debugPrint('Register error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    final body = {
      'email': email,
      'motDePasse': password,
    };

    try {
      debugPrint('Login URL: $uri');
      debugPrint('Login body: $body');
      
      // CORRECTION: utilisez client.post() directement au lieu de ApiInterceptor.post()
      final response = await client
          .post(
            uri,
            headers: await getHeaders(includeAuth: false),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      
      debugPrint('Login status: ${response.statusCode}');
      debugPrint('Login response: ${response.body}');
      return response;
    } on http.ClientException catch (e) {
      debugPrint('Login ClientException: $e');
      throw Exception('Network error: Failed to connect to server. Please check if the backend is running.');
    } on SocketException catch (e) {
      debugPrint('Login SocketException: $e');
      throw Exception('Network error: Cannot reach backend at $baseUrl');
    } on TimeoutException catch (e) {
      debugPrint('Login TimeoutException: $e');
      throw Exception('Network error: Request timeout. Backend may be slow.');
    } catch (e) {
      debugPrint('Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<http.Response> googleSignIn({required String idToken}) async {
    final uri = Uri.parse('$baseUrl/auth/google');
    final body = {'idToken': idToken}; // Backend expects idToken

    try {
      return await _interceptResponse(
        client.post(
          uri,
          headers: await getHeaders(includeAuth: false),
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  Future<http.Response> forgotPassword({required String email}) async {
    final uri = Uri.parse('$baseUrl/auth/forgot-password');
    final body = {'email': email};

    try {
      return await _interceptResponse(
        client.post(
          uri,
          headers: await getHeaders(includeAuth: false),
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Forgot password failed: $e');
    }
  }

  Future<http.Response> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/reset-password');
    final body = {
      'token': token,
      'newPassword': newPassword,
    };

    try {
      return await _interceptResponse(
        client.post(
          uri,
          headers: await getHeaders(includeAuth: false),
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Reset password failed: $e');
    }
  }

  Future<http.Response> verify2FA({
    required String email,
    required String code,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/2fa/verify');
    final body = {
      'email': email,
      'code': code,
    };

    try {
      return await client
          .post(
            uri,
            headers: await getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw Exception('2FA verification failed: $e');
    }
  }

  // ============ USERS ENDPOINTS ============

  Future<http.Response> getUserProfile() async {
    final uri = Uri.parse('$baseUrl/utilisateurs/profile');

    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<http.Response> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? profileImage,
  }) async {
    final uri = Uri.parse('$baseUrl/utilisateurs/profile');
    final body = {
      'nom': '$firstName $lastName'.trim(),
      'telephone': phoneNumber,
      if (profileImage != null) 'photoUrl': profileImage,
    };

    try {
      return await _interceptResponse(
        client.put(uri, headers: await getHeaders(), body: jsonEncode(body))
            .timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // ============ DESTINATIONS ENDPOINTS ============

  Future<http.Response> getDestinations({int page = 0, int size = 10}) async {
    final uri = Uri.parse('$baseUrl/destinations');

    try {
      return await client
          .get(
            uri,
            headers: await getHeaders(),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw Exception('Failed to fetch destinations: $e');
    }
  }

  Future<http.Response> getDestinationsByCategory(String category) async {
    final uri = Uri.parse('$baseUrl/destinations/category/$category');

    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch destinations by category: $e');
    }
  }

  Future<http.Response> getDestinationById(int id) async {
    final uri = Uri.parse('$baseUrl/destinations/$id');

    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch destination: $e');
    }
  }

  Future<http.Response> searchDestinations(String query) async {
    final uri = Uri.parse('$baseUrl/destinations/search')
        .replace(queryParameters: {'query': query});

    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to search destinations: $e');
    }
  }

  Future<http.Response> filterDestinations({
    String? category,
    double? minRating,
  }) async {
    final params = <String, String>{};
    if (category != null) params['category'] = category;
    if (minRating != null) params['minRating'] = minRating.toString();

    final uri = Uri.parse('$baseUrl/destinations/filter').replace(queryParameters: params);

    try {
      return await client
          .get(
            uri,
            headers: await getHeaders(),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw Exception('Failed to filter destinations: $e');
    }
  }

  // ============ REVIEWS ENDPOINTS ============

  Future<http.Response> createReview({
    required int destinationId,
    required double rating,
    required String comment,
  }) async {
    final uri = Uri.parse('$baseUrl/avis');
    final body = {
      'destinationId': destinationId,
      'note': rating,
      'commentaire': comment,
    };

    try {
      return await _interceptResponse(
        client.post(uri, headers: await getHeaders(), body: jsonEncode(body))
            .timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  Future<http.Response> getReviewsByDestination(int destinationId) async {
    final uri = Uri.parse('$baseUrl/avis/destination/$destinationId');

    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  // ============ EVENTS ENDPOINTS ============

  Future<http.Response> getEvents({int page = 0, int size = 100}) async {
    final uri = Uri.parse('$baseUrl/evenements');

    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  Future<http.Response> getUpcomingEvents() async {
    final uri = Uri.parse('$baseUrl/evenements/upcoming');
    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch upcoming events: $e');
    }
  }

  Future<http.Response> getEventById(int id) async {
    final uri = Uri.parse('$baseUrl/evenements/$id');
    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch event: $e');
    }
  }

  // ============ RESERVATIONS ENDPOINTS ============

  Future<http.Response> getMyReservations() async {
    final uri = Uri.parse('$baseUrl/reservations/my');
    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch reservations: $e');
    }
  }

  Future<http.Response> createReservation(int evenementId) async {
    final uri = Uri.parse('$baseUrl/reservations/$evenementId');
    try {
      return await _interceptResponse(
        client.post(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to create reservation: $e');
    }
  }

  Future<http.Response> cancelReservation(int reservationId) async {
    final uri = Uri.parse('$baseUrl/reservations/$reservationId');
    try {
      return await _interceptResponse(
        client.delete(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to cancel reservation: $e');
    }
  }

  // ============ ITINERAIRES (ITINERARIES) ENDPOINTS ============

  Future<http.Response> getItineraries(int utilisateurId) async {
    final uri = Uri.parse('$baseUrl/itineraires/utilisateur/$utilisateurId');
    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch itineraries: $e');
    }
  }

  Future<http.Response> getItineraryById(int id, int utilisateurId) async {
    final uri = Uri.parse('$baseUrl/itineraires/$id/utilisateur/$utilisateurId');
    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch itinerary: $e');
    }
  }

  Future<http.Response> createItinerary(int utilisateurId, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/itineraires/utilisateur/$utilisateurId');
    try {
      debugPrint('Create Itinerary URL: $uri');
      debugPrint('Create Itinerary body: $body');
      return await _interceptResponse(
        client.post(
          uri,
          headers: await getHeaders(),
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      debugPrint('Create Itinerary error: $e');
      throw Exception('Failed to create itinerary: $e');
    }
  }

  Future<http.Response> updateItinerary(int id, int utilisateurId, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/itineraires/$id/utilisateur/$utilisateurId');
    try {
      return await _interceptResponse(
        client.put(
          uri,
          headers: await getHeaders(),
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to update itinerary: $e');
    }
  }

  Future<http.Response> deleteItinerary(int id, int utilisateurId) async {
    final uri = Uri.parse('$baseUrl/itineraires/$id/utilisateur/$utilisateurId');
    try {
      return await _interceptResponse(
        client.delete(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to delete itinerary: $e');
    }
  }

  Future<http.Response> addDestinationToItinerary(int itineraryId, int destinationId, int utilisateurId) async {
    final uri = Uri.parse('$baseUrl/itineraires/$itineraryId/destinations/$destinationId/utilisateur/$utilisateurId');
    try {
      return await _interceptResponse(
        client.post(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to add destination to itinerary: $e');
    }
  }

  Future<http.Response> removeDestinationFromItinerary(int itineraryId, int destinationId, int utilisateurId) async {
    final uri = Uri.parse('$baseUrl/itineraires/$itineraryId/destinations/$destinationId/utilisateur/$utilisateurId');
    try {
      return await _interceptResponse(
        client.delete(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to remove destination from itinerary: $e');
    }
  }

  Future<http.Response> optimizeItinerary(int id, int utilisateurId) async {
    final uri = Uri.parse('$baseUrl/itineraires/$id/optimiser/utilisateur/$utilisateurId');
    try {
      return await _interceptResponse(
        client.post(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to optimize itinerary: $e');
    }
  }

  // ============ ADMIN EVENTS ENDPOINTS ============

  Future<http.Response> adminCreateEvent({required int destinationId, required Map<String, dynamic> body}) async {
    final uri = Uri.parse('$baseUrl/evenements/destination/$destinationId');
    try {
      return await _interceptResponse(
        client.post(
          uri,
          headers: await getHeaders(),
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<http.Response> adminUpdateEvent(int id, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/evenements/$id');
    try {
      return await _interceptResponse(
        client.put(
          uri,
          headers: await getHeaders(),
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Future<http.Response> adminDeleteEvent(int id) async {
    final uri = Uri.parse('$baseUrl/evenements/$id');
    try {
      return await _interceptResponse(
        client.delete(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // ============ RECOMMENDATIONS ENDPOINTS ============

  Future<http.Response> getRecommendations() async {
    final uri = Uri.parse('$baseUrl/recommendations');

    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch recommendations: $e');
    }
  }

  // ============ WEATHER ENDPOINTS ============

  Future<http.Response> getWeather(String city) async {
    final uri = Uri.parse('$baseUrl/weather/$city');

    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch weather: $e');
    }
  }

  // ============ ADMIN ENDPOINTS ============

  Future<http.Response> getAdminUsers({int page = 0, int size = 10}) async {
    final uri = Uri.parse('$baseUrl/admin/users')
        .replace(queryParameters: {'page': page.toString(), 'size': size.toString()});

    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch admin users: $e');
    }
  }

  Future<http.Response> blockUser(int userId) async {
    final uri = Uri.parse('$baseUrl/admin/users/block/$userId');

    try {
      return await _interceptResponse(
        client.put(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  Future<http.Response> changeUserRole(int userId, String role) async {
    final body = {'role': role.toUpperCase()};
    final adminUri = Uri.parse('$baseUrl/admin/users/$userId/role');
    final userUri = Uri.parse('$baseUrl/utilisateurs/$userId/role');

    try {
      final adminResponse = await _interceptResponse(
        client.put(adminUri, headers: await getHeaders(), body: jsonEncode(body))
            .timeout(const Duration(seconds: 30)),
      );

      // Fallback for backend versions where role change exists on /utilisateurs/{id}/role
      if (adminResponse.statusCode == 404) {
        return await _interceptResponse(
          client.put(userUri, headers: await getHeaders(), body: jsonEncode(body))
              .timeout(const Duration(seconds: 30)),
        );
      }

      return adminResponse;
    } catch (e) {
      throw Exception('Failed to change user role: $e');
    }
  }

  Future<http.Response> createDestination(Map<String, dynamic> destinationData) async {
    final uri = Uri.parse('$baseUrl/destinations');
    
    // Backend expects French field names: nom, categorie, type
    final body = {
      'nom': destinationData['name'],
      'description': destinationData['description'] ?? '',
      'histoire': destinationData['history'] ?? '',
      'type': destinationData['type'] ?? '',
      'latitude': destinationData['latitude'],
      'longitude': destinationData['longitude'],
      'categorie': destinationData['category'],
    };

    try {
      return await _interceptResponse(
        client.post(uri, headers: await getHeaders(), body: jsonEncode(body))
            .timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to create destination: $e');
    }
  }

  Future<http.Response> createDestinationWithImage({
    required Map<String, dynamic> destinationData,
    required File imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/destinations');

    try {
      // Create multipart request for file upload
      final request = http.MultipartRequest('POST', uri);

      // Add headers (authorization)
      final headers = await getHeaders();
      request.headers.addAll(headers);

      // Add form fields with French field names
      request.fields['nom'] = destinationData['name'] ?? '';
      request.fields['description'] = destinationData['description'] ?? '';
      request.fields['histoire'] = destinationData['history'] ?? '';
      request.fields['type'] = destinationData['type'] ?? '';
      request.fields['latitude'] = destinationData['latitude'].toString();
      request.fields['longitude'] = destinationData['longitude'].toString();
      request.fields['categorie'] = destinationData['category'] ?? '';

      // Add image file
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send request and process response
      final response = await request.send().timeout(const Duration(seconds: 60));
      final responseBody = await response.stream.bytesToString();

      return http.Response(
        responseBody,
        response.statusCode,
        headers: response.headers,
      );
    } catch (e) {
      throw Exception('Failed to create destination with image: $e');
    }
  }

  Future<http.Response> uploadDestinationMedia({
    required int destinationId,
    required File imageFile,
    String? description,
  }) async {
    final uri = Uri.parse('$baseUrl/media/upload/destination/$destinationId');

    try {
      final request = http.MultipartRequest('POST', uri);
      final headers = await getHeaders();
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      if (description != null && description.trim().isNotEmpty) {
        request.fields['description'] = description.trim();
      }

      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      final response = await request.send().timeout(const Duration(seconds: 60));
      final responseBody = await response.stream.bytesToString();
      return http.Response(
        responseBody,
        response.statusCode,
        headers: response.headers,
      );
    } catch (e) {
      throw Exception('Failed to upload destination media: $e');
    }
  }

  Future<http.Response> updateDestination(
    int destinationId,
    Map<String, dynamic> destinationData,
  ) async {
    final uri = Uri.parse('$baseUrl/destinations/$destinationId');
    final body = {
      'nom': destinationData['name'],
      'description': destinationData['description'] ?? '',
      'histoire': destinationData['history'] ?? '',
      'type': destinationData['type'] ?? '',
      'latitude': destinationData['latitude'],
      'longitude': destinationData['longitude'],
      'categorie': destinationData['category'],
    };

    try {
      return await _interceptResponse(
        client.put(uri, headers: await getHeaders(), body: jsonEncode(body))
            .timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to update destination: $e');
    }
  }

  Future<http.Response> deleteDestination(int destinationId) async {
    final uri = Uri.parse('$baseUrl/admin/destinations/$destinationId');

    try {
      return await _interceptResponse(
        client.delete(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to delete destination: $e');
    }
  }

  Future<http.Response> getAdminStatistics() async {
    final uri = Uri.parse('$baseUrl/admin/statistics');

    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch statistics: $e');
    }
  }

  // ============ FAVORITES ENDPOINTS ============

  Future<http.Response> addFavorite(int destinationId) async {
    final uri = Uri.parse('$baseUrl/favoris/$destinationId');

    try {
      return await _interceptResponse(
        client.post(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  Future<http.Response> removeFavorite(int destinationId) async {
    final uri = Uri.parse('$baseUrl/favoris/$destinationId');

    try {
      return await _interceptResponse(
        client.delete(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  Future<http.Response> checkFavorite(int destinationId) async {
    final uri = Uri.parse('$baseUrl/favoris/check/$destinationId');

    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to check favorite: $e');
    }
  }

  Future<http.Response> getMyFavorites() async {
    final uri = Uri.parse('$baseUrl/favoris/my');

    try {
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  // ==================== WEATHER API ====================

  Future<http.Response> getWeatherByDestination(int destinationId) async {
    final uri = Uri.parse('$baseUrl/meteo/destination/$destinationId');

    try {
      debugPrint('API: GET $uri');
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      debugPrint('API Error: Failed to fetch weather for destination $destinationId');
      throw Exception('Failed to fetch weather: $e');
    }
  }

  Future<http.Response> getAllWeatherByDestination(int destinationId) async {
    final uri = Uri.parse('$baseUrl/meteo/destination/$destinationId/all');

    try {
      debugPrint('API: GET $uri');
      return await _interceptResponse(
        client.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      debugPrint('API Error: Failed to fetch all weather for destination $destinationId');
      throw Exception('Failed to fetch weather forecast: $e');
    }
  }

  Future<http.Response> getWeatherByDateRange(
    int destinationId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    final uri = Uri.parse('$baseUrl/meteo/destination/$destinationId/range');
    
    try {
      debugPrint('API: GET $uri?debut=${startDate.toIso8601String()}&fin=${endDate.toIso8601String()}');
      return await _interceptResponse(
        client.get(
          uri.replace(queryParameters: {
            'debut': startDate.toIso8601String(),
            'fin': endDate.toIso8601String(),
          }),
          headers: await getHeaders()
        ).timeout(const Duration(seconds: 30)),
      );
    } catch (e) {
      debugPrint('API Error: Failed to fetch weather by date range for destination $destinationId');
      throw Exception('Failed to fetch weather by date range: $e');
    }
  }
}
