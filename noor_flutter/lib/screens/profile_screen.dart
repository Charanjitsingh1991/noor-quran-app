import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/auth_provider.dart';
import '../services/biometric_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  final List<String> _countries = [
    "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria",
    "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan",
    "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cabo Verde", "Cambodia",
    "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo, Democratic Republic of the", "Congo, Republic of the",
    "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Cyprus", "Czechia", "Denmark", "Djibouti", "Dominica", "Dominican Republic",
    "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Eswatini", "Ethiopia", "Fiji", "Finland",
    "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea",
    "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq",
    "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kosovo",
    "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania",
    "Luxembourg", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius",
    "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar", "Namibia",
    "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "North Macedonia", "Norway",
    "Oman", "Pakistan", "Palau", "Palestine State", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland",
    "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino",
    "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands",
    "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden", "Switzerland",
    "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia",
    "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States of America", "Uruguay", "Uzbekistan",
    "Vanuatu", "Vatican City", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final userProfile = authProvider.userProfile;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: userProfile?.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              userProfile!.photoURL!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 50,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    userProfile?.name ?? user?.email?.split('@')[0] ?? 'User',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  // Email
                  if (user?.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user!.email!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  // Country
                  if (userProfile?.country != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        userProfile!.country,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 32),

              // Reading Progress
              if (userProfile?.lastRead != null) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Reading Progress',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Last read: Surah ${userProfile!.lastRead!.surah}, Verse ${userProfile.lastRead!.verse}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Settings Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Font Size Setting
                      _buildSettingItem(
                        context,
                        icon: Icons.text_fields,
                        title: 'Font Size',
                        subtitle: _getFontSizeLabel(userProfile?.fontSize ?? 'md'),
                        onTap: () => _showFontSizeDialog(context, authProvider),
                      ),

                      const Divider(height: 24),

                      // Themes Setting
                      _buildSettingItem(
                        context,
                        icon: Icons.palette,
                        title: 'Themes',
                        subtitle: 'Customize app appearance',
                        onTap: () => context.go('/themes'),
                      ),

                      const Divider(height: 24),



                      // Security Settings
                      _buildSettingItem(
                        context,
                        icon: Icons.fingerprint,
                        title: 'Biometric Authentication',
                        subtitle: 'Use fingerprint or face unlock',
                        onTap: () => _showBiometricDialog(context),
                      ),

                      const Divider(height: 24),

                      _buildSettingItem(
                        context,
                        icon: Icons.pin,
                        title: 'PIN Code',
                        subtitle: 'Set up PIN for quick access',
                        onTap: () => _showPinCodeDialog(context),
                      ),

                      const Divider(height: 24),

                      // Account Settings
                      _buildSettingItem(
                        context,
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                        onTap: () => _showEditProfileDialog(context, authProvider),
                      ),

                      const Divider(height: 24),

                      // Logout
                      _buildSettingItem(
                        context,
                        icon: Icons.logout,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        onTap: () => _showLogoutDialog(context, authProvider),
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // App Info
              Text(
                'Noor Quran Companion',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDestructive
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  String _getFontSizeLabel(String fontSize) {
    switch (fontSize) {
      case 'sm':
        return 'Small';
      case 'md':
        return 'Medium';
      case 'lg':
        return 'Large';
      default:
        return 'Medium';
    }
  }

  void _showFontSizeDialog(BuildContext context, AuthProvider authProvider) {
    final currentFontSize = authProvider.userProfile?.fontSize ?? 'md';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFontSizeOption(context, 'sm', 'Small', currentFontSize),
            _buildFontSizeOption(context, 'md', 'Medium', currentFontSize),
            _buildFontSizeOption(context, 'lg', 'Large', currentFontSize),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeOption(BuildContext context, String value, String label, String currentValue) {
    final isSelected = value == currentValue;

    return InkWell(
      onTap: () async {
        Navigator.of(context).pop();
        try {
          // Update both AuthProvider and ThemeProvider
          await Provider.of<AuthProvider>(context, listen: false)
              .updateProfile({'fontSize': value});

          // Update ThemeProvider to apply font size immediately
          Provider.of<ThemeProvider>(context, listen: false).setFontSize(value);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Font size updated to $label')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating font size: $e')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController = TextEditingController(text: authProvider.userProfile?.name ?? '');
    String? selectedCountry = authProvider.userProfile?.country;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCountry,
              decoration: const InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select your country'),
              items: _countries.map((country) {
                return DropdownMenuItem(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (value) {
                selectedCountry = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a country';
                }
                return null;
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
              if (selectedCountry == null || selectedCountry!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a country')),
                );
                return;
              }

              Navigator.of(context).pop();
              try {
                await authProvider.updateProfile({
                  'name': nameController.text.trim(),
                  'country': selectedCountry,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating profile: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBiometricDialog(BuildContext context) async {
    final biometricService = BiometricService.instance;
    final isBiometricAvailable = await biometricService.isBiometricAvailable();
    final isBiometricEnabled = await biometricService.isBiometricEnabled();

    if (!isBiometricAvailable) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Biometric Not Available'),
          content: const Text('Biometric authentication is not available on this device.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final availableBiometrics = await biometricService.getAvailableBiometrics();
    String biometricType = 'biometric';
    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      biometricType = 'fingerprint';
    } else if (availableBiometrics.contains(BiometricType.face)) {
      biometricType = 'face';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isBiometricEnabled ? 'Disable' : 'Enable'} Biometric Authentication'),
        content: Text(
          isBiometricEnabled
              ? 'Disable biometric authentication for this app?'
              : 'Enable $biometricType authentication for quick access to the app?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              if (!isBiometricEnabled) {
                // Enable biometric - first authenticate to verify
                final authenticated = await biometricService.authenticateWithBiometrics(
                  'Verify your $biometricType to enable biometric authentication',
                );

                if (authenticated) {
                  await biometricService.saveBiometricEnabled(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Biometric authentication enabled')),
                  );
                }
              } else {
                // Disable biometric
                await biometricService.saveBiometricEnabled(false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Biometric authentication disabled')),
                );
              }
            },
            child: Text(isBiometricEnabled ? 'Disable' : 'Enable'),
          ),
        ],
      ),
    );
  }

  void _showPinCodeDialog(BuildContext context) async {
    final biometricService = BiometricService.instance;
    final existingPin = await biometricService.getPinCode();
    final hasPin = existingPin != null && existingPin.isNotEmpty;

    if (hasPin) {
      // Show options to change or delete PIN
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('PIN Code Options'),
          content: const Text('What would you like to do with your PIN code?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showChangePinDialog(context);
              },
              child: const Text('Change PIN'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await biometricService.deletePinCode();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN code deleted')),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete PIN'),
            ),
          ],
        ),
      );
    } else {
      // Show create PIN dialog
      _showCreatePinDialog(context);
    }
  }

  void _showCreatePinDialog(BuildContext context) {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create PIN Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              decoration: const InputDecoration(
                labelText: 'Enter PIN (4-6 digits)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              decoration: const InputDecoration(
                labelText: 'Confirm PIN',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final pin = pinController.text.trim();
              final confirmPin = confirmPinController.text.trim();

              if (pin.length < 4 || pin.length > 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN must be 4-6 digits')),
                );
                return;
              }

              if (pin != confirmPin) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN codes do not match')),
                );
                return;
              }

              Navigator.of(context).pop();
              await BiometricService.instance.savePinCode(pin);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN code created successfully')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog(BuildContext context) async {
    final biometricService = BiometricService.instance;
    final currentPin = await biometricService.getPinCode();

    if (currentPin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No existing PIN found')),
      );
      return;
    }

    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change PIN Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPinController,
              decoration: const InputDecoration(
                labelText: 'Current PIN',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPinController,
              decoration: const InputDecoration(
                labelText: 'New PIN (4-6 digits)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              decoration: const InputDecoration(
                labelText: 'Confirm New PIN',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final enteredCurrentPin = currentPinController.text.trim();
              final newPin = newPinController.text.trim();
              final confirmPin = confirmPinController.text.trim();

              if (enteredCurrentPin != currentPin) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Current PIN is incorrect')),
                );
                return;
              }

              if (newPin.length < 4 || newPin.length > 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New PIN must be 4-6 digits')),
                );
                return;
              }

              if (newPin != confirmPin) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New PIN codes do not match')),
                );
                return;
              }

              Navigator.of(context).pop();
              await biometricService.savePinCode(newPin);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN code changed successfully')),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await authProvider.signOut();
                context.go('/login');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $e')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
