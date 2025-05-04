// lib/app.dart - Main app widget and configuration

import 'package:flutter/material.dart';
import 'package:moodfit/config/theme.dart';
import 'package:moodfit/core/navigation/app_router.dart';
import 'package:moodfit/core/navigation/routes.dart'; // Make sure this import is included
import 'package:provider/provider.dart';
import 'package:moodfit/providers/auth_provider.dart';
import 'package:moodfit/providers/mood_provider.dart';
import 'package:moodfit/providers/workout_provider.dart';

class MoodFitApp extends StatelessWidget {
  const MoodFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
      ],
      child: MaterialApp(
        title: 'MoodFit',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: Routes.splash,
      ),
    );
  }
}
