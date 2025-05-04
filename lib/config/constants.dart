// lib/config/constants.dart - App constants

class AppConstants {
  // App Info
  static const String appName = 'MoodFit';
  static const String appTagline = 'Fitness for every mood';
  static const String appVersion = '1.0.0';

  // Mood Intensity Levels
  static const List<String> intensityLevels = ['Low', 'Medium', 'High'];

  // Workout Types
  static const List<String> workoutTypes = [
    'HIIT',
    'Yoga',
    'Dance',
    'Strength',
    'Cardio',
    'Meditation',
    'Stretching',
  ];

  // Animation Durations
  static const int shortAnimationDuration = 200; // milliseconds
  static const int mediumAnimationDuration = 400; // milliseconds
  static const int longAnimationDuration = 800; // milliseconds

  // Default Rest Time
  static const int defaultRestTime = 30; // seconds

  // Error Messages
  static const String networkErrorMessage =
      'Network connection issue. Please check your internet connection and try again.';
  static const String generalErrorMessage =
      'Something went wrong. Please try again later.';
  static const String authErrorMessage =
      'Authentication error. Please try again.';

  // Success Messages
  static const String workoutCompletedMessage =
      'Workout completed successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';

  // Default Values
  static const int defaultWorkoutDuration = 30; // minutes
  static const int minQuickWorkoutDuration = 5; // minutes
  static const int maxQuickWorkoutDuration = 15; // minutes
}
