import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/auth_provider.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  bool? _cachedIsAdmin;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.userProfile?.isAdmin ?? false;

    // Only rebuild if admin status actually changed
    if (_cachedIsAdmin != isAdmin) {
      _cachedIsAdmin = isAdmin;
    }

    final effectiveIsAdmin = _cachedIsAdmin ?? false;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          height: 80, // Fixed height of 4rem (64px)
          decoration: BoxDecoration(
            color: const Color(0xFF008B8B).withOpacity(0.6), // Ocean blue/teal background with 60% opacity for better transparency
            border: Border(
              top: BorderSide(
                color: const Color(0xFF008B8B).withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.home,
                  label: 'Home',
                  route: '/home',
                  selectedColor: const Color(0xFFD97706), // Orange color for selected (matches headings)
                  unselectedColor: const Color(0xFF000000), // Black color for unselected
                ),
                _buildNavItem(
                  context,
                  icon: Icons.access_time,
                  label: 'Prayer',
                  route: '/prayer-times',
                  selectedColor: const Color(0xFFD97706), // Orange color for selected (matches headings)
                  unselectedColor: const Color(0xFF000000), // Black color for unselected
                ),
                if (effectiveIsAdmin) ...[
                  _buildNavItem(
                    context,
                    icon: Icons.admin_panel_settings,
                    label: 'Admin',
                    route: '/admin',
                    selectedColor: const Color(0xFFD97706), // Orange color for selected (matches headings)
                    unselectedColor: const Color(0xFF000000), // Black color for unselected
                  ),
                ] else ...[
                  _buildNavItem(
                    context,
                    icon: Icons.bookmark,
                    label: 'Bookmarks',
                    route: '/bookmarks',
                    selectedColor: const Color(0xFFD97706), // Orange color for selected (matches headings)
                    unselectedColor: const Color(0xFF000000), // Black color for unselected
                  ),
                ],
                _buildNavItem(
                  context,
                  icon: Icons.person,
                  label: 'Profile',
                  route: '/profile',
                  selectedColor: const Color(0xFFD97706), // Orange color for selected (matches headings)
                  unselectedColor: const Color(0xFF000000), // Black color for unselected
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final isSelected = currentRoute == route;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            context.go(route);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? selectedColor : unselectedColor,
                size: 20.0,
              ),
              const SizedBox(height: 2.0),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? selectedColor : unselectedColor,
                  fontSize: 10.0,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
