// lib/presentation/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:moodfit/presentation/common/app_button.dart';
import 'package:moodfit/presentation/common/app_text_field.dart';
import 'package:moodfit/presentation/common/breadcrumb.dart';
import 'package:moodfit/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(
      text: authProvider.user?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controller if canceling edit
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        _nameController.text = authProvider.user?.displayName ?? '';
      }
    });
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateProfile(
        displayName: _nameController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isEditing = false;
        });
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

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
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
                    onPressed: _toggleEdit,
                  ),
                ],
              ),
            ),

            // Breadcrumb
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Breadcrumb(
                items: const [
                  BreadcrumbItem(label: 'Home'),
                  BreadcrumbItem(label: 'Profile', isActive: true),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage:
                            user?.photoUrl != null
                                ? NetworkImage(user!.photoUrl!)
                                : null,
                        child:
                            user?.photoUrl == null
                                ? Text(
                                  user?.displayName?.substring(0, 1) ?? 'U',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                                : null,
                      ),
                      const SizedBox(height: 24),

                      // Profile Fields
                      if (_isEditing) ...[
                        AppTextField(
                          label: 'Full Name',
                          controller: _nameController,
                          enabled: _isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        AppButton(
                          text: 'Save Changes',
                          isLoading: authProvider.isLoading,
                          onPressed: _saveProfile,
                        ),
                      ] else ...[
                        // Display only mode
                        _buildProfileInfo(
                          'Full Name',
                          user?.displayName ?? 'Not set',
                        ),
                        _buildProfileInfo('Email', user?.email ?? 'Not set'),
                        _buildProfileInfo(
                          'Member Since',
                          _formatDate(user?.createdAt),
                        ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        // Stats
                        const Text(
                          'Activity Stats',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              context,
                              Icons.fitness_center,
                              '0',
                              'Workouts',
                            ),
                            _buildStatCard(
                              context,
                              Icons.timer,
                              '0',
                              'Minutes',
                            ),
                            _buildStatCard(
                              context,
                              Icons.calendar_today,
                              '0',
                              'Days',
                            ),
                          ],
                        ),
                      ],

                      // Error message
                      if (authProvider.error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          authProvider.error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not available';
    return '${date.day}/${date.month}/${date.year}';
  }
}
