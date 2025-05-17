// lib/utils/signup_handler.dart - Handles sign-up flow tracking
import 'package:flutter/material.dart';
import 'package:moodfit/providers/auth_provider.dart' as app_auth;
import 'package:moodfit/screens/main/mood_selection_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupHandler {
  static const String _signupProcessKey = 'signup_process_active';

  // Mark signup process as active
  static Future<void> markSignupActive() async {
    debugPrint('SignupHandler: Marking signup process as active');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signupProcessKey, true);
  }

  // Check if signup process is active
  static Future<bool> isSignupActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_signupProcessKey) ?? false;
  }

  // Clear signup process
  static Future<void> clearSignupActive() async {
    debugPrint('SignupHandler: Clearing signup process');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_signupProcessKey);
  }

  // Check and clear if user is not authenticated but flag is set
  static Future<void> clearIfNotAuthenticated(BuildContext context) async {
    final authProvider =
        Provider.of<app_auth.AuthProvider>(context, listen: false);
    final isActive = await isSignupActive();

    // If signup flag is active but user is not authenticated, clear it
    if (isActive && !authProvider.isAuthenticated) {
      debugPrint(
          'SignupHandler: Clearing stale signup flag because user is not authenticated');
      await clearSignupActive();
    }
  }

  // Handle redirection for new user
  static Future<Widget> checkRedirection(BuildContext context) async {
    // First check if we need to clear stale flags
    await clearIfNotAuthenticated(context);

    final authProvider =
        // ignore: use_build_context_synchronously
        Provider.of<app_auth.AuthProvider>(context, listen: false);
    final isSignup = await isSignupActive();

    debugPrint(
        'SignupHandler: Checking redirection, isSignupActive = $isSignup, isAuthenticated = ${authProvider.isAuthenticated}');

    // Only redirect if both conditions are true
    if (isSignup && authProvider.isAuthenticated) {
      await clearSignupActive();
      return const MoodSelectionScreen(isInitialSetup: true);
    }

    return Container(); // Return empty container if no redirection needed
  }
}
