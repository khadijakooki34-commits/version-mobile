import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/index.dart';
import 'providers/index.dart';
import 'services/avis_service.dart';
import 'screens/auth_screens/splash_screen.dart';
import 'screens/auth_screens/login_screen.dart';
import 'screens/auth_screens/register_screen.dart';
import 'screens/auth_screens/forgot_password_screen.dart';
import 'screens/auth_screens/oauth_callback_screen.dart';
import 'screens/user_screens/home_screen.dart';
import 'screens/user_screens/destination_details_screen.dart';
import 'screens/user_screens/search_destinations_screen.dart';
import 'screens/user_screens/write_review_screen.dart';
import 'screens/user_screens/recommendations_screen.dart';
import 'screens/user_screens/events_screen.dart';
import 'screens/user_screens/weather_screen.dart';
import 'screens/user_screens/profile_screen.dart';
import 'screens/user_screens/edit_profile_screen.dart';
import 'screens/admin_screens/admin_dashboard_screen.dart';
import 'screens/admin_screens/admin_users_screen.dart';
import 'screens/admin_screens/admin_destinations_screen.dart';
import 'screens/admin_screens/admin_events_screen.dart';
import 'screens/admin_screens/admin_statistics_screen.dart';
import 'screens/user_screens/my_reservations_screen.dart';
import 'screens/user_screens/my_itineraries_screen.dart';
import 'screens/user_screens/create_itinerary_screen.dart';
import 'screens/user_screens/itinerary_detail_screen.dart';
import 'screens/user_screens/event_detail_screen.dart';
import 'widgets/index.dart';
import 'utils/index.dart';

late ApiService _apiService;
late AuthService _authService;
late DestinationService _destinationService;
late ReviewService _reviewService;
late AvisService _avisService;
late EventService _eventService;
late ReservationService _reservationService;
late RecommendationService _recommendationService;
late WeatherService _weatherService;
late UserService _userService;
late AdminService _adminService;
late FavoriteService _favoriteService;
late ItineraryService _itineraryService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ApiService
  _apiService = ApiService();
  await _apiService.initialize();

  // Initialize all services
  _authService = AuthService(apiService: _apiService);
  _destinationService = DestinationService(apiService: _apiService);
  _reviewService = ReviewService(apiService: _apiService);
  _avisService = AvisService(apiService: _apiService);
  _eventService = EventService(apiService: _apiService);
  _reservationService = ReservationService(apiService: _apiService);
  _recommendationService = RecommendationService(apiService: _apiService);
  _weatherService = WeatherService(apiService: _apiService);
  _userService = UserService(apiService: _apiService);
  _adminService = AdminService(apiService: _apiService);
  _favoriteService = FavoriteService(apiService: _apiService);
  _itineraryService = ItineraryService(apiService: _apiService);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider - Must be available for all screens
        ChangeNotifierProvider(
            create: (_) => AuthProvider(authService: _authService)),

        // Destination Provider
        ChangeNotifierProvider(create: (_) =>
            DestinationProvider(destinationService: _destinationService)),

        // Review Provider
        ChangeNotifierProvider(
            create: (_) => ReviewProvider(reviewService: _reviewService)),

        // Avis Provider
        ChangeNotifierProvider(
            create: (_) => AvisProvider(avisService: _avisService)),

        // Event Provider
        ChangeNotifierProvider(
            create: (_) => EventProvider(eventService: _eventService)),

        // Reservation Provider
        ChangeNotifierProvider(create: (_) =>
            ReservationProvider(reservationService: _reservationService)),

        // Admin Event Provider
        ChangeNotifierProvider(
          create: (_) =>
              AdminEventProvider(
                eventService: _eventService,
                apiService: _apiService,
              ),
        ),

        // Recommendation Provider
        ChangeNotifierProvider(create: (_) =>
            RecommendationProvider(
            recommendationService: _recommendationService)),

        // Weather Provider
        ChangeNotifierProvider(
            create: (_) => WeatherProvider(weatherService: _weatherService)),

        // User Provider
        ChangeNotifierProvider(
            create: (_) => UserProvider(userService: _userService)),

        // Admin Provider
        ChangeNotifierProvider(
            create: (_) => AdminProvider(adminService: _adminService)),

        // Favorite Provider
        ChangeNotifierProvider(
            create: (_) => FavoriteProvider(favoriteService: _favoriteService)),

        // Itinerary Provider
        ChangeNotifierProvider(create: (_) =>
            ItineraryProvider(itineraryService: _itineraryService)),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        // Add navigator key for global navigation
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr'),
        ],
        home: const SplashScreen(),
        routes: _buildRoutes(),
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) =>
                Scaffold(
                  appBar: AppBar(title: const Text('Page Non Trouvée')),
                  body: const Center(child: Text('404 - Page non trouvée')),
                ),
          );
        },
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/splash': (context) => const SplashScreen(),
      '/login': (context) => const LoginScreen(),
      '/register': (context) => const RegisterScreen(),
      '/forgot-password': (context) => const ForgotPasswordScreen(),
      '/oauth-callback': (context) => const OAuthCallbackScreen(),
      '/home': (context) => const AuthGuard(child: HomeScreen()),
      '/destination-details': (context) {
        final args = ModalRoute
            .of(context)
            ?.settings
            .arguments;
        int destinationId = 0;

        // Handle both int and Map arguments
        if (args is int) {
          destinationId = args;
        } else if (args is Map<String, dynamic>) {
          destinationId = (args['destinationId'] as int?) ?? 0;
        }

        return AuthGuard(
          child: DestinationDetailsScreen(destinationId: destinationId),
        );
      },
      '/search-destinations': (context) => const AuthGuard(
            child: SearchDestinationsScreen(),
          ),
      '/write-review': (context) {
        final args = ModalRoute
            .of(context)
            ?.settings
            .arguments;
        int destinationId = 0;

        // Handle both int and Map arguments
        if (args is int) {
          destinationId = args;
        } else if (args is Map<String, dynamic>) {
          destinationId = (args['destinationId'] as int?) ?? 0;
        }

        return AuthGuard(
          child: WriteReviewScreen(destinationId: destinationId),
        );
      },
      '/recommendations': (context) => const AuthGuard(
            child: RecommendationsScreen(),
          ),
      '/events': (context) => const AuthGuard(child: EventsScreen()),
      '/event-detail': (context) {
        final args = ModalRoute
            .of(context)
            ?.settings
            .arguments;
        final eventId = args is int ? args : (args is Map
            ? (args['eventId'] as int?) ?? 0
            : 0);
        return AuthGuard(child: EventDetailScreen(eventId: eventId));
      },
      '/my-reservations': (context) => const AuthGuard(child: MyReservationsScreen()),
      '/my-itineraries': (context) => const AuthGuard(child: MyItinerariesScreen()),
      '/create-itinerary': (context) {
        final args = ModalRoute
            .of(context)
            ?.settings
            .arguments;
        int userId = 0;
        List<int>? initialIds;
        if (args is int) {
          userId = args;
        } else if (args is Map<String, dynamic>) {
          userId = (args['userId'] as int?) ?? 0;
          final dId = args['destinationId'];
          if (dId != null)
            initialIds = [dId is int ? dId : (dId as num).toInt()];
        }
        return AuthGuard(child: CreateItineraryScreen(userId: userId, initialDestinationIds: initialIds));
      },
      '/itinerary-detail': (context) {
        final args = ModalRoute
            .of(context)
            ?.settings
            .arguments;
        final id = args is int ? args : 0;
        return AuthGuard(child: ItineraryDetailScreen(itineraryId: id));
      },
      '/weather': (context) => const AuthGuard(child: WeatherScreen()),
      '/profile': (context) => const AuthGuard(child: ProfileScreen()),
      '/edit-profile': (context) => const AuthGuard(
            child: EditProfileScreen(),
          ),
      '/admin-dashboard': (context) => const AdminGuard(
            child: AdminDashboardScreen(),
          ),
      '/admin-users': (context) => const AdminGuard(
            child: AdminUsersScreen(),
          ),
      '/admin-destinations': (context) => const AdminGuard(
            child: AdminDestinationsScreen(),
          ),
      '/admin-events': (context) => const AdminGuard(
            child: AdminEventsScreen(),
          ),
      '/admin-statistics': (context) => const AdminGuard(
            child: AdminStatisticsScreen(),
          ),
    };
  }
}

