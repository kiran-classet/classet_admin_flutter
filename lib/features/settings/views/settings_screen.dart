import 'package:classet_admin/features/help_center/views/help_center_screen.dart';
import 'package:classet_admin/features/profile/views/privacy_policy_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = true;
  bool _darkMode = false;
  final String _selectedLanguage = 'English';
  final double _textSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 80.0,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),
                _buildNotificationSettings(),
                const SizedBox(height: 20),
                // _buildAppearanceSettings(),
                // const SizedBox(height: 20),
                // _buildAccountSettings(),
                // const SizedBox(height: 20),
                // _buildSecuritySettings(),
                const SizedBox(height: 20),
                _buildAboutSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSectionTitle('Notifications'),
          ),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive email updates'),
            value: _emailNotifications,
            onChanged: _notificationsEnabled
                ? (bool value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  }
                : null,
          ),
          SwitchListTile(
            title: const Text('SMS Notifications'),
            subtitle: const Text('Receive SMS alerts'),
            value: _smsNotifications,
            onChanged: _notificationsEnabled
                ? (bool value) {
                    setState(() {
                      _smsNotifications = value;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings() {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSectionTitle('Appearance'),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: _darkMode,
            onChanged: (bool value) {
              setState(() {
                _darkMode = value;
              });
            },
          ),
          // ListTile(
          //   title: const Text('Text Size'),
          //   subtitle: Slider(
          //     value: _textSize,
          //     min: 12.0,
          //     max: 24.0,
          //     divisions: 4,
          //     label: _textSize.round().toString(),
          //     onChanged: (double value) {
          //       setState(() {
          //         _textSize = value;
          //       });
          //     },
          //   ),
          // ),
          // ListTile(
          //   title: const Text('Language'),
          //   subtitle: DropdownButton<String>(
          //     value: _selectedLanguage,
          //     isExpanded: true,
          //     onChanged: (String? newValue) {
          //       if (newValue != null) {
          //         setState(() {
          //           _selectedLanguage = newValue;
          //         });
          //       }
          //     },
          //     items: <String>['English', 'Hindi', 'Spanish', 'French']
          //         .map<DropdownMenuItem<String>>((String value) {
          //       return DropdownMenuItem<String>(
          //         value: value,
          //         child: Text(value),
          //       );
          //     }).toList(),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSectionTitle('Account'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile Settings'),
            subtitle: const Text('Update your personal information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to profile settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email Address'),
            subtitle: const Text('Change your email address'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to email settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Phone Number'),
            subtitle: const Text('Update your contact number'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to phone settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSectionTitle('Security'),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            subtitle: const Text('Update your password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to password change
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Add extra security to your account'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to 2FA settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Settings'),
            subtitle: const Text('Manage your privacy preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to privacy settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSectionTitle('About'),
          ),
          // ListTile(
          //   leading: const Icon(Icons.info),
          //   title: const Text('App Information'),
          //   subtitle: const Text('Version 1.0.0'),
          //   trailing: const Icon(Icons.chevron_right),
          //   onTap: () {
          //     // TODO: Show app info
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.description),
          //   title: const Text('Terms of Service'),
          //   trailing: const Icon(Icons.chevron_right),
          //   onTap: () {
          //     // TODO: Show terms of service
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PrivacyPolicyScreen(), // Replace with your PrivacyPolicyScreen widget
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HelpCenterScreen(), // Replace with your HelpSupportScreen widget
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
