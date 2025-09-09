import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? email;
  final String? name;
  final String? dob;
  final String? photoURL;
  final String country;
  final String fontSize;
  final LastRead? lastRead;
  final bool isAdmin;
  final String theme;
  final bool biometricEnabled;
  final String? pinCode;

  UserProfile({
    required this.uid,
    this.email,
    this.name,
    this.dob,
    this.photoURL,
    required this.country,
    required this.fontSize,
    this.lastRead,
    this.isAdmin = false,
    this.theme = 'default',
    this.biometricEnabled = false,
    this.pinCode,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Check for both 'isAdmin' field and 'role' field for backward compatibility
    bool isAdmin = map['isAdmin'] ?? false;
    if (!isAdmin && map['role'] != null) {
      // If role field exists and isAdmin is false, check if role is 'admin'
      isAdmin = map['role'].toString().toLowerCase() == 'admin';
    }

    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'],
      name: map['name'],
      dob: map['dob'],
      photoURL: map['photoURL'],
      country: map['country'] ?? 'Unknown',
      fontSize: map['fontSize'] ?? 'md',
      lastRead: map['lastRead'] != null
          ? LastRead.fromMap(map['lastRead'])
          : null,
      isAdmin: isAdmin,
      theme: map['theme'] ?? 'default',
      biometricEnabled: map['biometricEnabled'] ?? false,
      pinCode: map['pinCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'dob': dob,
      'photoURL': photoURL,
      'country': country,
      'fontSize': fontSize,
      'lastRead': lastRead?.toMap(),
      'isAdmin': isAdmin,
      'theme': theme,
      'biometricEnabled': biometricEnabled,
      'pinCode': pinCode,
    };
  }
}

class LastRead {
  final int surah;
  final int verse;

  LastRead({
    required this.surah,
    required this.verse,
  });

  factory LastRead.fromMap(Map<String, dynamic> map) {
    return LastRead(
      surah: map['surah'] ?? 1,
      verse: map['verse'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surah': surah,
      'verse': verse,
    };
  }
}
