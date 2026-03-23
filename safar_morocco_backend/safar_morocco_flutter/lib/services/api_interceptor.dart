import 'package:http/http.dart' as http;
import '../utils/jwt_interceptor.dart';

/// Intercepts HTTP responses and handles authentication errors
class ApiInterceptor {
  /// Process response and handle errors (401, 403)
  static Future<http.Response> interceptResponse(http.Response response) async {
    // Handle 401 Unauthorized - token expired or invalid
    if (response.statusCode == 401) {
      await JwtInterceptor.handleUnauthorized();
      throw Exception('Unauthorized: Your session has expired. Please login again.');
    }
    
    // Handle 403 Forbidden - insufficient permissions
    if (response.statusCode == 403) {
      JwtInterceptor.handleForbidden();
      throw Exception('Forbidden: You do not have permission to perform this action.');
    }
    
    return response;
  }
  
  /// Wrapper for GET requests with interceptor
  static Future<http.Response> get(
    http.Client client,
    Uri url,
    Map<String, String> headers,
  ) async {
    final response = await client.get(url, headers: headers);
    return interceptResponse(response);
  }
  
  /// Wrapper for POST requests with interceptor
  static Future<http.Response> post(
    http.Client client,
    Uri url,
    Map<String, String> headers,
    Object? body,
  ) async {
    final response = await client.post(url, headers: headers, body: body);
    return interceptResponse(response);
  }
  
  /// Wrapper for PUT requests with interceptor
  static Future<http.Response> put(
    http.Client client,
    Uri url,
    Map<String, String> headers,
    Object? body,
  ) async {
    final response = await client.put(url, headers: headers, body: body);
    return interceptResponse(response);
  }
  
  /// Wrapper for DELETE requests with interceptor
  static Future<http.Response> delete(
    http.Client client,
    Uri url,
    Map<String, String> headers,
  ) async {
    final response = await client.delete(url, headers: headers);
    return interceptResponse(response);
  }
}

