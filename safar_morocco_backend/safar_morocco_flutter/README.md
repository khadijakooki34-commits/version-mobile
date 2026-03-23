# Safar Morocco Flutter Frontend

A production-ready Flutter mobile application for discovering tourism destinations, events, and personalized travel recommendations across Morocco. Features real-time chat assistance, weather integration, and admin dashboard for platform management.

## Project Overview

**Safar Morocco** is an intelligent interactive tourism discovery platform built with Flutter 3.0+. It provides users with:
- Destination discovery with search and filtering
- Personalized travel recommendations
- Event discovery and management
- Real-time chatbot assistance
- Weather forecasting for travel planning
- User-generated reviews and ratings
- JWT-based authentication with Google OAuth2
- Two-factor authentication (2FA)

### Key Features

#### User Features
- 🏠 **Home Screen**: Browse destinations in list or grid view with pagination
- 🔍 **Advanced Search**: Filter by category, rating, and keyword
- 📍 **Destination Details**: View complete information with images, reviews, and ratings
- ⭐ **Reviews**: Write and read user reviews with 5-star rating system
- 🎉 **Events Discovery**: View upcoming events with detailed information
- 🎯 **Smart Recommendations**: AI-powered travel recommendations with match scores
- ☀️ **Weather Integration**: Real-time weather for travel planning
- 💬 **Chatbot**: 24/7 travel assistance via chatbot
- 👤 **Profile Management**: View and edit user profile

#### Admin Features
- 📊 **Dashboard**: Overview of platform statistics
- 👥 **User Management**: View users, manage permissions, block/unblock accounts
- 📈 **Statistics**: Detailed analytics on destinations, users, and reviews
- 🗑️ **Content Moderation**: Delete inappropriate content

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models with JSON serialization
│   ├── user_model.dart
│   ├── destination_model.dart
│   ├── review_model.dart
│   ├── event_model.dart
│   ├── weather_model.dart
│   ├── chatbot_model.dart
│   ├── recommendation_model.dart
│   ├── statistics_model.dart
│   └── index.dart           # Barrel export
├── services/                # Business logic & API integration
│   ├── api_service.dart     # HTTP client with JWT management
│   ├── auth_service.dart
│   ├── destination_service.dart
│   ├── review_service.dart
│   ├── event_service.dart
│   ├── chatbot_service.dart
│   ├── recommendation_service.dart
│   ├── weather_service.dart
│   ├── user_service.dart
│   ├── user_admin_service.dart
│   └── index.dart
├── providers/               # State management (Provider pattern)
│   ├── auth_provider.dart
│   ├── destination_provider.dart
│   ├── review_provider.dart
│   ├── event_provider.dart
│   ├── chatbot_provider.dart
│   ├── recommendation_provider.dart
│   ├── weather_provider.dart
│   ├── user_provider.dart
│   ├── admin_provider.dart
│   └── index.dart
├── screens/                 # UI Screens
│   ├── auth_screens/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── user_screens/
│   │   ├── home_screen.dart
│   │   ├── destination_details_screen.dart
│   │   ├── search_destinations_screen.dart
│   │   ├── write_review_screen.dart
│   │   ├── chatbot_screen.dart
│   │   ├── recommendations_screen.dart
│   │   ├── events_screen.dart
│   │   ├── weather_screen.dart
│   │   ├── profile_screen.dart
│   │   └── edit_profile_screen.dart
│   └── admin_screens/
│       ├── admin_dashboard_screen.dart
│       ├── admin_users_screen.dart
│       └── admin_statistics_screen.dart
├── widgets/                 # Reusable UI components
│   ├── common_widgets.dart
│   ├── destination_card.dart
│   ├── review_card.dart
│   └── index.dart
└── utils/                   # Utilities & constants
    ├── constants.dart
    ├── app_theme.dart
    ├── validation_util.dart
    ├── date_format_util.dart
    └── index.dart
```

## Getting Started

### Prerequisites

- Flutter 3.0 or higher
- Dart 2.17 or higher
- Android SDK (for Android development)
- Xcode (for iOS development)
- Backend API running on `http://localhost:8088/api`

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd safar_morocco_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your API endpoints and Google OAuth credentials
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### For Specific Platforms

**Android:**
```bash
flutter run -d android
```

**iOS:**
```bash
flutter run -d ios
```

**Web:**
```bash
flutter run -d chrome
```

## Configuration

### API Configuration

The app connects to the backend API at `http://localhost:8088/api`. To change this:

1. Open `lib/utils/constants.dart`
2. Update `AppConstants.baseUrl` with your API endpoint:
   ```dart
   static const String baseUrl = 'http://your-api-url:8088/api';
   ```

### Google OAuth Setup

For Google Sign-In to work:

1. **Android**: Update `com.example.safar_morocco` in `android/app/build.gradle` with your package name
2. **iOS**: Configure URL schemes in Xcode
3. Add your Google OAuth credentials to `lib/utils/constants.dart`

### Theme Customization

Modify colors and styling in `lib/utils/app_theme.dart`:

```dart
static const Color primaryColor = Color(0xFF6B4423); // Brown
static const Color secondaryColor = Color(0xFFD4A574); // Tan
static const Color accentColor = Color(0xFFE8B86B);   // Gold
```

## Architecture

This project follows **Clean Architecture** with clear separation of concerns:

```
Presentation Layer (Screens & Widgets)
           ↓
State Management Layer (Providers)
           ↓
Business Logic Layer (Services)
           ↓
Data Layer (Models & API)
```

### Data Flow

1. **UI Layer**: Screens & Widgets build using `Consumer<Provider>`
2. **Provider Layer**: Manages state using `ChangeNotifier`
3. **Service Layer**: Handles business logic and API calls
4. **API Service**: Makes HTTP requests with JWT authentication

### Authentication Flow

```
1. User enters credentials on LoginScreen
2. LoginScreen calls AuthProvider.login()
3. AuthProvider calls AuthService.login()
4. AuthService calls ApiService with credentials
5. Backend returns JWT token
6. ApiService stores token in SharedPreferences
7. All subsequent requests include Bearer token
8. Token expiry checked before each request
9. Auto-logout on expired token
```

## Features & Implementation Details

### Authentication System

- **JWT-based Authentication**: Secure token-based authentication
- **OAuth2 Google Sign-In**: One-tap authentication with Google accounts
- **Two-Factor Authentication**: Optional 2FA for enhanced security
- **Token Persistence**: Tokens stored securely in SharedPreferences
- **Auto Token Refresh**: Checks token expiry before each request

### Pagination

Destinations and events support pagination:
- Page size: 20 items
- Tracks `hasMore` to know if more items available
- `loadMore()` method to fetch next page

### State Management with Provider

All screens use the `Consumer` pattern for reactive UI:

```dart
Consumer<DestinationProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) return LoadingWidget();
    if (provider.error != null) return ErrorWidget(...);
    return ListView(...); // Build UI
  },
)
```

### Error Handling

Comprehensive error handling across all layers:
- Network errors show ErrorWidget with retry button
- Validation errors shown on form fields
- Toast notifications for user feedback
- Error clearing after dismissal

### Validation

Centralized validation in `lib/utils/validation_util.dart`:
- Email validation
- Password validation (min 8 chars, mixed case, number, special char)
- Phone number validation
- Name validation
- Rating validation (1-5)
- Comment length validation (10-500 chars)

## Code Examples

### Using a Provider

```dart
// Reading data
final destinations = context.read<DestinationProvider>().destinations;

// Listening to changes
Consumer<DestinationProvider>(
  builder: (context, provider, _) {
    return ListView(
      children: provider.destinations
          .map((d) => DestinationCard(destination: d))
          .toList(),
    );
  },
)

// Manually triggering refresh
ElevatedButton(
  onPressed: () => context.read<DestinationProvider>().fetchDestinations(),
  child: const Text('Refresh'),
)
```

### Authenticated API Call

```dart
// In service layer
Future<List<Destination>> getDestinations() async {
  // ApiService automatically adds Authorization header
  // and checks token expiry
  final response = await apiService.get('/destinations?page=0&size=20');
  final data = response['content'] as List;
  return data.map((d) => Destination.fromJson(d)).toList();
}
```

### Form Validation

```dart
TextField(
  validator: (value) => ValidationUtil.validateEmail(value),
  decoration: InputDecoration(
    hintText: 'Enter email',
    errorText: _emailError,
  ),
)
```

## API Endpoints

The app integrates with the following backend endpoint groups:

### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `POST /auth/google-sign-in` - Google OAuth login
- `POST /auth/verify-2fa` - Verify 2FA code

### Users
- `GET /users/profile` - Get user profile
- `PUT /users/profile` - Update user profile

### Destinations
- `GET /destinations` - List destinations (paginated)
- `GET /destinations/{id}` - Get destination details
- `GET /destinations/search` - Search destinations
- `GET /destinations/filter` - Filter destinations

### Reviews
- `POST /reviews` - Create review
- `GET /reviews/destination/{id}` - Get reviews for destination

### Events
- `GET /events` - List events

### Chatbot
- `POST /chatbot/message` - Send message to chatbot

### Recommendations
- `GET /recommendations` - Get personalized recommendations

### Weather
- `GET /weather` - Get weather for city

### Admin
- `GET /admin/users` - List users
- `PUT /admin/users/{id}/block` - Block user
- `DELETE /admin/destinations/{id}` - Delete destination
- `GET /admin/statistics` - Get platform statistics

## Testing

### Manual Testing with Postman

1. Import `Safar_Morocco_API.postman_collection.json`
2. Set up environment variables:
   - `base_url`: `http://localhost:8088/api`
   - `jwt_token`: Obtained from login endpoint
3. Test endpoints in order: Register → Login → Use other endpoints

### Running Flutter Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/providers/auth_provider_test.dart
```

## Troubleshooting

### Common Issues

**"Connection refused" error**
- Ensure backend API is running on `http://localhost:8088`
- Check firewall settings
- Verify API base URL in `constants.dart`

**"JWT token expired" error**
- App automatically logs out and redirects to login
- Login again to get a new token

**"Google Sign-In fails"**
- Verify Google OAuth credentials are configured
- Check package name matches in Google Cloud Console
- Ensure SHA-1 fingerprint is added to Android settings

**UI not updating**
- Ensure using `Consumer` or `context.watch()` instead of `context.read()`
- Check that Provider is properly initialized in `main.dart`

## Performance Optimization

- **Image Caching**: Using `cached_network_image` for efficient image loading
- **Weather Caching**: Weather data cached for 30 minutes
- **Pagination**: Lazy loading destinations and events
- **Provider Lazy Init**: Providers only initialize when first accessed
- **Widget Optimization**: Using `const` constructors where possible

## Security Considerations

- JWT tokens stored in SharedPreferences (adequate for mobile apps)
- HTTPS should be used in production
- Google OAuth credentials should be environment-specific
- 2FA provides additional account security
- Admin endpoints require admin role

## Deployment

### Building for Production

**Android:**
```bash
flutter build apk --release
# or for App Bundle (Google Play)
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

### Pre-deployment Checklist

- [ ] Update API base URL to production server
- [ ] Enable HTTPS for API calls
- [ ] Configure production Google OAuth credentials
- [ ] Update app version in `pubspec.yaml`
- [ ] Load test with expected user base
- [ ] Test all features on target devices
- [ ] Enable error logging and monitoring
- [ ] Set up crash reporting
- [ ] Review security settings

## Dependencies

Key dependencies used in this project:

- **http**: REST API communication
- **provider**: State management
- **shared_preferences**: Local data persistence
- **google_sign_in**: OAuth2 authentication
- **jwt_decoder**: JWT token parsing
- **cached_network_image**: Efficient image loading
- **intl**: Date and time formatting
- **flutter_localizations**: Multi-language support

See `pubspec.yaml` for complete dependency list and versions.

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -am 'Add new feature'`
3. Push to branch: `git push origin feature/your-feature`
4. Submit a pull request

Code style guidelines:
- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused
- Write tests for new features

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
1. Check existing GitHub Issues
2. Create a new issue with detailed description
3. Include device/OS information and steps to reproduce

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

## Contact

For more information about Safar Morocco project, contact the development team.

---

**Happy coding! 🚀 Explore Morocco with Safar Morocco!**
