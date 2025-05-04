// Update app_router.dart
import 'package:flutter/material.dart';
import 'package:moodfit/core/navigation/routes.dart';
import 'package:moodfit/presentation/screens/auth/login_screen.dart';
import 'package:moodfit/presentation/screens/auth/register_screen.dart';
import 'package:moodfit/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:moodfit/presentation/screens/mood_selection/mood_selection_screen.dart';
import 'package:moodfit/presentation/screens/workout/workout_details_screen.dart';
import 'package:moodfit/presentation/screens/workout/quick_workout_screen.dart';
import 'package:moodfit/presentation/screens/splash_screen.dart';
import 'package:moodfit/presentation/screens/profile/profile_screen.dart';
import 'package:moodfit/presentation/screens/settings/settings_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case Routes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case Routes.moodSelection:
        return MaterialPageRoute(builder: (_) => const MoodSelectionScreen());
      case Routes.workoutDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder:
              (_) => WorkoutDetailsScreen(
                workoutId: args?['workoutId'],
                mood: args?['mood'],
              ),
        );
      case Routes.quickWorkout:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder:
              (_) => QuickWorkoutScreen(
                workoutId: args?['workoutId'],
                duration: args?['duration'],
              ),
        );
      case Routes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
