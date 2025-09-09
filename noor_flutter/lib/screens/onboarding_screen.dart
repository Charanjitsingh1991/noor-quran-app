import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: 'Welcome to Noor',
      subtitle: 'Your personal Quran companion',
      description: 'Discover the beauty of the Quran with our modern, user-friendly interface designed to enhance your spiritual journey.',
      icon: Icons.wb_sunny,
      color: const Color(0xFFD97706),
    ),
    OnboardingItem(
      title: 'Biometric Security',
      subtitle: 'Secure & Quick Access',
      description: 'Enable biometric authentication (fingerprint/face) for quick and secure access to your account. Your data stays protected.',
      icon: Icons.fingerprint,
      color: const Color(0xFF059669),
    ),
    OnboardingItem(
      title: 'Beautiful Reading',
      subtitle: 'Immerse Yourself',
      description: 'Read the Quran with beautiful Arabic text, multiple translations, and adjustable font sizes for comfortable reading.',
      icon: Icons.menu_book,
      color: const Color(0xFF7C3AED),
    ),
    OnboardingItem(
      title: 'Language Support',
      subtitle: 'Read in Your Language',
      description: 'Switch between different languages for translations. Choose from English, Hindi, and many more languages.',
      icon: Icons.language,
      color: const Color(0xFFDC2626),
    ),
    OnboardingItem(
      title: 'Personal Bookmarks',
      subtitle: 'Save & Organize',
      description: 'Bookmark your favorite verses, add personal notes, and organize your reading progress for easy reference.',
      icon: Icons.bookmark,
      color: const Color(0xFF0891B2),
    ),
    OnboardingItem(
      title: 'Prayer Times',
      subtitle: 'Stay Connected',
      description: 'Get accurate prayer times based on your location and receive notifications to never miss a prayer.',
      icon: Icons.access_time,
      color: const Color(0xFFF97316),
    ),
    OnboardingItem(
      title: 'Continue Reading',
      subtitle: 'Pick Up Where You Left',
      description: 'The app remembers your last reading position so you can seamlessly continue your spiritual journey.',
      icon: Icons.play_circle_fill,
      color: const Color(0xFF6366F1),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() async {
    // Mark onboarding as completed in user profile
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.updateProfile({'onboardingCompleted': true});

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Skip'),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  return _buildPage(_onboardingItems[index]);
                },
              ),
            ),

            // Bottom indicators and buttons
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 60,
              color: item.color,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            item.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            item.subtitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: item.color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingItems.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Navigation buttons
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousPage,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Previous'),
                  ),
                ),

              if (_currentPage > 0) const SizedBox(width: 16),

              Expanded(
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _currentPage == _onboardingItems.length - 1
                        ? 'Get Started'
                        : 'Next',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}
