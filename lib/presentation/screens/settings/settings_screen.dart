// lib/presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:moodfit/core/navigation/routes.dart';
import 'package:moodfit/presentation/common/breadcrumb.dart';
import 'package:moodfit/providers/auth_provider.dart';
import 'package:provider/provider.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // To balance the appbar
                ],
              ),
            ),

            // Breadcrumb
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Breadcrumb(
                items: const [
                  BreadcrumbItem(label: 'Home'),
                  BreadcrumbItem(label: 'Settings', isActive: true),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Section
                      _buildSectionHeader('Account'),
                      _buildSettingItem(
                        'Profile',
                        Icons.person,
                        onTap:
                            () =>
                                Navigator.of(context).pushNamed(Routes.profile),
                      ),
                      const Divider(),
                      _buildSettingItem(
                        'Change Password',
                        Icons.lock,
                        onTap: () {
                          // Navigate to change password screen
                        },
                      ),
                      const Divider(),
                      _buildSettingItem(
                        'Logout',
                        Icons.logout,
                        textColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () async {
                          await authProvider.signOut();
                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed(Routes.login);
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // Preferences Section
                      _buildSectionHeader('Preferences'),
                      SwitchListTile(
                        title: const Text('Notifications'),
                        secondary: const Icon(Icons.notifications),
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        secondary: const Icon(Icons.dark_mode),
                        value: _darkModeEnabled,
                        onChanged: (value) {
                          setState(() {
                            _darkModeEnabled = value;
                          });
                        },
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Language'),
                        subtitle: Text(_selectedLanguage),
                        leading: const Icon(Icons.language),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _showLanguageDialog,
                      ),

                      const SizedBox(height: 24),

                      // About Section
                      _buildSectionHeader('About'),
                      _buildSettingItem(
                        'App Version',
                        Icons.info,
                        subtitle: '1.0.0',
                      ),
                      const Divider(),
                      _buildSettingItem(
                        'Terms of Service',
                        Icons.description,
                        onTap: () {
                          // Navigate to terms screen
                        },
                      ),
                      const Divider(),
                      _buildSettingItem(
                        'Privacy Policy',
                        Icons.privacy_tip,
                        onTap: () {
                          // Navigate to privacy policy screen
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption('English'),
                _buildLanguageOption('Spanish'),
                _buildLanguageOption('French'),
                _buildLanguageOption('German'),
              ],
            ),
          ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language),
      trailing:
          _selectedLanguage == language
              ? Icon(Icons.check, color: Theme.of(context).primaryColor)
              : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon, {
    String? subtitle,
    Color? textColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      leading: Icon(icon, color: iconColor),
      trailing:
          onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }
}
