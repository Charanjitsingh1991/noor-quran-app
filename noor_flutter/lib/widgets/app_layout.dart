import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'bottom_navigation.dart';

class AppLayout extends StatefulWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool? _cachedIsLoading;
  String? _cachedUserId;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;
    final userId = authProvider.user?.uid;

    // Only rebuild if authentication state actually changed
    if (_cachedIsLoading != isLoading || _cachedUserId != userId) {
      _cachedIsLoading = isLoading;
      _cachedUserId = userId;
    }

    final effectiveIsLoading = _cachedIsLoading ?? true;
    final effectiveUserId = _cachedUserId;

    // Show loading screen while checking authentication
    if (effectiveIsLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    // Redirect to login if not authenticated
    if (effectiveUserId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/login');
        }
      });
      return const SizedBox.shrink();
    }

    // Show authenticated layout
    return Scaffold(
      body: Stack(
        children: [
          // Main content with padding for bottom navigation
          Padding(
            padding: const EdgeInsets.only(bottom: 80), // Space for bottom nav (80px height)
            child: widget.child,
          ),

          // Bottom navigation
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavigation(),
          ),
        ],
      ),
    );
  }
}
