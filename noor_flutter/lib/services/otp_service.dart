import 'dart:convert';
import 'package:http/http.dart' as http;

class OTPService {
  // Production webapp URL (which now handles SMTP directly)
  static const String baseUrl = 'https://noor-web-29ckxd946-charanjit-singhs-projects-01b838c6.vercel.app';
  // static const String baseUrl = 'http://localhost:3000'; // Uncomment for local development

  // Send OTP to email using webapp's SMTP
  static Future<Map<String, dynamic>> sendOTP({
    required String email,
    String? name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/send-email'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'name': name,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Verify OTP using webapp's verification
  static Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/verify-email'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to verify OTP',
          'attemptsLeft': data['attemptsLeft'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Health check
  static Future<bool> isServiceAvailable() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
