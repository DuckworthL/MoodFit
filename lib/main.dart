// lib/main.dart - Main application entry point
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moodfit/firebase_options.dart';
import 'package:moodfit/providers/auth_provider.dart' as app_auth;
import 'package:moodfit/providers/mood_provider.dart';
import 'package:moodfit/providers/progress_provider.dart';
import 'package:moodfit/providers/workout_provider.dart';
import 'package:moodfit/screens/main/mood_selection_screen.dart';
import 'package:moodfit/screens/splash_screen.dart';
import 'package:moodfit/utils/signup_handler.dart';
import 'package:moodfit/utils/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Add auth state listener for debugging
  firebase_auth.FirebaseAuth.instance
      .authStateChanges()
      .listen((firebase_auth.User? user) {
    if (user != null) {
      debugPrint('AUTH STATE CHANGE: User is signed in with UID: ${user.uid}');
    } else {
      debugPrint('AUTH STATE CHANGE: User is signed out');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<app_auth.AuthProvider>(
          create: (_) => app_auth.AuthProvider(),
        ),
        ChangeNotifierProvider<MoodProvider>(
          create: (_) => MoodProvider(),
        ),
        ChangeNotifierProvider<WorkoutProvider>(
          create: (_) => WorkoutProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<ProgressProvider>(
          create: (_) => ProgressProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'MoodFit',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.getCurrentTheme(),
            home: const SplashScreenWithRedirection(),
          );
        },
      ),
    );
  }
}

// New splash screen that handles redirection
class SplashScreenWithRedirection extends StatefulWidget {
  const SplashScreenWithRedirection({Key? key}) : super(key: key);

  @override
  State<SplashScreenWithRedirection> createState() =>
      _SplashScreenWithRedirectionState();
}

class _SplashScreenWithRedirectionState
    extends State<SplashScreenWithRedirection> {
  @override
  void initState() {
    super.initState();
    _checkSignupRedirection();
  }

  Future<void> _checkSignupRedirection() async {
    final authProvider =
        Provider.of<app_auth.AuthProvider>(context, listen: false);
    final isSignupActive = await SignupHandler.isSignupActive();

    debugPrint(
        'Splash: Checking signup redirection, isSignupActive = $isSignupActive, isAuthenticated = ${authProvider.isAuthenticated}');

    // Only redirect to mood selection if BOTH conditions are true:
    // 1. Signup is active (indicating a new registration)
    // 2. User is authenticated (user has actually logged in)
    if (isSignupActive && authProvider.isAuthenticated && mounted) {
      // If signup is active and user is authenticated, navigate to mood selection
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  const MoodSelectionScreen(isInitialSetup: true),
            ),
          );
        }
      });
    } else if (isSignupActive && !authProvider.isAuthenticated) {
      // Clear the signup flag if it's set but user is not authenticated
      debugPrint(
          'Clearing stale signup flag because user is not authenticated');
      await SignupHandler.clearSignupActive();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
