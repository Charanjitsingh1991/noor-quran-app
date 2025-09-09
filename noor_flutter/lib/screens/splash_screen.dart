import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if auth provider is already initialized
    if (!authProvider.isLoading) {
      print('SplashScreen: AuthProvider already initialized, scheduling navigation...');
      _scheduleNavigation(authProvider);
      return;
    }

    // Listen to auth provider changes
    authProvider.addListener(() {
      if (mounted && !authProvider.isLoading) {
        print('SplashScreen: AuthProvider state changed, scheduling navigation...');
        _scheduleNavigation(authProvider);
      }
    });

    // Fallback timeout in case auth state doesn't change
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && authProvider.isLoading) {
        print('SplashScreen: Auth timeout - scheduling navigation');
        _scheduleNavigation(authProvider);
      }
    });
  }

  void _scheduleNavigation(AuthProvider authProvider) {
    // Schedule navigation after the current build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _navigateBasedOnAuthState(authProvider);
      }
    });
  }

  void _navigateBasedOnAuthState(AuthProvider authProvider) {
    // Prevent multiple navigations
    if (_hasNavigated) {
      return;
    }

    _hasNavigated = true;

    if (!authProvider.firebaseAvailable) {
      // Firebase not available, show demo mode
      _showFirebaseErrorDialog();
    } else if (authProvider.user != null) {
      print('SplashScreen: Navigating to home (user logged in)');
      context.go('/home');
    } else {
      print('SplashScreen: Navigating to login (no user)');
      context.go('/login');
    }
  }

  void _showFirebaseErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Connection Issue'),
        content: const Text(
          'Unable to connect to Firebase. The app will run in demo mode with limited functionality.\n\n'
          'Some features like authentication and data synchronization will not be available.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (!_hasNavigated) {
                _hasNavigated = true;
                context.go('/home');
              }
            },
            child: const Text('Continue to Demo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            Image.asset(
              'assets/icon.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              'Noor',
              style: GoogleFonts.alegreya(
                fontSize: 57,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your Quran Companion',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Initializing...',
              style: GoogleFonts.ptSans(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
