// lib/utils/signup_handler.dart - Handles sign-up flow tracking
import 'package:flutter/material.dart';
import 'package:moodfit/screens/main/mood_selection_screen.dart';
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

  // Handle redirection for new user
  static Future<Widget> checkRedirection(BuildContext context) async {
    final isSignup = await isSignupActive();
    debugPrint(
        'SignupHandler: Checking redirection, isSignupActive = $isSignup');

    if (isSignup) {
      await clearSignupActive();
      return const MoodSelectionScreen(isInitialSetup: true);
    }

    return Container(); // Return empty container if no redirection needed
  }
}
