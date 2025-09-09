import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String? imageUrl;
  final String type; // 'broadcast' or 'prayer_reminder'
  final String targetAudience; // 'all', 'active_users', 'premium_users'
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final String createdBy;
  final String status; // 'scheduled', 'sent', 'delivered', 'failed'
  final Map<String, int>? deliveryStats;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.type,
    required this.targetAudience,
    this.scheduledAt,
    required this.createdAt,
    required this.createdBy,
    required this.status,
    this.deliveryStats,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      imageUrl: map['imageUrl'],
      type: map['type'] ?? 'broadcast',
      targetAudience: map['targetAudience'] ?? 'all',
      scheduledAt: map['scheduledAt'] != null
          ? (map['scheduledAt'] as Timestamp).toDate()
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
      status: map['status'] ?? 'scheduled',
      deliveryStats: map['deliveryStats'] != null
          ? Map<String, int>.from(map['deliveryStats'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'type': type,
      'targetAudience': targetAudience,
      'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'status': status,
      'deliveryStats': deliveryStats,
    };
  }
}

class NotificationPreferences {
  final bool enabled;
  final Map<String, PrayerNotificationSettings> prayerReminders;
  final Map<String, bool> adminBroadcasts;

  NotificationPreferences({
    required this.enabled,
    required this.prayerReminders,
    required this.adminBroadcasts,
  });

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    final prayerReminders = <String, PrayerNotificationSettings>{};
    if (map['prayerReminders'] != null) {
      (map['prayerReminders'] as Map<String, dynamic>).forEach((key, value) {
        prayerReminders[key] = PrayerNotificationSettings.fromMap(value);
      });
    }

    final adminBroadcasts = <String, bool>{};
    if (map['adminBroadcasts'] != null) {
      (map['adminBroadcasts'] as Map<String, dynamic>).forEach((key, value) {
        adminBroadcasts[key] = value as bool;
      });
    }

    return NotificationPreferences(
      enabled: map['enabled'] ?? true,
      prayerReminders: prayerReminders,
      adminBroadcasts: adminBroadcasts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'prayerReminders': prayerReminders.map((key, value) => MapEntry(key, value.toMap())),
      'adminBroadcasts': adminBroadcasts,
    };
  }
}

class PrayerNotificationSettings {
  final bool enabled;
  final List<int> minutesBefore; // e.g., [5, 2] for 5 and 2 minutes before

  PrayerNotificationSettings({
    required this.enabled,
    required this.minutesBefore,
  });

  factory PrayerNotificationSettings.fromMap(Map<String, dynamic> map) {
    return PrayerNotificationSettings(
      enabled: map['enabled'] ?? true,
      minutesBefore: List<int>.from(map['minutesBefore'] ?? [5, 2]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'minutesBefore': minutesBefore,
    };
  }
}

class FCMToken {
  final String token;
  final String deviceId;
  final String platform;
  final DateTime lastUpdated;
  final bool isActive;

  FCMToken({
    required this.token,
    required this.deviceId,
    required this.platform,
    required this.lastUpdated,
    required this.isActive,
  });

  factory FCMToken.fromMap(Map<String, dynamic> map) {
    return FCMToken(
      token: map['token'] ?? '',
      deviceId: map['deviceId'] ?? '',
      platform: map['platform'] ?? 'android',
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'deviceId': deviceId,
      'platform': platform,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isActive': isActive,
    };
  }
}
