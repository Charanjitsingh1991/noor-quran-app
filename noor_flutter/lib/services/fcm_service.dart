import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _fcmToken;
  AuthProvider? _authProvider;

  // Initialize FCM
  Future<void> initializeFCM(AuthProvider authProvider) async {
    print('FCMService: Starting FCM initialization...');
    _authProvider = authProvider;

    // Request permissions
    await _requestPermissions();

    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');

    // Store token if user is logged in
    if (_authProvider?.user != null && _fcmToken != null) {
      await _storeFCMToken(_fcmToken!);
    }

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      if (_authProvider?.user != null) {
        _storeFCMToken(newToken);
      }
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle messages when app is opened from terminated state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    print('FCMService: FCM initialization completed successfully');
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _storeFCMToken(String token) async {
    if (_authProvider?.user == null) return;

    try {
      final userId = _authProvider!.user!.uid;
      final deviceId = await _getDeviceId();

      await _firestore.collection('users').doc(userId).collection('fcmTokens').doc(deviceId).set({
        'token': token,
        'deviceId': deviceId,
        'platform': _getPlatform(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      print('FCM token stored successfully');
    } catch (e) {
      print('Error storing FCM token: $e');
    }
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');

    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('device_id', deviceId);
    }

    return deviceId;
  }

  String _getPlatform() {
    // This is a simplified platform detection
    // In a real app, you'd use platform-specific code
    return 'android'; // Default to android for now
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.notification?.title}');
    print('Message body: ${message.notification?.body}');
    print('Message data: ${message.data}');

    // For now, just log the message
    // In a real app, you might show a local notification or in-app banner
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Received background message: ${message.notification?.title}');
    // Handle background message processing
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.notification?.title}');

    // Navigate based on message data
    final data = message.data;
    if (data.containsKey('screen')) {
      // Navigate to specific screen
      _navigateToScreen(data['screen'], data);
    }
  }

  void _navigateToScreen(String screen, Map<String, dynamic> data) {
    // This would integrate with your navigation system
    print('Navigate to screen: $screen with data: $data');
  }

  // Subscribe to topics for admin broadcasts
  Future<void> subscribeToAdminBroadcasts() async {
    await _firebaseMessaging.subscribeToTopic('admin_broadcasts');
    print('Subscribed to admin broadcasts');
  }

  Future<void> unsubscribeFromAdminBroadcasts() async {
    await _firebaseMessaging.unsubscribeFromTopic('admin_broadcasts');
    print('Unsubscribed from admin broadcasts');
  }

  // Send admin notification (would be called from admin panel)
  Future<void> sendAdminNotification({
    required String title,
    required String message,
    String? imageUrl,
    String targetAudience = 'all',
  }) async {
    if (_authProvider?.userProfile?.isAdmin != true) {
      throw Exception('Only admins can send notifications');
    }

    try {
      // Store notification in Firestore
      final notificationRef = await _firestore.collection('notifications').add({
        'title': title,
        'message': message,
        'imageUrl': imageUrl,
        'type': 'broadcast',
        'targetAudience': targetAudience,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _authProvider!.user!.uid,
        'status': 'sending',
      });

      // Here you would typically call a Cloud Function to send the notification
      // For now, we'll simulate sending to all users
      await _sendToAllUsers(title, message, imageUrl);

      // Update status
      await notificationRef.update({'status': 'sent'});

    } catch (e) {
      print('Error sending admin notification: $e');
      rethrow;
    }
  }

  Future<void> _sendToAllUsers(String title, String message, String? imageUrl) async {
    // This would be replaced with a Cloud Function call
    // For demonstration, we'll get all user tokens and send notifications
    try {
      final usersSnapshot = await _firestore.collection('users').get();

      for (final userDoc in usersSnapshot.docs) {
        final tokensSnapshot = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('fcmTokens')
            .where('isActive', isEqualTo: true)
            .get();

        for (final tokenDoc in tokensSnapshot.docs) {
          final token = tokenDoc.data()['token'] as String?;
          if (token != null) {
            // Send notification to this token
            await _sendNotificationToToken(token, title, message, imageUrl);
          }
        }
      }
    } catch (e) {
      print('Error sending to all users: $e');
    }
  }

  Future<void> _sendNotificationToToken(String token, String title, String message, String? imageUrl) async {
    // This would be implemented using FCM HTTP API or Cloud Functions
    // For now, it's a placeholder
    print('Sending notification to token: $token');
  }

  // Prayer time notifications
  Future<void> schedulePrayerNotifications() async {
    // This would integrate with your prayer time calculation service
    // For now, it's a placeholder
    print('Scheduling prayer notifications');
  }

  // Clean up inactive tokens
  Future<void> cleanupInactiveTokens() async {
    try {
      final batch = _firestore.batch();
      final usersSnapshot = await _firestore.collection('users').get();

      for (final userDoc in usersSnapshot.docs) {
        final tokensSnapshot = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('fcmTokens')
            .where('isActive', isEqualTo: true)
            .get();

        for (final tokenDoc in tokensSnapshot.docs) {
          final lastUpdated = tokenDoc.data()['lastUpdated'] as Timestamp?;
          if (lastUpdated != null) {
            final daysSinceUpdate = DateTime.now().difference(lastUpdated.toDate()).inDays;
            if (daysSinceUpdate > 30) {
              // Mark as inactive
              batch.update(tokenDoc.reference, {'isActive': false});
            }
          }
        }
      }

      await batch.commit();
      print('Cleaned up inactive tokens');
    } catch (e) {
      print('Error cleaning up tokens: $e');
    }
  }
}
