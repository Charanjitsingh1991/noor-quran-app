import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/quran.dart';
import '../services/firebase_service.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService.instance;
  List<Surah> _surahs = [];
  bool _isLoading = true;
  bool _isLoadingSurahs = false;
  String? _errorMessage;
  Map<String, dynamic> _verseOfTheDay = {};

  @override
  void initState() {
    super.initState();
    _loadSurahs();
    _loadVerseOfTheDay();
  }

  Future<void> _loadSurahs() async {
    if (!mounted || _isLoadingSurahs) return;

    _isLoadingSurahs = true;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_firebaseService.isInitialized) {
        final surahs = await _firebaseService.getAllSurahs();
        if (mounted) {
          setState(() {
            _surahs = surahs;
            _isLoading = false;
            _isLoadingSurahs = false;
          });
        }
      } else {
        // Firebase not available, show demo data
        _loadDemoData();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load Surahs. Please check your connection.';
          _isLoading = false;
          _isLoadingSurahs = false;
        });
      }
      print('Error loading surahs: $e');
      // Fallback to demo data
      _loadDemoData();
    }
  }

  void _loadDemoData() {
    if (!mounted) return;

    // Demo Surah data for when Firebase is not available
    final demoSurahs = [
      Surah(
        number: 1,
        name: 'الفاتحة',
        englishName: 'Al-Fatiha',
        englishNameTranslation: 'The Opening',
        revelationType: 'Meccan',
        numberOfAyahs: 7,
        verses: [],
      ),
      Surah(
        number: 2,
        name: 'البقرة',
        englishName: 'Al-Baqarah',
        englishNameTranslation: 'The Cow',
        revelationType: 'Medinan',
        numberOfAyahs: 286,
        verses: [],
      ),
      Surah(
        number: 3,
        name: 'آل عمران',
        englishName: 'Aal-E-Imran',
        englishNameTranslation: 'The Family of Imran',
        revelationType: 'Medinan',
        numberOfAyahs: 200,
        verses: [],
      ),
    ];

    setState(() {
      _surahs = demoSurahs;
      _isLoading = false;
      _isLoadingSurahs = false;
    });
  }

  Future<void> _loadVerseOfTheDay() async {
    try {
      if (_firebaseService.isInitialized) {
        final verseData = await _firebaseService.getVerseOfTheDay();
        if (mounted && verseData.isNotEmpty) {
          setState(() {
            _verseOfTheDay = verseData;
          });
        }
      }
    } catch (e) {
      print('Error loading verse of the day: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfile = authProvider.userProfile;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading Surahs...',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could Not Load Surahs',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadSurahs,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(
                      'Al-Quran',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: const Color(0xFFD97706), // Accent/Highlight Color
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your companion for spiritual growth',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF737373), // Secondary/Muted Text
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Verse of the Day
              _buildVerseOfTheDay(),

              const SizedBox(height: 24),

              // Continue Reading Section
              if (userProfile?.lastRead != null)
                _buildContinueReading(userProfile!.lastRead!),

              const SizedBox(height: 24),

              // Surah List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Surahs',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    '${_surahs.length} Surahs',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Surah List
              if (_surahs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Surahs available',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _surahs.length,
                  itemBuilder: (context, index) {
                    final surah = _surahs[index];
                    final isCurrentlyReading = userProfile?.lastRead?.surah == surah.number;
                    return _buildSurahCard(surah, isCurrentlyReading);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseOfTheDay() {
    // Use dynamic data if available, otherwise fallback to demo
    final arabicText = _verseOfTheDay['arabicText'] ?? 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
    final englishText = _verseOfTheDay['englishText'] ?? '"In the name of Allah, the Entirely Merciful, the Especially Merciful."';
    final surahName = _verseOfTheDay['surah'] ?? 'Al-Fatiha';
    final verseNumber = _verseOfTheDay['verseNumber'] ?? 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Verse of the Day',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arabicText,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 2,
                    fontFamily: 'Alegreya',
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 12),
                Text(
                  '"$englishText"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$surahName ($verseNumber)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueReading(dynamic lastRead) {
    final surahName = _getSurahName(lastRead.surah);
    final progress = _calculateReadingProgress(lastRead.surah, lastRead.verse);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_circle_fill,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Continue Reading',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => context.go('/surah/${lastRead.surah}'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Continue on ${surahName ?? 'Surah ${lastRead.surah}'}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Verse ${lastRead.verse}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Progress Bar
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).round()}% completed',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _getSurahName(int surahNumber) {
    final surah = _surahs.firstWhere(
      (s) => s.number == surahNumber,
      orElse: () => Surah(
        number: surahNumber,
        name: '',
        englishName: '',
        englishNameTranslation: '',
        revelationType: '',
        numberOfAyahs: 0,
        verses: [],
      ),
    );
    return surah.englishName.isNotEmpty ? surah.englishName : null;
  }

  double _calculateReadingProgress(int surahNumber, int currentVerse) {
    final surah = _surahs.firstWhere(
      (s) => s.number == surahNumber,
      orElse: () => Surah(
        number: surahNumber,
        name: '',
        englishName: '',
        englishNameTranslation: '',
        revelationType: '',
        numberOfAyahs: 0,
        verses: [],
      ),
    );

    if (surah.numberOfAyahs == 0) return 0.0;

    return currentVerse / surah.numberOfAyahs;
  }

  Widget _buildSurahCard(Surah surah, bool isCurrentlyReading) {
    return Card(
      elevation: isCurrentlyReading ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          context.go('/surah/${surah.number}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isCurrentlyReading
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Surah Number with Reading Indicator
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCurrentlyReading
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        surah.number.toString(),
                        style: TextStyle(
                          color: isCurrentlyReading
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  if (isCurrentlyReading)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Surah Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            surah.englishName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isCurrentlyReading
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentlyReading)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Reading',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      surah.englishNameTranslation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arabic Name and Verse Count
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      surah.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${surah.numberOfAyahs} Verses',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
