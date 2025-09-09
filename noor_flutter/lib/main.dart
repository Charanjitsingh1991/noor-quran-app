import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firebase_service.dart';
import 'services/fcm_service.dart';
import 'providers/auth_provider.dart';
// ThemeProvider is defined in auth_provider.dart
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/surah_reader_screen.dart';
import 'screens/continue_reading_screen.dart';
import 'screens/prayer_times_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/themes_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'widgets/app_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  final firebaseService = FirebaseService.instance;
  final firebaseInitialized = await firebaseService.initializeFirebase();

  runApp(NoorApp(firebaseInitialized: firebaseInitialized));
}

class NoorApp extends StatefulWidget {
  final bool firebaseInitialized;

  const NoorApp({super.key, required this.firebaseInitialized});

  @override
  State<NoorApp> createState() => _NoorAppState();
}

class _NoorAppState extends State<NoorApp> {
  late AuthProvider _authProvider;
  late ThemeProvider _themeProvider;
  String? _cachedFontSize;
  String? _cachedTheme;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _themeProvider = ThemeProvider();

    // Listen to auth provider changes to update theme
    _authProvider.addListener(_onAuthProviderChanged);
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthProviderChanged);
    super.dispose();
  }

  void _onAuthProviderChanged() {
    final userProfile = _authProvider.userProfile;

    // Only update theme if user profile actually changed
    if (userProfile != null) {
      if (_cachedFontSize != userProfile.fontSize) {
        _cachedFontSize = userProfile.fontSize;
        _themeProvider.setFontSize(userProfile.fontSize);
      }

      if (_cachedTheme != userProfile.theme && userProfile.theme.isNotEmpty) {
        _cachedTheme = userProfile.theme;
        _themeProvider.setTheme(userProfile.theme);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _themeProvider),
      ],
      child: MaterialApp.router(
        title: 'Noor: Quran Companion',
        debugShowCheckedModeBanner: false,
        theme: _themeProvider.currentTheme.copyWith(
          textTheme: GoogleFonts.ptSansTextTheme(_themeProvider.currentTheme.textTheme).copyWith(
            displayLarge: GoogleFonts.alegreya(
              fontSize: 57,
              fontWeight: FontWeight.w400,
            ),
            displayMedium: GoogleFonts.alegreya(
              fontSize: 45,
              fontWeight: FontWeight.w400,
            ),
            displaySmall: GoogleFonts.alegreya(
              fontSize: 36,
              fontWeight: FontWeight.w400,
            ),
            headlineLarge: GoogleFonts.alegreya(
              fontSize: 32,
              fontWeight: FontWeight.w400,
            ),
            headlineMedium: GoogleFonts.alegreya(
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
            headlineSmall: GoogleFonts.alegreya(
              fontSize: 24,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        routerConfig: NoorRouter.createRouter(_authProvider),
      ),
    );
  }
}

class NoorRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/otp-verification',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return OTPVerificationScreen(
              email: extra?['email'] ?? '',
              password: extra?['password'] ?? '',
              country: extra?['country'] ?? '',
              name: extra?['name'],
              dob: extra?['dob'],
              fontSize: extra?['fontSize'],
            );
          },
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => AppLayout(child: const HomeScreen()),
        ),
        GoRoute(
          path: '/surah/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return SurahReaderScreen(surahId: id);
          },
        ),
        GoRoute(
          path: '/continue-reading',
          builder: (context, state) => AppLayout(child: const ContinueReadingScreen()),
        ),
        GoRoute(
          path: '/prayer-times',
          builder: (context, state) => AppLayout(child: const PrayerTimesScreen()),
        ),
        GoRoute(
          path: '/bookmarks',
          builder: (context, state) => AppLayout(child: const BookmarksScreen()),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => AppLayout(child: const ProfileScreen()),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => AppLayout(child: const AdminScreen()),
        ),
        GoRoute(
          path: '/themes',
          builder: (context, state) => AppLayout(child: const ThemesScreen()),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = authProvider.user != null;
        final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/signup' || state.matchedLocation == '/forgot-password';
        final isSplashRoute = state.matchedLocation == '/';
        final isHomeRoute = state.matchedLocation == '/home';

        // Don't redirect while loading
        if (authProvider.isLoading) {
          return null;
        }

        // If user is not logged in and trying to access protected routes, redirect to login
        if (!isLoggedIn && !isAuthRoute && !isSplashRoute) {
          return '/login';
        }

        // If user is logged in and on auth routes, redirect to home
        if (isLoggedIn && isAuthRoute) {
          return '/home';
        }

        // If user is logged in and on splash screen, redirect to home
        if (isLoggedIn && isSplashRoute) {
          return '/home';
        }

        // If user is not logged in and on home, redirect to login
        if (!isLoggedIn && isHomeRoute) {
          return '/login';
        }

        return null;
      },
    );
  }
}
