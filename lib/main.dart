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
    final isSignupActive = await SignupHandler.isSignupActive();
    debugPrint(
        'Splash: Checking signup redirection, isSignupActive = $isSignupActive');

    if (isSignupActive && mounted) {
      // If signup is active, navigate to mood selection after a short delay
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
