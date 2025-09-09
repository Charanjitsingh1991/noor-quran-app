import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/otp_service.dart';
import '../providers/auth_provider.dart';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String country;
  final String? name;
  final String? dob;
  final String? fontSize;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.password,
    required this.country,
    this.name,
    this.dob,
    this.fontSize,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendTimer = 0;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendTimer = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _resendTimer--);
      }
      return _resendTimer > 0;
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      setState(() => _errorMessage = 'Please enter a 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await OTPService.verifyOTP(
        email: widget.email,
        otp: _otpController.text,
      );

      if (result['success'] == true) {
        // OTP verified successfully, now create the account
        await _createAccount();
      } else {
        setState(() {
          _errorMessage = result['error'];
          if (result['attemptsLeft'] != null) {
            _errorMessage = '${result['error']} (${result['attemptsLeft']} attempts left)';
          }
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Verification failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createAccount() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final firebaseService = FirebaseService.instance;

      // Create user account with Firebase
      final userCredential = await firebaseService.createUserWithEmailAndPassword(
        widget.email,
        widget.password,
      );

      // Create user profile with all the collected data
      final profile = UserProfile(
        uid: userCredential.user!.uid,
        email: widget.email,
        name: widget.name,
        country: widget.country,
        fontSize: widget.fontSize ?? 'md',
      );

      await firebaseService.createUserProfile(profile);

      // Update additional profile information if provided
      final updates = <String, dynamic>{};
      if (widget.dob != null) {
        updates['dob'] = widget.dob;
      }
      if (widget.fontSize != null && widget.fontSize != 'md') {
        updates['fontSize'] = widget.fontSize;
      }

      if (updates.isNotEmpty) {
        await authProvider.updateProfile(updates);
      }

      if (mounted) {
        // Navigate to onboarding
        context.go('/onboarding');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Account creation failed: ${e.toString()}');
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isResending = true);

    try {
      final result = await OTPService.sendOTP(
        email: widget.email,
        name: widget.name,
      );

      if (result['success'] == true) {
        _startResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend OTP: ${result['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend OTP: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Verify Email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/signup'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Text(
                      'Check Your Email',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We sent a 6-digit code to',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.email,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // OTP Input
                    TextField(
                      controller: _otpController,
                      decoration: const InputDecoration(
                        labelText: 'Enter 6-digit code',
                        hintText: '000000',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Error Message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Verify & Create Account'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Resend OTP
                    TextButton(
                      onPressed: (_resendTimer > 0 || _isResending) ? null : _resendOTP,
                      child: _isResending
                          ? const Text('Sending...')
                          : Text(
                              _resendTimer > 0
                                  ? 'Resend code in ${_resendTimer}s'
                                  : 'Didn\'t receive code? Resend',
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Back to signup
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text('Change email address'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
