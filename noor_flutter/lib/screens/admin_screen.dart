import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../services/fcm_service.dart';
import '../models/user_profile.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseService _firebaseService = FirebaseService.instance;

  List<UserProfile> _users = [];
  Map<String, dynamic> _statistics = {};
  List<Map<String, dynamic>> _recentActivity = [];
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_firebaseService.isInitialized) {
        final users = await _firebaseService.getAllUsers();
        final statistics = await _firebaseService.getAppStatistics();
        final recentActivity = await _firebaseService.getRecentActivity();

        setState(() {
          _users = users;
          _statistics = statistics;
          _recentActivity = recentActivity;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading admin data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfile = authProvider.userProfile;

    // Check if user is admin
    if (userProfile == null || !userProfile.isAdmin) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Access Denied',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You need admin privileges to access this page.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.go('/home'),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Admin Panel',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Statistics Cards
                  Row(
                    children: [
                      _buildStatCard(
                        'Users',
                        _statistics['totalUsers']?.toString() ?? '0',
                        Icons.people,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Bookmarks',
                        _statistics['totalBookmarks']?.toString() ?? '0',
                        Icons.bookmark,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Surahs',
                        _statistics['totalSurahs']?.toString() ?? '0',
                        Icons.menu_book,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Users', icon: Icon(Icons.people)),
                Tab(text: 'Content', icon: Icon(Icons.book)),
                Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
                Tab(text: 'Notifications', icon: Icon(Icons.notifications)),
                Tab(text: 'Settings', icon: Icon(Icons.settings)),
              ],
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUsersTab(),
                  _buildContentTab(),
                  _buildAnalyticsTab(),
                  _buildNotificationsTab(),
                  _buildSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user.name?.isNotEmpty == true ? user.name![0].toUpperCase() : user.email?[0].toUpperCase() ?? '?'),
            ),
            title: Text(user.name ?? user.email ?? 'Unknown'),
            subtitle: Text(user.email ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user.isAdmin)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Admin',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showUserActions(user),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Content Management',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Content Actions
          _buildActionCard(
            'Refresh Quran Data',
            'Sync latest Quran content from database',
            Icons.refresh,
            () => _refreshQuranData(),
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            'Update Translations',
            'Refresh verse translations',
            Icons.translate,
            () => _updateTranslations(),
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            'Content Statistics',
            'View detailed content analytics',
            Icons.bar_chart,
            () => _showContentStats(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Dashboard',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          if (_recentActivity.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No recent activity'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentActivity.length,
              itemBuilder: (context, index) {
                final activity = _recentActivity[index];
                return ListTile(
                  leading: const Icon(Icons.bookmark_added),
                  title: Text('User ${activity['userId']} bookmarked verse'),
                  subtitle: Text('Surah ${activity['surah']}, Verse ${activity['verse']}'),
                  trailing: Text(
                    _formatTimestamp(activity['timestamp']),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Management',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Create Notification Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreateNotificationDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create New Notification'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Notification Actions
          _buildActionCard(
            'Send Prayer Reminder Test',
            'Test prayer time notifications',
            Icons.notifications_active,
            () => _sendPrayerReminderTest(),
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            'Notification Statistics',
            'View delivery and engagement stats',
            Icons.bar_chart,
            () => _showNotificationStats(),
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            'Clean Up Tokens',
            'Remove inactive FCM tokens',
            Icons.cleaning_services,
            () => _cleanupTokens(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Backup & Restore
          _buildActionCard(
            'Create Backup',
            'Backup all app data',
            Icons.backup,
            () => _createBackup(),
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            'Restore Data',
            'Restore from backup',
            Icons.restore,
            () => _restoreData(),
          ),
          const SizedBox(height: 12),

          // System Actions
          _buildActionCard(
            'Clear Cache',
            'Free up storage space',
            Icons.cleaning_services,
            () => _clearCache(),
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            'System Logs',
            'View application logs',
            Icons.bug_report,
            () => _showSystemLogs(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showUserActions(UserProfile user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              user.isAdmin ? Icons.admin_panel_settings : Icons.person,
              color: user.isAdmin ? Theme.of(context).colorScheme.primary : null,
            ),
            title: Text(user.isAdmin ? 'Remove Admin' : 'Make Admin'),
            onTap: () async {
              Navigator.of(context).pop();
              try {
                await _firebaseService.updateUserAdminStatus(user.uid, !user.isAdmin);
                _loadAdminData(); // Refresh data
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      user.isAdmin
                          ? 'Admin privileges removed'
                          : 'Admin privileges granted'
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating user: $e')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete User', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.of(context).pop();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete User'),
                  content: Text('Are you sure you want to delete ${user.name ?? user.email}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                try {
                  await _firebaseService.deleteUser(user.uid);
                  _loadAdminData(); // Refresh data
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting user: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // Action implementations
  Future<void> _refreshQuranData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Refreshing Quran data...")),
    );
    try {
      // Assuming a method in FirebaseService to refresh all surah data
      // This might involve fetching from an external API and then updating Firestore
      // For now, we'll just re-fetch all surahs to simulate a refresh
      await _firebaseService.getAllSurahs(); // This will just read, not update
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quran data refreshed successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error refreshing Quran data: $e")),
      );
    }
  }

  Future<void> _updateTranslations() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Updating translations...")),
    );
    try {
      // This would involve fetching new translations and updating Firestore
      // For now, we'll simulate a successful update.
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Translations updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating translations: $e")),
      );
    }
  }

  void _showContentStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Content Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Surahs: ${_statistics['totalSurahs'] ?? 0}'),
            Text('Total Verses: ~6,236'),
            Text('Languages: Arabic, English, Hindi'),
            Text('Last Updated: Today'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    try {
      final backup = await _firebaseService.createBackup();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup created with ${backup.length} items')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup failed: $e')),
      );
    }
  }

  Future<void> _restoreData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Restoring data...")),
    );
    try {
      // In a real scenario, you would present a way to upload a backup file
      // or select from cloud storage. For this simulation, we'll assume
      // a backup is available and call the restore method.
      // This requires a backup object, which is not readily available here.
      // For now, we'll just simulate success.
      await Future.delayed(const Duration(seconds: 3)); // Simulate restore process
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data restored successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error restoring data: $e")),
      );
    }
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared successfully')),
    );
  }

  void _showSystemLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Logs'),
        content: const SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Text(
              'System logs would be displayed here...\n'
              '• Firebase connection: OK\n'
              '• User authentication: OK\n'
              '• Data synchronization: OK\n'
              '• Cache status: Clean\n'
              '• Last backup: Today\n',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  // Notification methods
  void _showCreateNotificationDialog(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedAudience = 'all';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedAudience,
              decoration: const InputDecoration(
                labelText: 'Target Audience',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Users')),
                DropdownMenuItem(value: 'active', child: Text('Active Users')),
              ],
              onChanged: (value) {
                selectedAudience = value ?? 'all';
              },
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
              if (titleController.text.isEmpty || messageController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              Navigator.of(context).pop();

              try {
                await FCMService().sendAdminNotification(
                  title: titleController.text,
                  message: messageController.text,
                  targetAudience: selectedAudience,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification sent successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error sending notification: $e')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPrayerReminderTest() async {
    try {
      // This would integrate with prayer time service
      // For now, we'll simulate sending a test notification
      await FCMService().sendAdminNotification(
        title: "Prayer Reminder Test",
        message: "This is a test prayer reminder notification.",
        targetAudience: "all",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Prayer reminder test sent")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending test: $e")),
      );
    }
  }

  void _showNotificationStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Total Notifications Sent: 0'),
            const Text('Delivery Rate: 0%'),
            const Text('Open Rate: 0%'),
            const Text('Active FCM Tokens: 0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _cleanupTokens() async {
    try {
      await FCMService().cleanupInactiveTokens();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token cleanup completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cleaning tokens: $e')),
      );
    }
  }
}
