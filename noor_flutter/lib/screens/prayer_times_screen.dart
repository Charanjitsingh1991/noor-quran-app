import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../providers/auth_provider.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Map<String, String> _prayerTimes = {};
  bool _isLoading = true;
  String _location = 'Detecting location...';
  String _errorMessage = '';
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  final Map<String, String> _prayerIcons = {
    'Fajr': '🌅',
    'Dhuhr': '☀️',
    'Asr': '🌇',
    'Maghrib': '🌆',
    'Isha': '🌙',
  };

  final List<String> _prayerOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  @override
  void initState() {
    super.initState();
    _initializePrayerTimes();
    _startClock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  Future<void> _initializePrayerTimes() async {
    try {
      await _getPrayerTimes();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load prayer times: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Try to get location-based prayer times first
      Position? position = await _getCurrentPosition();

      if (position != null) {
        await _fetchPrayerTimesFromAPI(position.latitude, position.longitude);
        setState(() {
          _location = 'Your current location';
        });
      } else {
        // Fallback to country-based prayer times
        await _fetchPrayerTimesByCountry();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load prayer times. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _fetchPrayerTimesFromAPI(double latitude, double longitude) async {
    final url = 'https://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude&method=2';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'] as Map<String, dynamic>;

        setState(() {
          _prayerTimes = {
            'Fajr': timings['Fajr'] ?? '',
            'Dhuhr': timings['Dhuhr'] ?? '',
            'Asr': timings['Asr'] ?? '',
            'Maghrib': timings['Maghrib'] ?? '',
            'Isha': timings['Isha'] ?? '',
          };
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch prayer times');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> _fetchPrayerTimesByCountry() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProfile = authProvider.userProfile;

    if (userProfile?.country == null) {
      setState(() {
        _errorMessage = 'Please set your country in profile settings.';
        _isLoading = false;
      });
      return;
    }

    // Country code mapping for API
    final countryCodes = {
      'United States of America': 'US',
      'United Kingdom': 'GB',
      'United Arab Emirates': 'AE',
      'Saudi Arabia': 'SA',
      'Pakistan': 'PK',
      'India': 'IN',
      'Bangladesh': 'BD',
      'Indonesia': 'ID',
      'Egypt': 'EG',
      'Turkey': 'TR',
      'Canada': 'CA',
      'Malaysia': 'MY',
      'Nigeria': 'NG',
    };

    final countryCode = countryCodes[userProfile!.country] ?? 'US';
    final url = 'https://api.aladhan.com/v1/timingsByCity?city=${userProfile.country}&country=$countryCode&method=2';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'] as Map<String, dynamic>;

        setState(() {
          _prayerTimes = {
            'Fajr': timings['Fajr'] ?? '',
            'Dhuhr': timings['Dhuhr'] ?? '',
            'Asr': timings['Asr'] ?? '',
            'Maghrib': timings['Maghrib'] ?? '',
            'Isha': timings['Isha'] ?? '',
          };
          _location = userProfile.country;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch prayer times');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  String _formatTime12Hour(String time24) {
    if (time24.isEmpty) return '--:-- --';
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

      return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }

  String _getTimeToNextPrayer() {
    if (_prayerTimes.isEmpty) return '--:--:--';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final prayerName in _prayerOrder) {
      final prayerTimeStr = _prayerTimes[prayerName];
      if (prayerTimeStr == null || prayerTimeStr.isEmpty) continue;

      try {
        final parts = prayerTimeStr.split(':');
        final prayerTime = DateTime(
          today.year,
          today.month,
          today.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );

        if (prayerTime.isAfter(now)) {
          final difference = prayerTime.difference(now);
          final hours = difference.inHours.toString().padLeft(2, '0');
          final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
          final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
          return '$hours:$minutes:$seconds';
        }
      } catch (e) {
        continue;
      }
    }

    // If all prayers are done, show time to Fajr tomorrow
    final fajrTimeStr = _prayerTimes['Fajr'];
    if (fajrTimeStr != null && fajrTimeStr.isNotEmpty) {
      try {
        final parts = fajrTimeStr.split(':');
        final tomorrow = today.add(const Duration(days: 1));
        final fajrTime = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );

        final difference = fajrTime.difference(now);
        final hours = difference.inHours.toString().padLeft(2, '0');
        final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
        return '$hours:$minutes:$seconds';
      } catch (e) {
        // Ignore
      }
    }

    return '--:--:--';
  }

  String _getNextPrayerName() {
    if (_prayerTimes.isEmpty) return 'Loading...';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final prayerName in _prayerOrder) {
      final prayerTimeStr = _prayerTimes[prayerName];
      if (prayerTimeStr == null || prayerTimeStr.isEmpty) continue;

      try {
        final parts = prayerTimeStr.split(':');
        final prayerTime = DateTime(
          today.year,
          today.month,
          today.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );

        if (prayerTime.isAfter(now)) {
          return prayerName;
        }
      } catch (e) {
        continue;
      }
    }

    return 'Fajr'; // Next prayer is Fajr tomorrow
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Prayer Times',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on $_location',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Current Time
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _getPrayerTimes,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else ...[
                // Next Prayer Countdown
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _prayerIcons[_getNextPrayerName()] ?? '🕌',
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Next Prayer: ${_getNextPrayerName()}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getTimeToNextPrayer(),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Time until Adhan',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Today's Prayer Schedule
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Schedule',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._prayerOrder.map((prayerName) {
                        final isNextPrayer = prayerName == _getNextPrayerName();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isNextPrayer
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isNextPrayer
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _prayerIcons[prayerName] ?? '🕌',
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  prayerName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isNextPrayer
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                _formatTime12Hour(_prayerTimes[prayerName] ?? ''),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: isNextPrayer
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Refresh Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _getPrayerTimes,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Prayer Times'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
