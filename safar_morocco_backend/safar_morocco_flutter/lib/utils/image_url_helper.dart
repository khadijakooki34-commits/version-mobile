import 'constants.dart';

/// Resolves image URLs from the backend.
/// Backend returns relative paths like /uploads/filename.jpg.
/// Converts them to full URLs for CachedNetworkImage/Image.network.
String resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  // Already absolute (http/https)
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  // Relative path - prepend server base URL
  const base = AppConstants.serverBaseUrl;
  final path = url.startsWith('/') ? url : '/$url';
  return '$base$path';
}

