import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  static BiometricService get instance => _instance;

  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics(String reason) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false, // Allow device PIN/pattern as fallback
        ),
      );
      return didAuthenticate;
    } catch (e) {
      print('Error during biometric authentication: $e');
      // Handle specific platform channel errors
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('type cast') ||
          e.toString().contains('List<Object?>')) {
        print('Platform channel error detected, falling back to PIN authentication');
        return false;
      }
      return false;
    }
  }

  // PIN Code Management
  Future<void> savePinCode(String pinCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin_code', pinCode);
  }

  Future<String?> getPinCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_pin_code');
  }

  Future<void> deletePinCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_pin_code');
  }

  Future<bool> verifyPinCode(String enteredPin) async {
    final savedPin = await getPinCode();
    return savedPin == enteredPin;
  }

  // Biometric Settings
  Future<void> saveBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  // Quick Authentication (Biometric or PIN)
  Future<bool> quickAuthenticate() async {
    final biometricEnabled = await isBiometricEnabled();
    final pinCode = await getPinCode();

    if (biometricEnabled) {
      final biometricAvailable = await isBiometricAvailable();
      if (biometricAvailable) {
        return await authenticateWithBiometrics('Authenticate to access Noor');
      }
    }

    // If biometric is not available or enabled, fall back to PIN
    if (pinCode != null && pinCode.isNotEmpty) {
      // This would typically show a PIN entry dialog
      // For now, we'll return false to indicate PIN authentication is needed
      return false;
    }

    return false;
  }

  // Check if any authentication method is available
  Future<bool> hasAuthenticationMethod() async {
    final biometricEnabled = await isBiometricEnabled();
    final pinCode = await getPinCode();

    if (biometricEnabled) {
      final biometricAvailable = await isBiometricAvailable();
      if (biometricAvailable) {
        return true;
      }
    }

    return pinCode != null && pinCode.isNotEmpty;
  }
}
