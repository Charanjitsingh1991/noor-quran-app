import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quran.dart';
import '../services/firebase_service.dart';
import '../providers/auth_provider.dart';

class SurahReaderScreen extends StatefulWidget {
  final int surahId;

  const SurahReaderScreen({super.key, required this.surahId});

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  final FirebaseService _firebaseService = FirebaseService.instance;
  Surah? _surah;
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedLanguage = 'english';
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};

  @override
  void initState() {
    super.initState();
    _loadSurah();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSurah() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_firebaseService.isInitialized) {
        final surah = await _firebaseService.getSurah(widget.surahId);
        if (surah != null) {
          setState(() {
            _surah = surah;
            _isLoading = false;
          });
          // Initialize keys for verses
          for (int i = 0; i < surah.verses.length; i++) {
            _verseKeys[surah.verses[i].numberInSurah] = GlobalKey();
          }
        } else {
          _loadDemoData();
        }
      } else {
        _loadDemoData();
      }
    } catch (e) {
      print('Error loading surah: $e');
      _loadDemoData();
    }
  }

  void _loadDemoData() {
    // Demo Surah data
    final demoVerses = [
      Verse(
        number: 1,
        numberInSurah: 1,
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        englishText: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        hindiText: 'अल्लाह के नाम से, जो अत्यंत दयालु और विशेष दयालु है।',
      ),
      Verse(
        number: 2,
        numberInSurah: 2,
        arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        englishText: 'All praise is due to Allah, Lord of the worlds.',
        hindiText: 'सारी प्रशंसा अल्लाह के लिए है, जो समस्त विश्व का पालनकर्ता है।',
      ),
      Verse(
        number: 3,
        numberInSurah: 3,
        arabicText: 'الرَّحْمَٰنِ الرَّحِيمِ',
        englishText: 'The Entirely Merciful, the Especially Merciful.',
        hindiText: 'अत्यंत दयालु, विशेष दयालु।',
      ),
    ];

    setState(() {
      _surah = Surah(
        number: widget.surahId,
        name: 'الفاتحة',
        englishName: 'Al-Fatiha',
        englishNameTranslation: 'The Opening',
        revelationType: 'Meccan',
        numberOfAyahs: demoVerses.length,
        verses: demoVerses,
      );
      _isLoading = false;
    });

    // Initialize keys for demo verses
    for (int i = 0; i < demoVerses.length; i++) {
      _verseKeys[demoVerses[i].numberInSurah] = GlobalKey();
    }
  }

  void _updateLastRead(int verseNumber) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.updateLastRead(widget.surahId, verseNumber);
  }

  void _showBookmarkDialog(Verse verse) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Bookmark - ${verse.numberInSurah}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              verse.arabicText,
              style: GoogleFonts.alegreya(
                fontSize: 20,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Add a note (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final bookmark = Bookmark(
                  id: '',
                  surah: widget.surahId,
                  verse: verse.numberInSurah,
                  note: noteController.text,
                  createdAt: Timestamp.now(),
                  surahName: _surah?.englishName ?? '',
                  verseText: verse.arabicText,
                );

                if (_firebaseService.isInitialized) {
                  await _firebaseService.addBookmark(
                    Provider.of<AuthProvider>(context, listen: false).user!.uid,
                    bookmark,
                  );
                }

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bookmark saved!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error saving bookmark: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Surah ${widget.surahId}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null || _surah == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Surah ${widget.surahId}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: Center(
          child: Text(_errorMessage ?? 'Failed to load surah'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_surah!.englishName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          // Language Toggle
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedLanguage = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'english',
                child: Text('English'),
              ),
              const PopupMenuItem(
                value: 'hindi',
                child: Text('Hindi'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    _selectedLanguage == 'english' ? Icons.language : Icons.translate,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _selectedLanguage == 'english' ? 'EN' : 'HI',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Surah Header
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _surah!.name,
                  style: GoogleFonts.alegreya(
                    fontSize: 45,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                Text(
                  _surah!.englishName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _surah!.englishNameTranslation,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_surah!.revelationType} • ${_surah!.numberOfAyahs} Verses',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Verses List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _surah!.verses.length,
              itemBuilder: (context, index) {
                final verse = _surah!.verses[index];
                return Container(
                  key: _verseKeys[verse.numberInSurah],
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Verse Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${widget.surahId}:${verse.numberInSurah}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.bookmark_border,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () => _showBookmarkDialog(verse),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Arabic Text
                      Text(
                        verse.arabicText,
                        style: GoogleFonts.alegreya(
                          fontSize: 24,
                          height: 2,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),

                      const SizedBox(height: 16),

                      // Translation
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedLanguage == 'english'
                              ? '"${verse.englishText}"'
                              : '"${verse.hindiText}"',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
