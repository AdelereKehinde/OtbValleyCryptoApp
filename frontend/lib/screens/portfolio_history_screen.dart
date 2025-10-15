import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cheeseball/providers/theme_provider.dart';
import 'package:cheeseball/theme/colors.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsSettingsState();
}

class _SettingsSettingsState extends State<SettingsScreen> {
  String _selectedCurrency = 'USD';
  String _selectedLanguage = 'English';
  bool _biometricAuth = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];
  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance
          _buildSectionHeader('Appearance'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildThemeSwitch(),
                _buildSettingsItem(
                  Icons.style,
                  'App Theme',
                  'Change app appearance',
                  _changeTheme,
                ),
              ],
            ),
          ),
          // Preferences
          _buildSectionHeader('Preferences'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildSettingsItemWithDropdown(
                  Icons.attach_money,
                  'Default Currency',
                  _selectedCurrency,
                  _currencies,
                  (value) {
                    setState(() {
                      _selectedCurrency = value!;
                    });
                  },
                ),
                _buildSettingsItemWithDropdown(
                  Icons.language,
                  'Language',
                  _selectedLanguage,
                  _languages,
                  (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          // Notifications
          _buildSectionHeader('Notifications'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildSwitchSetting(
                  'Push Notifications',
                  'Receive push notifications',
                  _pushNotifications,
                  (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                ),
                _buildSwitchSetting(
                  'Email Notifications',
                  'Receive email updates',
                  _emailNotifications,
                  (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  },
                ),
                _buildSettingsItem(
                  Icons.notifications_active,
                  'Notification Settings',
                  'Configure alert types',
                  () => Navigator.pushNamed(context, '/notification-settings'),
                ),
              ],
            ),
          ),
          // Security
          _buildSectionHeader('Security'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildSwitchSetting(
                  'Biometric Authentication',
                  'Use fingerprint or face ID',
                  _biometricAuth,
                  (value) {
                    setState(() {
                      _biometricAuth = value;
                    });
                  },
                ),
                _buildSettingsItem(
                  Icons.security,
                  'Change Password',
                  'Update your password',
                  _changePassword,
                ),
                _buildSettingsItem(
                  Icons.lock,
                  'Privacy Settings',
                  'Manage data and privacy',
                  () => Navigator.pushNamed(context, '/privacy-settings'),
                ),
              ],
            ),
          ),
          // About
          _buildSectionHeader('About'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildSettingsItem(
                  Icons.star,
                  'Rate App',
                  'Rate us on app store',
                  _rateApp,
                ),
                _buildSettingsItem(
                  Icons.share,
                  'Share App',
                  'Share with friends',
                  _shareApp,
                ),
                _buildSettingsItem(
                  Icons.description,
                  'Terms of Service',
                  'View terms and conditions',
                  _viewTerms,
                ),
                _buildSettingsItem(
                  Icons.privacy_tip,
                  'Privacy Policy',
                  'View privacy policy',
                  _viewPrivacyPolicy,
                ),
                _buildSettingsItem(
                  Icons.info,
                  'About',
                  'App version and info',
                  _viewAbout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // App version
          Center(
            child: Text(
              'CheeseBall v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralGray,
                  ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildThemeSwitch() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SwitchListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text('Dark Mode'),
          subtitle: const Text('Switch between light and dark theme'),
          value: themeProvider.themeMode == ThemeMode.dark,
          onChanged: (value) {
            themeProvider.toggleTheme(value);
          },
        );
      },
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSettingsItemWithDropdown(
    IconData icon,
    String title,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildSwitchSetting(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  void _changeTheme() {
    // Already handled by theme switch
  }

  void _changePassword() {
    Navigator.pushNamed(context, '/change-password');
  }

  void _rateApp() {
    // Implement app rating
  }

  void _shareApp() {
    // Implement app sharing
  }

  void _viewTerms() {
    Navigator.pushNamed(context, '/terms');
  }

  void _viewPrivacyPolicy() {
    Navigator.pushNamed(context, '/privacy');
  }

  void _viewAbout() {
    Navigator.pushNamed(context, '/about');
  }
}