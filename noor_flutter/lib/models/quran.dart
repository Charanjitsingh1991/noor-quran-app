import 'package:cloud_firestore/cloud_firestore.dart';

class Verse {
  final int number;
  final int numberInSurah;
  final String arabicText;
  final String englishText;
  final String hindiText;

  Verse({
    required this.number,
    required this.numberInSurah,
    required this.arabicText,
    required this.englishText,
    required this.hindiText,
  });

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      number: map['number'] ?? 0,
      numberInSurah: map['numberInSurah'] ?? 0,
      arabicText: map['arabicText'] ?? '',
      englishText: map['englishText'] ?? '',
      hindiText: map['hindiText'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'numberInSurah': numberInSurah,
      'arabicText': arabicText,
      'englishText': englishText,
      'hindiText': hindiText,
    };
  }
}

class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;
  final List<Verse> verses;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.verses,
  });

  factory Surah.fromMap(Map<String, dynamic> map) {
    return Surah(
      number: map['number'] ?? 0,
      name: map['name'] ?? '',
      englishName: map['englishName'] ?? '',
      englishNameTranslation: map['englishNameTranslation'] ?? '',
      revelationType: map['revelationType'] ?? '',
      numberOfAyahs: map['numberOfAyahs'] ?? 0,
      verses: (map['verses'] as List<dynamic>?)
              ?.map((verse) => Verse.fromMap(verse))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'name': name,
      'englishName': englishName,
      'englishNameTranslation': englishNameTranslation,
      'revelationType': revelationType,
      'numberOfAyahs': numberOfAyahs,
      'verses': verses.map((verse) => verse.toMap()).toList(),
    };
  }
}

class Bookmark {
  final String id;
  final int surah;
  final int verse;
  final String note;
  final Timestamp createdAt;
  final String surahName;
  final String verseText;

  Bookmark({
    required this.id,
    required this.surah,
    required this.verse,
    required this.note,
    required this.createdAt,
    required this.surahName,
    required this.verseText,
  });

  factory Bookmark.fromMap(Map<String, dynamic> map, String id) {
    return Bookmark(
      id: id,
      surah: map['surah'] ?? 0,
      verse: map['verse'] ?? 0,
      note: map['note'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      surahName: map['surahName'] ?? '',
      verseText: map['verseText'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surah': surah,
      'verse': verse,
      'note': note,
      'createdAt': createdAt,
      'surahName': surahName,
      'verseText': verseText,
    };
  }
}
