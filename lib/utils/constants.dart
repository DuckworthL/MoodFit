// lib/utils/constants.dart - App-wide constant values
import 'package:moodfit/models/mood_model.dart';
import 'package:moodfit/models/workout_model.dart';

class AppConstants {
  // Application Info
  static const String appName = 'MoodFit';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String moodsCollection = 'moods';
  static const String workoutsCollection = 'workouts';
  static const String progressCollection = 'workout_progress';

  // Shared Preferences Keys
  static const String themePrefKey = 'isDarkMode';
  static const String onboardingCompletedKey = 'onboardingCompleted';
  static const String userIdKey = 'userId';

  // Demo Account
  static const String demoEmail = 'demo@moodfit.com';
  static const String demoPassword = 'MoodFit2025';

  // Mood Descriptions
  static Map<MoodType, String> moodDescriptions = {
    MoodType.energetic:
        'Full of energy and ready to tackle challenging workouts',
    MoodType.happy:
        'Feeling positive and ready for moderate-intensity exercises',
    MoodType.calm: 'Relaxed and looking for balanced, steady movements',
    MoodType.tired:
        'Low energy, best for gentle stretches and mindful movement',
    MoodType.stressed:
        'Need stress-relief through focused breathing and moderate movement',
    MoodType.sad: 'Looking for mood-lifting exercises with gradual intensity',
  };

  // Predefined Workouts
  static List<WorkoutModel> getPredefinedWorkouts() {
    // This would be pre-populated in a real app
    return [];
  }

  // Helper Methods
  static List<Exercise> createQuickExerciseList(MoodType mood) {
    // Create a mood-appropriate quick workout (5-10 minutes)
    List<Exercise> exercises = [];

    switch (mood) {
      case MoodType.energetic:
        exercises = [
          Exercise(
            name: 'Jumping Jacks',
            description: 'Full body exercise to get your heart pumping',
            imageAsset: 'assets/icons/jump_rope.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'High Knees',
            description: 'Run in place while bringing your knees up high',
            imageAsset: 'assets/icons/jump_rope.png',
            durationSeconds: 45,
          ),
          Exercise(
            name: 'Quick Rest',
            description: 'Take a short break and breathe',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 20,
            isRest: true,
          ),
          Exercise(
            name: 'Mountain Climbers',
            description: 'Engage your core while moving your legs quickly',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Burpees',
            description: 'Full body movement for maximum energy expenditure',
            imageAsset: 'assets/icons/dumbell.png',
            durationSeconds: 45,
          ),
          Exercise(
            name: 'Quick Rest',
            description: 'Take a short break and breathe',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 20,
            isRest: true,
          ),
          Exercise(
            name: 'Speed Skaters',
            description: 'Lateral jumps to work your legs and coordination',
            imageAsset: 'assets/icons/jump_rope.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Cool Down',
            description: 'Gentle stretches to finish your workout',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
        ];
        break;

      case MoodType.happy:
        exercises = [
          Exercise(
            name: 'Dancing Warm-up',
            description: 'Move to your favorite beat to warm up',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Squats with Arm Raises',
            description: 'Combine lower and upper body movements',
            imageAsset: 'assets/icons/dumbell.png',
            durationSeconds: 45,
          ),
          Exercise(
            name: 'Quick Rest',
            description: 'Take a short break and breathe',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 20,
            isRest: true,
          ),
          Exercise(
            name: 'Standing Side Crunches',
            description: 'Work your obliques while standing',
            imageAsset: 'assets/icons/dumbell.png',
            durationSeconds: 45,
          ),
          Exercise(
            name: 'Star Jumps',
            description: 'Jump while extending your arms and legs',
            imageAsset: 'assets/icons/jump_rope.png',
            durationSeconds: 45,
          ),
          Exercise(
            name: 'Quick Rest',
            description: 'Take a short break and breathe',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 20,
            isRest: true,
          ),
          Exercise(
            name: 'Standing Knee to Elbow',
            description: 'Connect opposite knee to elbow, alternating sides',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 45,
          ),
          Exercise(
            name: 'Cool Down',
            description: 'Gentle stretches to finish your workout',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
        ];
        break;

      // Other mood-based workouts would be defined similarly
      default:
        exercises = [
          Exercise(
            name: 'Deep Breathing',
            description: 'Focus on your breath to center yourself',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Gentle Stretches',
            description: 'Easy movements to improve flexibility',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Walking in Place',
            description: 'Simple movement to get your blood flowing',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Shoulder Rolls',
            description: 'Release tension in your upper body',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 45,
          ),
          Exercise(
            name: 'Mindful Moment',
            description: 'Take time to reconnect with your body',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
        ];
    }

    return exercises;
  }
}
