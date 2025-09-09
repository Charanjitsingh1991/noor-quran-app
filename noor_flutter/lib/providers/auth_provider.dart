import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';
import '../services/fcm_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = _getDefaultTheme();
  String _fontSize = 'md';

  ThemeData get currentTheme => _currentTheme;
  String get fontSize => _fontSize;

  static ThemeData _getDefaultTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: const Color(0xFFD97706), // Accent/Highlight Color: hsl(45, 65%, 52%)
        onPrimary: const Color(0xFF1C1917), // accent foreground
        secondary: const Color(0xFFE5E7EB), // light gray
        onSecondary: const Color(0xFF0F0F0F), // Main Text Color: hsl(0, 0%, 3.9%)
        error: const Color(0xFFDC2626),
        onError: const Color(0xFFFFFFFF),
        surface: const Color(0xFFE8E3DD), // Background Color: hsl(60, 56%, 91%)
        onSurface: const Color(0xFF0F0F0F), // Main Text Color: hsl(0, 0%, 3.9%)
        surfaceContainerHighest: const Color(0xFFE8E3DD), // card background
        onSurfaceVariant: const Color(0xFF737373), // Secondary/Muted Text: hsl(0, 0%, 45.1%)
        outline: const Color(0xFFE4E4E7), // Border Color: hsl(0, 0%, 89.8%)
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5DC), // Creamish background color
    );
  }

  void setTheme(String themeId) {
    switch (themeId) {
      case 'default':
        _currentTheme = _getDefaultTheme();
        break;
      case 'dark':
        _currentTheme = _getDarkTheme();
        break;
      case 'nature':
        _currentTheme = _getNatureTheme();
        break;
      case 'ocean':
        _currentTheme = _getOceanTheme();
        break;
      case 'sunset':
        _currentTheme = _getSunsetTheme();
        break;
      case 'midnight':
        _currentTheme = _getMidnightTheme();
        break;
      default:
        _currentTheme = _getDefaultTheme();
    }
    _updateThemeWithFontSize();
  }

  void setFontSize(String fontSize) {
    _fontSize = fontSize;
    _updateThemeWithFontSize();
  }

  void _updateThemeWithFontSize() {
    double fontScale = _getFontScale(_fontSize);

    _currentTheme = _currentTheme.copyWith(
      textTheme: _currentTheme.textTheme.copyWith(
        displayLarge: _currentTheme.textTheme.displayLarge?.copyWith(fontSize: 57 * fontScale),
        displayMedium: _currentTheme.textTheme.displayMedium?.copyWith(fontSize: 45 * fontScale),
        displaySmall: _currentTheme.textTheme.displaySmall?.copyWith(fontSize: 36 * fontScale),
        headlineLarge: _currentTheme.textTheme.headlineLarge?.copyWith(fontSize: 32 * fontScale),
        headlineMedium: _currentTheme.textTheme.headlineMedium?.copyWith(fontSize: 28 * fontScale),
        headlineSmall: _currentTheme.textTheme.headlineSmall?.copyWith(fontSize: 24 * fontScale),
        titleLarge: _currentTheme.textTheme.titleLarge?.copyWith(fontSize: 22 * fontScale),
        titleMedium: _currentTheme.textTheme.titleMedium?.copyWith(fontSize: 16 * fontScale),
        titleSmall: _currentTheme.textTheme.titleSmall?.copyWith(fontSize: 14 * fontScale),
        bodyLarge: _currentTheme.textTheme.bodyLarge?.copyWith(fontSize: 16 * fontScale),
        bodyMedium: _currentTheme.textTheme.bodyMedium?.copyWith(fontSize: 14 * fontScale),
        bodySmall: _currentTheme.textTheme.bodySmall?.copyWith(fontSize: 12 * fontScale),
        labelLarge: _currentTheme.textTheme.labelLarge?.copyWith(fontSize: 14 * fontScale),
        labelMedium: _currentTheme.textTheme.labelMedium?.copyWith(fontSize: 12 * fontScale),
        labelSmall: _currentTheme.textTheme.labelSmall?.copyWith(fontSize: 11 * fontScale),
      ),
    );
    notifyListeners();
  }

  double _getFontScale(String fontSize) {
    switch (fontSize) {
      case 'sm':
        return 0.875; // 14px base instead of 16px
      case 'lg':
        return 1.125; // 18px base instead of 16px
      case 'md':
      default:
        return 1.0; // 16px base
    }
  }

  static ThemeData _getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: const Color(0xFF6366F1),
        onPrimary: const Color(0xFFFFFFFF),
        secondary: const Color(0xFF4B5563),
        onSecondary: const Color(0xFFFFFFFF),
        error: const Color(0xFFEF4444),
        onError: const Color(0xFFFFFFFF),
        surface: const Color(0xFF1F2937),
        onSurface: const Color(0xFFFFFFFF),
        surfaceContainerHighest: const Color(0xFF374151),
        onSurfaceVariant: const Color(0xFF9CA3AF),
        outline: const Color(0xFF6B7280),
      ),
      scaffoldBackgroundColor: const Color(0xFF111827),
    );
  }

  static ThemeData _getNatureTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: const Color(0xFF059669),
        onPrimary: const Color(0xFFFFFFFF),
        secondary: const Color(0xFF10B981),
        onSecondary: const Color(0xFFFFFFFF),
        error: const Color(0xFFDC2626),
        onError: const Color(0xFFFFFFFF),
        surface: const Color(0xFFF0FDF4),
        onSurface: const Color(0xFF0F0F0F),
        surfaceContainerHighest: const Color(0xFFD1FAE5),
        onSurfaceVariant: const Color(0xFF6B7280),
        outline: const Color(0xFF34D399),
      ),
      scaffoldBackgroundColor: const Color(0xFFF0FDF4),
    );
  }

  static ThemeData _getOceanTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: const Color(0xFF0891B2),
        onPrimary: const Color(0xFFFFFFFF),
        secondary: const Color(0xFF06B6D4),
        onSecondary: const Color(0xFFFFFFFF),
        error: const Color(0xFFDC2626),
        onError: const Color(0xFFFFFFFF),
        surface: const Color(0xFFECFDF5),
        onSurface: const Color(0xFF0F0F0F),
        surfaceContainerHighest: const Color(0xFFD1FAE5),
        onSurfaceVariant: const Color(0xFF6B7280),
        outline: const Color(0xFF67E8F9),
      ),
      scaffoldBackgroundColor: const Color(0xFFECFDF5),
    );
  }

  static ThemeData _getSunsetTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: const Color(0xFFDC2626),
        onPrimary: const Color(0xFFFFFFFF),
        secondary: const Color(0xFFF97316),
        onSecondary: const Color(0xFFFFFFFF),
        error: const Color(0xFFDC2626),
        onError: const Color(0xFFFFFFFF),
        surface: const Color(0xFFFFFBEB),
        onSurface: const Color(0xFF0F0F0F),
        surfaceContainerHighest: const Color(0xFFFDF4F5),
        onSurfaceVariant: const Color(0xFF6B7280),
        outline: const Color(0xFFFECACA),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFBEB),
    );
  }

  static ThemeData _getMidnightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: const Color(0xFF7C3AED),
        onPrimary: const Color(0xFFFFFFFF),
        secondary: const Color(0xFF8B5CF6),
        onSecondary: const Color(0xFFFFFFFF),
        error: const Color(0xFFEF4444),
        onError: const Color(0xFFFFFFFF),
        surface: const Color(0xFF0F0F23),
        onSurface: const Color(0xFFFFFFFF),
        surfaceContainerHighest: const Color(0xFF1E1B4B),
        onSurfaceVariant: const Color(0xFFA78BFA),
        outline: const Color(0xFF6366F1),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F23),
    );
  }
}

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;

  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _firebaseAvailable = false;

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get firebaseAvailable => _firebaseAvailable;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    print('AuthProvider: Starting initialization...');
    // Check if Firebase is available
    if (_firebaseService.isInitialized) {
      print('AuthProvider: Firebase is initialized');
      _firebaseAvailable = true;
      _initializeFirebaseAuth();
    } else {
      print('AuthProvider: Firebase not initialized, setting loading to false');
      // Firebase not available, set loading to false
      _isLoading = false;
      _firebaseAvailable = false;
      notifyListeners();
    }
  }

  void _initializeFirebaseAuth() {
    try {
      print('AuthProvider: Setting up Firebase auth state listener...');
      _firebaseService.authStateChanges.listen((User? user) async {
        print('AuthProvider: Auth state changed - User: ${user?.email ?? "null"}');

        // Only update if user actually changed
        if (_user?.uid != user?.uid) {
          _user = user;
          if (user != null) {
            print('AuthProvider: User is logged in, initializing FCM...');
            // Initialize FCM for the user
            await FCMService().initializeFCM(this);

            // Listen to user profile changes
            _firebaseService.getUserProfile(user.uid).listen((profile) {
              print('AuthProvider: User profile loaded: ${profile?.email ?? "null"}');

              // Only notify if profile actually changed
              if (_userProfile?.uid != profile?.uid ||
                  _userProfile?.isAdmin != profile?.isAdmin ||
                  _userProfile?.theme != profile?.theme) {
                _userProfile = profile;
                _isLoading = false;
                print('AuthProvider: Loading completed, notifying listeners...');
                notifyListeners();
              } else if (_isLoading) {
                _isLoading = false;
                notifyListeners();
              }
            });
          } else {
            print('AuthProvider: No user logged in, setting loading to false...');
            _userProfile = null;
            _isLoading = false;
            print('AuthProvider: Loading completed (no user), notifying listeners...');
            notifyListeners();
          }
        }
      });

      // Force check current user state
      print('AuthProvider: Checking current user...');
      final currentUser = _firebaseService.currentUser;
      print('AuthProvider: Current user: ${currentUser?.email ?? "null"}');

      // If no auth state change event fires within 2 seconds, force resolve
      Future.delayed(const Duration(seconds: 2), () {
        if (_isLoading && _user == null) {
          print('AuthProvider: Forcing auth state resolution...');
          _user = currentUser;
          _isLoading = false;
          notifyListeners();
        }
      });

    } catch (e) {
      print('AuthProvider: Error initializing Firebase auth: $e');
      _isLoading = false;
      _firebaseAvailable = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String country) async {
    try {
      final userCredential = await _firebaseService.createUserWithEmailAndPassword(email, password);
      final user = userCredential.user!;
      
      // Create user profile
      final profile = UserProfile(
        uid: user.uid,
        email: user.email,
        country: country,
        fontSize: 'md',
      );
      
      await _firebaseService.createUserProfile(profile);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_user != null) {
      try {
        await _firebaseService.updateUserProfile(_user!.uid, updates);
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<void> updateLastRead(int surah, int verse) async {
    if (_user != null) {
      try {
        await _firebaseService.updateLastRead(_user!.uid, surah, verse);
      } catch (e) {
        rethrow;
      }
    }
  }

  void refreshUserProfile() {
    if (_user != null) {
      _firebaseService.getUserProfile(_user!.uid).listen((profile) {
        // Only notify if profile actually changed
        if (_userProfile?.uid != profile?.uid ||
            _userProfile?.isAdmin != profile?.isAdmin ||
            _userProfile?.theme != profile?.theme ||
            _userProfile?.fontSize != profile?.fontSize) {
          _userProfile = profile;
          notifyListeners();
        }
      });
    }
  }

  Future<void> updateUserTheme(String theme) async {
    if (_userProfile == null || _user == null) return;

    try {
      await _firebaseService.updateUserProfile(_user!.uid, {'theme': theme});

      // Update local profile
      final updatedProfile = UserProfile(
        uid: _userProfile!.uid,
        email: _userProfile!.email,
        name: _userProfile!.name,
        dob: _userProfile!.dob,
        photoURL: _userProfile!.photoURL,
        country: _userProfile!.country,
        fontSize: _userProfile!.fontSize,
        lastRead: _userProfile!.lastRead,
        isAdmin: _userProfile!.isAdmin,
        theme: theme,
      );

      _userProfile = updatedProfile;
      notifyListeners();
    } catch (e) {
      print('Error updating user theme: $e');
      rethrow;
    }
  }
}
