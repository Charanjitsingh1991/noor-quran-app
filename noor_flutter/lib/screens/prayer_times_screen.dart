import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
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
  DateTime _currentTimezoneTime = DateTime.now();
  String _currentTimezone = 'Local Time';

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
    _initializeTimezone();
  }

  Future<void> _initializeTimezone() async {
    tz.initializeTimeZones();
    // Initialize prayer times after timezone is ready
    await _initializePrayerTimes();
    _startClock();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Force refresh timezone when dependencies change (e.g., when country is updated)
    _updateTimezoneTime();
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
          _updateTimezoneTime();
        });
      }
    });
  }

  void _updateTimezoneTime() {
    try {
      // Use a try-catch to safely access context
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProfile = authProvider.userProfile;

      if (userProfile?.country != null && userProfile.country.isNotEmpty) {
        // Timezone mapping for countries
        final countryTimezones = {
          'United States of America': 'America/New_York',
          'United Kingdom': 'Europe/London',
          'United Arab Emirates': 'Asia/Dubai',
          'Saudi Arabia': 'Asia/Riyadh',
          'Pakistan': 'Asia/Karachi',
          'India': 'Asia/Kolkata',
          'Bangladesh': 'Asia/Dhaka',
          'Indonesia': 'Asia/Jakarta',
          'Egypt': 'Africa/Cairo',
          'Turkey': 'Europe/Istanbul',
          'Canada': 'America/Toronto',
          'Malaysia': 'Asia/Kuala_Lumpur',
          'Nigeria': 'Africa/Lagos',
          'Australia': 'Australia/Sydney',
          'Germany': 'Europe/Berlin',
          'France': 'Europe/Paris',
          'Italy': 'Europe/Rome',
          'Spain': 'Europe/Madrid',
          'Netherlands': 'Europe/Amsterdam',
          'Belgium': 'Europe/Brussels',
          'Switzerland': 'Europe/Zurich',
          'Austria': 'Europe/Vienna',
          'Sweden': 'Europe/Stockholm',
          'Norway': 'Europe/Oslo',
          'Denmark': 'Europe/Copenhagen',
          'Finland': 'Europe/Helsinki',
          'Ireland': 'Europe/Dublin',
          'Portugal': 'Europe/Lisbon',
          'Greece': 'Europe/Athens',
          'Poland': 'Europe/Warsaw',
          'Czech Republic': 'Europe/Prague',
          'Hungary': 'Europe/Budapest',
          'Romania': 'Europe/Bucharest',
          'Bulgaria': 'Europe/Sofia',
          'Croatia': 'Europe/Zagreb',
          'Slovenia': 'Europe/Ljubljana',
          'Slovakia': 'Europe/Bratislava',
          'Serbia': 'Europe/Belgrade',
          'Bosnia and Herzegovina': 'Europe/Sarajevo',
          'Montenegro': 'Europe/Podgorica',
          'Kosovo': 'Europe/Belgrade',
          'Albania': 'Europe/Tirane',
          'North Macedonia': 'Europe/Skopje',
          'Jordan': 'Asia/Amman',
          'Lebanon': 'Asia/Beirut',
          'Syria': 'Asia/Damascus',
          'Iraq': 'Asia/Baghdad',
          'Kuwait': 'Asia/Kuwait',
          'Qatar': 'Asia/Qatar',
          'Bahrain': 'Asia/Bahrain',
          'Oman': 'Asia/Muscat',
          'Yemen': 'Asia/Aden',
          'Iran': 'Asia/Tehran',
          'Afghanistan': 'Asia/Kabul',
          'Uzbekistan': 'Asia/Tashkent',
          'Kazakhstan': 'Asia/Almaty',
          'Kyrgyzstan': 'Asia/Bishkek',
          'Tajikistan': 'Asia/Dushanbe',
          'Turkmenistan': 'Asia/Ashgabat',
          'Azerbaijan': 'Asia/Baku',
          'Georgia': 'Asia/Tbilisi',
          'Armenia': 'Asia/Yerevan',
          'Thailand': 'Asia/Bangkok',
          'Singapore': 'Asia/Singapore',
          'Philippines': 'Asia/Manila',
          'Vietnam': 'Asia/Ho_Chi_Minh',
          'South Korea': 'Asia/Seoul',
          'Japan': 'Asia/Tokyo',
          'China': 'Asia/Shanghai',
          'Taiwan': 'Asia/Taipei',
          'Hong Kong': 'Asia/Hong_Kong',
          'Macau': 'Asia/Macau',
          'Mongolia': 'Asia/Ulaanbaatar',
          'Nepal': 'Asia/Kathmandu',
          'Bhutan': 'Asia/Thimphu',
          'Sri Lanka': 'Asia/Colombo',
          'Myanmar': 'Asia/Yangon',
          'Cambodia': 'Asia/Phnom_Penh',
          'Laos': 'Asia/Vientiane',
          'Brunei': 'Asia/Brunei',
          'East Timor': 'Asia/Dili',
          'Morocco': 'Africa/Casablanca',
          'Algeria': 'Africa/Algiers',
          'Tunisia': 'Africa/Tunis',
          'Libya': 'Africa/Tripoli',
          'Sudan': 'Africa/Khartoum',
          'South Sudan': 'Africa/Juba',
          'Ethiopia': 'Africa/Addis_Ababa',
          'Eritrea': 'Africa/Asmara',
          'Djibouti': 'Africa/Djibouti',
          'Somalia': 'Africa/Mogadishu',
          'Kenya': 'Africa/Nairobi',
          'Tanzania': 'Africa/Dar_es_Salaam',
          'Uganda': 'Africa/Kampala',
          'Rwanda': 'Africa/Kigali',
          'Burundi': 'Africa/Bujumbura',
          'Democratic Republic of the Congo': 'Africa/Kinshasa',
          'Republic of the Congo': 'Africa/Brazzaville',
          'Gabon': 'Africa/Libreville',
          'Cameroon': 'Africa/Douala',
          'Central African Republic': 'Africa/Bangui',
          'Chad': 'Africa/Ndjamena',
          'Angola': 'Africa/Luanda',
          'Zambia': 'Africa/Lusaka',
          'Zimbabwe': 'Africa/Harare',
          'Mozambique': 'Africa/Maputo',
          'Malawi': 'Africa/Blantyre',
          'Botswana': 'Africa/Gaborone',
          'Namibia': 'Africa/Windhoek',
          'South Africa': 'Africa/Johannesburg',
          'Lesotho': 'Africa/Maseru',
          'Swaziland': 'Africa/Mbabane',
          'Ghana': 'Africa/Accra',
          'Ivory Coast': 'Africa/Abidjan',
          'Burkina Faso': 'Africa/Ouagadougou',
          'Mali': 'Africa/Bamako',
          'Niger': 'Africa/Niamey',
          'Senegal': 'Africa/Dakar',
          'Gambia': 'Africa/Banjul',
          'Guinea': 'Africa/Conakry',
          'Sierra Leone': 'Africa/Freetown',
          'Liberia': 'Africa/Monrovia',
          'Togo': 'Africa/Lome',
          'Benin': 'Africa/Porto-Novo',
          'Brazil': 'America/Sao_Paulo',
          'Argentina': 'America/Argentina/Buenos_Aires',
          'Chile': 'America/Santiago',
          'Colombia': 'America/Bogota',
          'Peru': 'America/Lima',
          'Venezuela': 'America/Caracas',
          'Ecuador': 'America/Guayaquil',
          'Bolivia': 'America/La_Paz',
          'Paraguay': 'America/Asuncion',
          'Uruguay': 'America/Montevideo',
          'Mexico': 'America/Mexico_City',
          'Cuba': 'America/Havana',
          'Dominican Republic': 'America/Santo_Domingo',
          'Haiti': 'America/Port-au-Prince',
          'Jamaica': 'America/Jamaica',
          'Trinidad and Tobago': 'America/Port_of_Spain',
          'Barbados': 'America/Barbados',
          'Bahamas': 'America/Nassau',
          'Panama': 'America/Panama',
          'Costa Rica': 'America/Costa_Rica',
          'Nicaragua': 'America/Managua',
          'Honduras': 'America/Tegucigalpa',
          'El Salvador': 'America/El_Salvador',
          'Guatemala': 'America/Guatemala',
          'Belize': 'America/Belize',
        };

        final timezoneName = countryTimezones[userProfile.country];
        if (timezoneName != null && timezoneName.isNotEmpty) {
          try {
            final location = tz.getLocation(timezoneName);
            final now = tz.TZDateTime.now(location);
            _currentTimezoneTime = now;
            _currentTimezone = userProfile.country;
          } catch (e) {
            // If timezone conversion fails, fall back to local time
            _currentTimezoneTime = DateTime.now();
            _currentTimezone = 'Local Time';
          }
        } else {
          _currentTimezoneTime = DateTime.now();
          _currentTimezone = 'Local Time';
        }
      } else {
        _currentTimezoneTime = DateTime.now();
        _currentTimezone = 'Local Time';
      }
    } catch (e) {
      // If anything fails, fall back to local time
      _currentTimezoneTime = DateTime.now();
      _currentTimezone = 'Local Time';
    }
  }

  DateTime _getCurrentTimeInTimezone() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProfile = authProvider.userProfile;

      if (userProfile?.country != null) {
        // Timezone mapping for countries
        final countryTimezones = {
          'United States of America': 'America/New_York',
          'United Kingdom': 'Europe/London',
          'United Arab Emirates': 'Asia/Dubai',
          'Saudi Arabia': 'Asia/Riyadh',
          'Pakistan': 'Asia/Karachi',
          'India': 'Asia/Kolkata',
          'Bangladesh': 'Asia/Dhaka',
          'Indonesia': 'Asia/Jakarta',
          'Egypt': 'Africa/Cairo',
          'Turkey': 'Europe/Istanbul',
          'Canada': 'America/Toronto',
          'Malaysia': 'Asia/Kuala_Lumpur',
          'Nigeria': 'Africa/Lagos',
          'Australia': 'Australia/Sydney',
          'Germany': 'Europe/Berlin',
          'France': 'Europe/Paris',
          'Italy': 'Europe/Rome',
          'Spain': 'Europe/Madrid',
          'Netherlands': 'Europe/Amsterdam',
          'Belgium': 'Europe/Brussels',
          'Switzerland': 'Europe/Zurich',
          'Austria': 'Europe/Vienna',
          'Sweden': 'Europe/Stockholm',
          'Norway': 'Europe/Oslo',
          'Denmark': 'Europe/Copenhagen',
          'Finland': 'Europe/Helsinki',
          'Ireland': 'Europe/Dublin',
          'Portugal': 'Europe/Lisbon',
          'Greece': 'Europe/Athens',
          'Poland': 'Europe/Warsaw',
          'Czech Republic': 'Europe/Prague',
          'Hungary': 'Europe/Budapest',
          'Romania': 'Europe/Bucharest',
          'Bulgaria': 'Europe/Sofia',
          'Croatia': 'Europe/Zagreb',
          'Slovenia': 'Europe/Ljubljana',
          'Slovakia': 'Europe/Bratislava',
          'Serbia': 'Europe/Belgrade',
          'Bosnia and Herzegovina': 'Europe/Sarajevo',
          'Montenegro': 'Europe/Podgorica',
          'Kosovo': 'Europe/Belgrade',
          'Albania': 'Europe/Tirane',
          'North Macedonia': 'Europe/Skopje',
          'Jordan': 'Asia/Amman',
          'Lebanon': 'Asia/Beirut',
          'Syria': 'Asia/Damascus',
          'Iraq': 'Asia/Baghdad',
          'Kuwait': 'Asia/Kuwait',
          'Qatar': 'Asia/Qatar',
          'Bahrain': 'Asia/Bahrain',
          'Oman': 'Asia/Muscat',
          'Yemen': 'Asia/Aden',
          'Iran': 'Asia/Tehran',
          'Afghanistan': 'Asia/Kabul',
          'Uzbekistan': 'Asia/Tashkent',
          'Kazakhstan': 'Asia/Almaty',
          'Kyrgyzstan': 'Asia/Bishkek',
          'Tajikistan': 'Asia/Dushanbe',
          'Turkmenistan': 'Asia/Ashgabat',
          'Azerbaijan': 'Asia/Baku',
          'Georgia': 'Asia/Tbilisi',
          'Armenia': 'Asia/Yerevan',
          'Thailand': 'Asia/Bangkok',
          'Singapore': 'Asia/Singapore',
          'Philippines': 'Asia/Manila',
          'Vietnam': 'Asia/Ho_Chi_Minh',
          'South Korea': 'Asia/Seoul',
          'Japan': 'Asia/Tokyo',
          'China': 'Asia/Shanghai',
          'Taiwan': 'Asia/Taipei',
          'Hong Kong': 'Asia/Hong_Kong',
          'Macau': 'Asia/Macau',
          'Mongolia': 'Asia/Ulaanbaatar',
          'Nepal': 'Asia/Kathmandu',
          'Bhutan': 'Asia/Thimphu',
          'Sri Lanka': 'Asia/Colombo',
          'Myanmar': 'Asia/Yangon',
          'Cambodia': 'Asia/Phnom_Penh',
          'Laos': 'Asia/Vientiane',
          'Brunei': 'Asia/Brunei',
          'East Timor': 'Asia/Dili',
          'Morocco': 'Africa/Casablanca',
          'Algeria': 'Africa/Algiers',
          'Tunisia': 'Africa/Tunis',
          'Libya': 'Africa/Tripoli',
          'Sudan': 'Africa/Khartoum',
          'South Sudan': 'Africa/Juba',
          'Ethiopia': 'Africa/Addis_Ababa',
          'Eritrea': 'Africa/Asmara',
          'Djibouti': 'Africa/Djibouti',
          'Somalia': 'Africa/Mogadishu',
          'Kenya': 'Africa/Nairobi',
          'Tanzania': 'Africa/Dar_es_Salaam',
          'Uganda': 'Africa/Kampala',
          'Rwanda': 'Africa/Kigali',
          'Burundi': 'Africa/Bujumbura',
          'Democratic Republic of the Congo': 'Africa/Kinshasa',
          'Republic of the Congo': 'Africa/Brazzaville',
          'Gabon': 'Africa/Libreville',
          'Cameroon': 'Africa/Douala',
          'Central African Republic': 'Africa/Bangui',
          'Chad': 'Africa/Ndjamena',
          'Angola': 'Africa/Luanda',
          'Zambia': 'Africa/Lusaka',
          'Zimbabwe': 'Africa/Harare',
          'Mozambique': 'Africa/Maputo',
          'Malawi': 'Africa/Blantyre',
          'Botswana': 'Africa/Gaborone',
          'Namibia': 'Africa/Windhoek',
          'South Africa': 'Africa/Johannesburg',
          'Lesotho': 'Africa/Maseru',
          'Swaziland': 'Africa/Mbabane',
          'Ghana': 'Africa/Accra',
          'Ivory Coast': 'Africa/Abidjan',
          'Burkina Faso': 'Africa/Ouagadougou',
          'Mali': 'Africa/Bamako',
          'Niger': 'Africa/Niamey',
          'Senegal': 'Africa/Dakar',
          'Gambia': 'Africa/Banjul',
          'Guinea': 'Africa/Conakry',
          'Sierra Leone': 'Africa/Freetown',
          'Liberia': 'Africa/Monrovia',
          'Togo': 'Africa/Lome',
          'Benin': 'Africa/Porto-Novo',
          'Brazil': 'America/Sao_Paulo',
          'Argentina': 'America/Argentina/Buenos_Aires',
          'Chile': 'America/Santiago',
          'Colombia': 'America/Bogota',
          'Peru': 'America/Lima',
          'Venezuela': 'America/Caracas',
          'Ecuador': 'America/Guayaquil',
          'Bolivia': 'America/La_Paz',
          'Paraguay': 'America/Asuncion',
          'Uruguay': 'America/Montevideo',
          'Mexico': 'America/Mexico_City',
          'Cuba': 'America/Havana',
          'Dominican Republic': 'America/Santo_Domingo',
          'Haiti': 'America/Port-au-Prince',
          'Jamaica': 'America/Jamaica',
          'Trinidad and Tobago': 'America/Port_of_Spain',
          'Barbados': 'America/Barbados',
          'Bahamas': 'America/Nassau',
          'Panama': 'America/Panama',
          'Costa Rica': 'America/Costa_Rica',
          'Nicaragua': 'America/Managua',
          'Honduras': 'America/Tegucigalpa',
          'El Salvador': 'America/El_Salvador',
          'Guatemala': 'America/Guatemala',
          'Belize': 'America/Belize',
        };

        final timezoneName = countryTimezones[userProfile.country];
        if (timezoneName != null) {
          try {
            final location = tz.getLocation(timezoneName);
            final now = tz.TZDateTime.now(location);
            _currentTimezone = userProfile.country;
            return now;
          } catch (e) {
            // If timezone conversion fails, fall back to local time
          }
        }
      }
    } catch (e) {
      // If anything fails, fall back to local time
    }

    _currentTimezone = 'Local Time';
    return DateTime.now();
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

    // Timezone mapping for countries
    final countryTimezones = {
      'United States of America': 'America/New_York',
      'United Kingdom': 'Europe/London',
      'United Arab Emirates': 'Asia/Dubai',
      'Saudi Arabia': 'Asia/Riyadh',
      'Pakistan': 'Asia/Karachi',
      'India': 'Asia/Kolkata',
      'Bangladesh': 'Asia/Dhaka',
      'Indonesia': 'Asia/Jakarta',
      'Egypt': 'Africa/Cairo',
      'Turkey': 'Europe/Istanbul',
      'Canada': 'America/Toronto',
      'Malaysia': 'Asia/Kuala_Lumpur',
      'Nigeria': 'Africa/Lagos',
      'Australia': 'Australia/Sydney',
      'Germany': 'Europe/Berlin',
      'France': 'Europe/Paris',
      'Italy': 'Europe/Rome',
      'Spain': 'Europe/Madrid',
      'Netherlands': 'Europe/Amsterdam',
      'Belgium': 'Europe/Brussels',
      'Switzerland': 'Europe/Zurich',
      'Austria': 'Europe/Vienna',
      'Sweden': 'Europe/Stockholm',
      'Norway': 'Europe/Oslo',
      'Denmark': 'Europe/Copenhagen',
      'Finland': 'Europe/Helsinki',
      'Ireland': 'Europe/Dublin',
      'Portugal': 'Europe/Lisbon',
      'Greece': 'Europe/Athens',
      'Poland': 'Europe/Warsaw',
      'Czech Republic': 'Europe/Prague',
      'Hungary': 'Europe/Budapest',
      'Romania': 'Europe/Bucharest',
      'Bulgaria': 'Europe/Sofia',
      'Croatia': 'Europe/Zagreb',
      'Slovenia': 'Europe/Ljubljana',
      'Slovakia': 'Europe/Bratislava',
      'Serbia': 'Europe/Belgrade',
      'Bosnia and Herzegovina': 'Europe/Sarajevo',
      'Montenegro': 'Europe/Podgorica',
      'Kosovo': 'Europe/Belgrade',
      'Albania': 'Europe/Tirane',
      'North Macedonia': 'Europe/Skopje',
      'Jordan': 'Asia/Amman',
      'Lebanon': 'Asia/Beirut',
      'Syria': 'Asia/Damascus',
      'Iraq': 'Asia/Baghdad',
      'Kuwait': 'Asia/Kuwait',
      'Qatar': 'Asia/Qatar',
      'Bahrain': 'Asia/Bahrain',
      'Oman': 'Asia/Muscat',
      'Yemen': 'Asia/Aden',
      'Iran': 'Asia/Tehran',
      'Afghanistan': 'Asia/Kabul',
      'Uzbekistan': 'Asia/Tashkent',
      'Kazakhstan': 'Asia/Almaty',
      'Kyrgyzstan': 'Asia/Bishkek',
      'Tajikistan': 'Asia/Dushanbe',
      'Turkmenistan': 'Asia/Ashgabat',
      'Azerbaijan': 'Asia/Baku',
      'Georgia': 'Asia/Tbilisi',
      'Armenia': 'Asia/Yerevan',
      'Thailand': 'Asia/Bangkok',
      'Singapore': 'Asia/Singapore',
      'Philippines': 'Asia/Manila',
      'Vietnam': 'Asia/Ho_Chi_Minh',
      'South Korea': 'Asia/Seoul',
      'Japan': 'Asia/Tokyo',
      'China': 'Asia/Shanghai',
      'Taiwan': 'Asia/Taipei',
      'Hong Kong': 'Asia/Hong_Kong',
      'Macau': 'Asia/Macau',
      'Mongolia': 'Asia/Ulaanbaatar',
      'Nepal': 'Asia/Kathmandu',
      'Bhutan': 'Asia/Thimphu',
      'Sri Lanka': 'Asia/Colombo',
      'Myanmar': 'Asia/Yangon',
      'Cambodia': 'Asia/Phnom_Penh',
      'Laos': 'Asia/Vientiane',
      'Brunei': 'Asia/Brunei',
      'East Timor': 'Asia/Dili',
      'Morocco': 'Africa/Casablanca',
      'Algeria': 'Africa/Algiers',
      'Tunisia': 'Africa/Tunis',
      'Libya': 'Africa/Tripoli',
      'Sudan': 'Africa/Khartoum',
      'South Sudan': 'Africa/Juba',
      'Ethiopia': 'Africa/Addis_Ababa',
      'Eritrea': 'Africa/Asmara',
      'Djibouti': 'Africa/Djibouti',
      'Somalia': 'Africa/Mogadishu',
      'Kenya': 'Africa/Nairobi',
      'Tanzania': 'Africa/Dar_es_Salaam',
      'Uganda': 'Africa/Kampala',
      'Rwanda': 'Africa/Kigali',
      'Burundi': 'Africa/Bujumbura',
      'Democratic Republic of the Congo': 'Africa/Kinshasa',
      'Republic of the Congo': 'Africa/Brazzaville',
      'Gabon': 'Africa/Libreville',
      'Cameroon': 'Africa/Douala',
      'Central African Republic': 'Africa/Bangui',
      'Chad': 'Africa/Ndjamena',
      'Angola': 'Africa/Luanda',
      'Zambia': 'Africa/Lusaka',
      'Zimbabwe': 'Africa/Harare',
      'Mozambique': 'Africa/Maputo',
      'Malawi': 'Africa/Blantyre',
      'Botswana': 'Africa/Gaborone',
      'Namibia': 'Africa/Windhoek',
      'South Africa': 'Africa/Johannesburg',
      'Lesotho': 'Africa/Maseru',
      'Swaziland': 'Africa/Mbabane',
      'Ghana': 'Africa/Accra',
      'Ivory Coast': 'Africa/Abidjan',
      'Burkina Faso': 'Africa/Ouagadougou',
      'Mali': 'Africa/Bamako',
      'Niger': 'Africa/Niamey',
      'Senegal': 'Africa/Dakar',
      'Gambia': 'Africa/Banjul',
      'Guinea': 'Africa/Conakry',
      'Sierra Leone': 'Africa/Freetown',
      'Liberia': 'Africa/Monrovia',
      'Togo': 'Africa/Lome',
      'Benin': 'Africa/Porto-Novo',
      'Brazil': 'America/Sao_Paulo',
      'Argentina': 'America/Argentina/Buenos_Aires',
      'Chile': 'America/Santiago',
      'Colombia': 'America/Bogota',
      'Peru': 'America/Lima',
      'Venezuela': 'America/Caracas',
      'Ecuador': 'America/Guayaquil',
      'Bolivia': 'America/La_Paz',
      'Paraguay': 'America/Asuncion',
      'Uruguay': 'America/Montevideo',
      'Mexico': 'America/Mexico_City',
      'Cuba': 'America/Havana',
      'Dominican Republic': 'America/Santo_Domingo',
      'Haiti': 'America/Port-au-Prince',
      'Jamaica': 'America/Jamaica',
      'Trinidad and Tobago': 'America/Port_of_Spain',
      'Barbados': 'America/Barbados',
      'Bahamas': 'America/Nassau',
      'Panama': 'America/Panama',
      'Costa Rica': 'America/Costa_Rica',
      'Nicaragua': 'America/Managua',
      'Honduras': 'America/Tegucigalpa',
      'El Salvador': 'America/El_Salvador',
      'Guatemala': 'America/Guatemala',
      'Belize': 'America/Belize',
    };

    // Expanded country code mapping for API
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
      'Australia': 'AU',
      'Germany': 'DE',
      'France': 'FR',
      'Italy': 'IT',
      'Spain': 'ES',
      'Netherlands': 'NL',
      'Belgium': 'BE',
      'Switzerland': 'CH',
      'Austria': 'AT',
      'Sweden': 'SE',
      'Norway': 'NO',
      'Denmark': 'DK',
      'Finland': 'FI',
      'Ireland': 'IE',
      'Portugal': 'PT',
      'Greece': 'GR',
      'Poland': 'PL',
      'Czech Republic': 'CZ',
      'Hungary': 'HU',
      'Romania': 'RO',
      'Bulgaria': 'BG',
      'Croatia': 'HR',
      'Slovenia': 'SI',
      'Slovakia': 'SK',
      'Serbia': 'RS',
      'Bosnia and Herzegovina': 'BA',
      'Montenegro': 'ME',
      'Kosovo': 'XK',
      'Albania': 'AL',
      'North Macedonia': 'MK',
      'Jordan': 'JO',
      'Lebanon': 'LB',
      'Syria': 'SY',
      'Iraq': 'IQ',
      'Kuwait': 'KW',
      'Qatar': 'QA',
      'Bahrain': 'BH',
      'Oman': 'OM',
      'Yemen': 'YE',
      'Iran': 'IR',
      'Afghanistan': 'AF',
      'Uzbekistan': 'UZ',
      'Kazakhstan': 'KZ',
      'Kyrgyzstan': 'KG',
      'Tajikistan': 'TJ',
      'Turkmenistan': 'TM',
      'Azerbaijan': 'AZ',
      'Georgia': 'GE',
      'Armenia': 'AM',
      'Thailand': 'TH',
      'Singapore': 'SG',
      'Philippines': 'PH',
      'Vietnam': 'VN',
      'South Korea': 'KR',
      'Japan': 'JP',
      'China': 'CN',
      'Taiwan': 'TW',
      'Hong Kong': 'HK',
      'Macau': 'MO',
      'Mongolia': 'MN',
      'Nepal': 'NP',
      'Bhutan': 'BT',
      'Sri Lanka': 'LK',
      'Myanmar': 'MM',
      'Cambodia': 'KH',
      'Laos': 'LA',
      'Brunei': 'BN',
      'East Timor': 'TL',
      'Morocco': 'MA',
      'Algeria': 'DZ',
      'Tunisia': 'TN',
      'Libya': 'LY',
      'Sudan': 'SD',
      'South Sudan': 'SS',
      'Ethiopia': 'ET',
      'Eritrea': 'ER',
      'Djibouti': 'DJ',
      'Somalia': 'SO',
      'Kenya': 'KE',
      'Tanzania': 'TZ',
      'Uganda': 'UG',
      'Rwanda': 'RW',
      'Burundi': 'BI',
      'Democratic Republic of the Congo': 'CD',
      'Republic of the Congo': 'CG',
      'Gabon': 'GA',
      'Cameroon': 'CM',
      'Central African Republic': 'CF',
      'Chad': 'TD',
      'Angola': 'AO',
      'Zambia': 'ZM',
      'Zimbabwe': 'ZW',
      'Mozambique': 'MZ',
      'Malawi': 'MW',
      'Botswana': 'BW',
      'Namibia': 'NA',
      'South Africa': 'ZA',
      'Lesotho': 'LS',
      'Swaziland': 'SZ',
      'Ghana': 'GH',
      'Ivory Coast': 'CI',
      'Burkina Faso': 'BF',
      'Mali': 'ML',
      'Niger': 'NE',
      'Chad': 'TD',
      'Senegal': 'SN',
      'Gambia': 'GM',
      'Guinea': 'GN',
      'Sierra Leone': 'SL',
      'Liberia': 'LR',
      'Togo': 'TG',
      'Benin': 'BJ',
      'Brazil': 'BR',
      'Argentina': 'AR',
      'Chile': 'CL',
      'Colombia': 'CO',
      'Peru': 'PE',
      'Venezuela': 'VE',
      'Ecuador': 'EC',
      'Bolivia': 'BO',
      'Paraguay': 'PY',
      'Uruguay': 'UY',
      'Mexico': 'MX',
      'Cuba': 'CU',
      'Dominican Republic': 'DO',
      'Haiti': 'HT',
      'Jamaica': 'JM',
      'Trinidad and Tobago': 'TT',
      'Barbados': 'BB',
      'Bahamas': 'BS',
      'Panama': 'PA',
      'Costa Rica': 'CR',
      'Nicaragua': 'NI',
      'Honduras': 'HN',
      'El Salvador': 'SV',
      'Guatemala': 'GT',
      'Belize': 'BZ',
    };

    // Major cities for each country (for better prayer time accuracy)
    final countryCities = {
      'United States of America': 'New York',
      'United Kingdom': 'London',
      'United Arab Emirates': 'Dubai',
      'Saudi Arabia': 'Mecca',
      'Pakistan': 'Karachi',
      'India': 'Delhi',
      'Bangladesh': 'Dhaka',
      'Indonesia': 'Jakarta',
      'Egypt': 'Cairo',
      'Turkey': 'Istanbul',
      'Canada': 'Toronto',
      'Malaysia': 'Kuala Lumpur',
      'Nigeria': 'Lagos',
      'Australia': 'Sydney',
      'Germany': 'Berlin',
      'France': 'Paris',
      'Italy': 'Rome',
      'Spain': 'Madrid',
      'Netherlands': 'Amsterdam',
      'Belgium': 'Brussels',
      'Switzerland': 'Zurich',
      'Austria': 'Vienna',
      'Sweden': 'Stockholm',
      'Norway': 'Oslo',
      'Denmark': 'Copenhagen',
      'Finland': 'Helsinki',
      'Ireland': 'Dublin',
      'Portugal': 'Lisbon',
      'Greece': 'Athens',
      'Poland': 'Warsaw',
      'Czech Republic': 'Prague',
      'Hungary': 'Budapest',
      'Romania': 'Bucharest',
      'Bulgaria': 'Sofia',
      'Croatia': 'Zagreb',
      'Slovenia': 'Ljubljana',
      'Slovakia': 'Bratislava',
      'Serbia': 'Belgrade',
      'Bosnia and Herzegovina': 'Sarajevo',
      'Montenegro': 'Podgorica',
      'Kosovo': 'Pristina',
      'Albania': 'Tirana',
      'North Macedonia': 'Skopje',
      'Jordan': 'Amman',
      'Lebanon': 'Beirut',
      'Syria': 'Damascus',
      'Iraq': 'Baghdad',
      'Kuwait': 'Kuwait City',
      'Qatar': 'Doha',
      'Bahrain': 'Manama',
      'Oman': 'Muscat',
      'Yemen': 'Sana\'a',
      'Iran': 'Tehran',
      'Afghanistan': 'Kabul',
      'Uzbekistan': 'Tashkent',
      'Kazakhstan': 'Astana',
      'Kyrgyzstan': 'Bishkek',
      'Tajikistan': 'Dushanbe',
      'Turkmenistan': 'Ashgabat',
      'Azerbaijan': 'Baku',
      'Georgia': 'Tbilisi',
      'Armenia': 'Yerevan',
      'Thailand': 'Bangkok',
      'Singapore': 'Singapore',
      'Philippines': 'Manila',
      'Vietnam': 'Hanoi',
      'South Korea': 'Seoul',
      'Japan': 'Tokyo',
      'China': 'Beijing',
      'Taiwan': 'Taipei',
      'Hong Kong': 'Hong Kong',
      'Macau': 'Macau',
      'Mongolia': 'Ulaanbaatar',
      'Nepal': 'Kathmandu',
      'Bhutan': 'Thimphu',
      'Sri Lanka': 'Colombo',
      'Myanmar': 'Yangon',
      'Cambodia': 'Phnom Penh',
      'Laos': 'Vientiane',
      'Brunei': 'Bandar Seri Begawan',
      'East Timor': 'Dili',
      'Morocco': 'Rabat',
      'Algeria': 'Algiers',
      'Tunisia': 'Tunis',
      'Libya': 'Tripoli',
      'Sudan': 'Khartoum',
      'South Sudan': 'Juba',
      'Ethiopia': 'Addis Ababa',
      'Eritrea': 'Asmara',
      'Djibouti': 'Djibouti',
      'Somalia': 'Mogadishu',
      'Kenya': 'Nairobi',
      'Tanzania': 'Dar es Salaam',
      'Uganda': 'Kampala',
      'Rwanda': 'Kigali',
      'Burundi': 'Bujumbura',
      'Democratic Republic of the Congo': 'Kinshasa',
      'Republic of the Congo': 'Brazzaville',
      'Gabon': 'Libreville',
      'Cameroon': 'Yaounde',
      'Central African Republic': 'Bangui',
      'Chad': 'N\'Djamena',
      'Angola': 'Luanda',
      'Zambia': 'Lusaka',
      'Zimbabwe': 'Harare',
      'Mozambique': 'Maputo',
      'Malawi': 'Lilongwe',
      'Botswana': 'Gaborone',
      'Namibia': 'Windhoek',
      'South Africa': 'Johannesburg',
      'Lesotho': 'Maseru',
      'Swaziland': 'Mbabane',
      'Ghana': 'Accra',
      'Ivory Coast': 'Abidjan',
      'Burkina Faso': 'Ouagadougou',
      'Mali': 'Bamako',
      'Niger': 'Niamey',
      'Senegal': 'Dakar',
      'Gambia': 'Banjul',
      'Guinea': 'Conakry',
      'Sierra Leone': 'Freetown',
      'Liberia': 'Monrovia',
      'Togo': 'Lome',
      'Benin': 'Porto-Novo',
      'Brazil': 'Sao Paulo',
      'Argentina': 'Buenos Aires',
      'Chile': 'Santiago',
      'Colombia': 'Bogota',
      'Peru': 'Lima',
      'Venezuela': 'Caracas',
      'Ecuador': 'Quito',
      'Bolivia': 'La Paz',
      'Paraguay': 'Asuncion',
      'Uruguay': 'Montevideo',
      'Mexico': 'Mexico City',
      'Cuba': 'Havana',
      'Dominican Republic': 'Santo Domingo',
      'Haiti': 'Port-au-Prince',
      'Jamaica': 'Kingston',
      'Trinidad and Tobago': 'Port of Spain',
      'Barbados': 'Bridgetown',
      'Bahamas': 'Nassau',
      'Panama': 'Panama City',
      'Costa Rica': 'San Jose',
      'Nicaragua': 'Managua',
      'Honduras': 'Tegucigalpa',
      'El Salvador': 'San Salvador',
      'Guatemala': 'Guatemala City',
      'Belize': 'Belmopan',
    };

    final countryCode = countryCodes[userProfile!.country] ?? 'AE'; // Default to UAE
    final city = countryCities[userProfile.country] ?? userProfile.country;

    // Use the correct API endpoint with proper city and country parameters
    final url = 'https://api.aladhan.com/v1/timingsByCity?city=${Uri.encodeComponent(city)}&country=$countryCode&method=2';

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
          _location = '$city, ${userProfile.country}';
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch prayer times for ${userProfile.country}');
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
                      child: Column(
                        children: [
                          Text(
                            '${_currentTimezoneTime.hour.toString().padLeft(2, '0')}:${_currentTimezoneTime.minute.toString().padLeft(2, '0')}:${_currentTimezoneTime.second.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentTimezone,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
