import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/quran.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance {
    _instance ??= FirebaseService._internal();
    return _instance!;
  }

  FirebaseService._internal();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  bool _isInitialized = false;

  FirebaseAuth get auth {
    if (!_isInitialized || _auth == null) {
      throw Exception('Firebase not initialized');
    }
    return _auth!;
  }

  FirebaseFirestore get firestore {
    if (!_isInitialized || _firestore == null) {
      throw Exception('Firebase not initialized');
    }
    return _firestore!;
  }

  // Firebase configuration (same as original app)
  static const FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyAt01Mu5xOU4CsPpgWIRUC3XZ5ANiSikEI",
    authDomain: "noor-4asnz.firebaseapp.com",
    projectId: "noor-4asnz",
    storageBucket: "noor-4asnz.appspot.com",
    messagingSenderId: "965023247103",
    appId: "1:965023247103:web:2a15ae0cffed5fc0423aca",
  );

  // Initialize Firebase with error handling
  Future<bool> initializeFirebase() async {
    try {
      if (_isInitialized) {
        print('FirebaseService: Already initialized');
        return true;
      }

      print('FirebaseService: Starting Firebase initialization...');
      await Firebase.initializeApp(options: firebaseOptions);

      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _isInitialized = true;

      print('FirebaseService: Firebase initialized successfully');
      return true;
    } catch (e) {
      print('FirebaseService: Failed to initialize Firebase: $e');
      _isInitialized = false;
      return false;
    }
  }

  bool get isInitialized => _isInitialized;

  // Authentication methods
  Stream<User?> get authStateChanges => _auth!.authStateChanges();
  User? get currentUser => _auth!.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _auth!.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    return await _auth!.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth!.signOut();
  }

  // User Profile methods
  Future<void> createUserProfile(UserProfile profile) async {
    await _firestore!.collection('users').doc(profile.uid).set(profile.toMap());
  }

  Stream<UserProfile?> getUserProfile(String uid) {
    return _firestore!.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    await _firestore!.collection('users').doc(uid).update(updates);
  }

  Future<void> updateLastRead(String uid, int surah, int verse) async {
    await _firestore!.collection('users').doc(uid).update({
      'lastRead': {
        'surah': surah,
        'verse': verse,
      }
    });
  }

  // Quran data methods
  Future<List<Surah>> getAllSurahs() async {
    final querySnapshot = await _firestore!.collection('surahs').get();
    return querySnapshot.docs.map((doc) {
      return Surah.fromMap(doc.data());
    }).toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  Future<Surah?> getSurah(int surahNumber) async {
    try {
      // Get surah metadata
      final surahDoc = await _firestore!.collection('surahs').doc(surahNumber.toString()).get();
      if (!surahDoc.exists) return null;

      // Get verses
      final versesDoc = await _firestore!.collection('ayahs').doc(surahNumber.toString()).get();
      if (!versesDoc.exists) return null;

      final surahData = surahDoc.data()!;
      final versesData = versesDoc.data()!;

      return Surah(
        number: surahData['number'] ?? 0,
        name: surahData['name'] ?? '',
        englishName: surahData['englishName'] ?? '',
        englishNameTranslation: surahData['englishNameTranslation'] ?? '',
        revelationType: surahData['revelationType'] ?? '',
        numberOfAyahs: surahData['numberOfAyahs'] ?? 0,
        verses: (versesData['ayahs'] as List<dynamic>?)
                ?.map((verse) => Verse.fromMap(verse))
                .toList() ??
            [],
      );
    } catch (e) {
      print('Error fetching surah $surahNumber: $e');
      return null;
    }
  }

  // Bookmark methods
  Future<void> addBookmark(String userId, Bookmark bookmark) async {
    await _firestore!
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .add(bookmark.toMap());
  }

  Stream<List<Bookmark>> getBookmarks(String userId) {
    return _firestore!
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Bookmark.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> deleteBookmark(String userId, String bookmarkId) async {
    await _firestore!
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(bookmarkId)
        .delete();
  }

  // Admin methods
  Future<List<UserProfile>> getAllUsers() async {
    final querySnapshot = await _firestore!.collection('users').get();
    return querySnapshot.docs.map((doc) {
      return UserProfile.fromMap(doc.data());
    }).toList();
  }

  Future<void> updateUserAdminStatus(String userId, bool isAdmin) async {
    await _firestore!.collection('users').doc(userId).update({'isAdmin': isAdmin});
  }

  Future<void> deleteUser(String userId) async {
    await _firestore!.collection('users').doc(userId).delete();
  }

  Future<Map<String, dynamic>> getAppStatistics() async {
    final usersCount = await _firestore!.collection('users').count().get();
    final bookmarksCount = await _firestore!.collectionGroup('bookmarks').count().get();
    final surahsCount = await _firestore!.collection('surahs').count().get();

    return {
      'totalUsers': usersCount.count,
      'totalBookmarks': bookmarksCount.count,
      'totalSurahs': surahsCount.count,
      'activeUsers': usersCount.count, // Simplified for now
    };
  }

  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    final querySnapshot = await _firestore!
        .collectionGroup('bookmarks')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'type': 'bookmark',
        'userId': doc.reference.parent.parent!.id,
        'surah': data['surah'],
        'verse': data['verse'],
        'timestamp': data['createdAt'],
      };
    }).toList();
  }

  // Content management methods
  Future<void> updateSurahData(int surahNumber, Map<String, dynamic> updates) async {
    await _firestore!.collection('surahs').doc(surahNumber.toString()).update(updates);
  }

  Future<void> updateVerseData(int surahNumber, int verseNumber, Map<String, dynamic> updates) async {
    final verseRef = _firestore!
        .collection('ayahs')
        .doc(surahNumber.toString())
        .collection('verses')
        .doc(verseNumber.toString());

    await verseRef.update(updates);
  }

  // Backup and restore methods
  Future<Map<String, dynamic>> createBackup() async {
    final backup = {
      'timestamp': Timestamp.now(),
      'users': [],
      'surahs': [],
      'bookmarks': [],
    };

    // Backup users
    final usersSnapshot = await _firestore!.collection('users').get();
    backup['users'] = usersSnapshot.docs.map((doc) => doc.data()).toList();

    // Backup surahs
    final surahsSnapshot = await _firestore!.collection('surahs').get();
    backup['surahs'] = surahsSnapshot.docs.map((doc) => doc.data()).toList();

    // Backup bookmarks
    final bookmarksSnapshot = await _firestore!.collectionGroup('bookmarks').get();
    backup['bookmarks'] = bookmarksSnapshot.docs.map((doc) => {
      'userId': doc.reference.parent.parent!.id,
      'data': doc.data(),
    }).toList();

    return backup;
  }

  Future<void> restoreBackup(Map<String, dynamic> backup) async {
    // Clear existing data
    final usersSnapshot = await _firestore!.collection('users').get();
    for (final doc in usersSnapshot.docs) {
      await doc.reference.delete();
    }

    // Restore users
    for (final userData in backup['users']) {
      await _firestore!.collection('users').add(userData);
    }

    // Restore surahs
    for (final surahData in backup['surahs']) {
      await _firestore!.collection('surahs').add(surahData);
    }

    // Restore bookmarks
    for (final bookmarkData in backup['bookmarks']) {
      final userId = bookmarkData['userId'];
      final data = bookmarkData['data'];
      await _firestore!.collection('users').doc(userId).collection('bookmarks').add(data);
    }
  }

  // Verse of the day methods
  Future<Map<String, dynamic>> getVerseOfTheDay() async {
    // Get a random verse from the database
    final surahsSnapshot = await _firestore!.collection('surahs').get();
    if (surahsSnapshot.docs.isEmpty) return {};

    final randomSurah = surahsSnapshot.docs[DateTime.now().day % surahsSnapshot.docs.length];
    final surahData = randomSurah.data();

    final versesSnapshot = await _firestore!.collection('ayahs').doc(randomSurah.id).get();
    if (!versesSnapshot.exists) return {};

    final versesData = versesSnapshot.data()!;
    final verses = versesData['ayahs'] as List<dynamic>;
    if (verses.isEmpty) return {};

    final randomVerse = verses[DateTime.now().hour % verses.length];

    return {
      'surah': surahData['englishName'] ?? '',
      'verseNumber': randomVerse['numberInSurah'] ?? 1,
      'arabicText': randomVerse['arabicText'] ?? '',
      'englishText': randomVerse['englishText'] ?? '',
    };
  }
}
