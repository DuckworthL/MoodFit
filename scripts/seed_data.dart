// scripts/seed_data.dart - Script to seed initial workout data into Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:moodfit/firebase_options.dart';
import 'package:moodfit/models/mood_model.dart';
import 'package:moodfit/models/workout_model.dart';
import 'package:moodfit/utils/constants.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Seed sample workouts
  for (var moodType in MoodType.values) {
    // Create quick workout
    final Exercise rest = Exercise(
      name: 'Quick Rest',
      description: 'Take a short break and breathe',
      imageAsset: 'assets/icons/yoga_mat.png',
      durationSeconds: 20,
      isRest: true,
    );

    // Create specific exercises based on mood
    List<Exercise> exercises = [];
    String workoutName = '';
    String workoutDescription = '';
    String backgroundImage = '';
    int energyLevel = 5;

    switch (moodType) {
      case MoodType.energetic:
        workoutName = 'Power Burst';
        workoutDescription =
            'A high-intensity workout for when you have lots of energy';
        backgroundImage = 'assets/backgrounds/strength_bg.jpg';
        energyLevel = 8;
        exercises = [
          Exercise(
            name: 'Jumping Jacks',
            description: 'Full body exercise to get your heart pumping',
            imageAsset: 'assets/icons/jump_rope.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Mountain Climbers',
            description:
                'Dynamic exercise engaging your core and cardiovascular system',
            imageAsset: 'assets/icons/dumbell.png',
            durationSeconds: 45,
          ),
          rest,
          Exercise(
            name: 'Burpees',
            description:
                'Full body exercise combining a squat, plank, and jump',
            imageAsset: 'assets/icons/kettlebell.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'High Knees',
            description:
                'Running in place while bringing knees to chest height',
            imageAsset: 'assets/icons/jump_rope.png',
            durationSeconds: 45,
          ),
          rest,
          Exercise(
            name: 'Speed Skaters',
            description: 'Lateral jumps from side to side',
            imageAsset: 'assets/icons/jump_rope.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Cool Down Stretches',
            description: 'Gentle stretches to lower heart rate',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
        ];
        break;

      case MoodType.happy:
        workoutName = 'Joy Boost';
        workoutDescription = 'A fun workout to maintain your positive mood';
        backgroundImage = 'assets/backgrounds/dance_bg.jpg';
        energyLevel = 6;
        exercises = [
          Exercise(
            name: 'Dance Warm-up',
            description: 'Free movement to your favorite upbeat song',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Star Jumps',
            description: 'Jump with arms and legs extended like a star',
            imageAsset: 'assets/icons/jump_rope.png',
            durationSeconds: 45,
          ),
          rest,
          Exercise(
            name: 'Squat with Arm Raise',
            description: 'Squat down and raise arms overhead as you stand',
            imageAsset: 'assets/icons/dumbell.png',
            durationSeconds: 60,
          ),
          rest,
          Exercise(
            name: 'Joyful Stretches',
            description: 'Stretching while focusing on gratitude',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
        ];
        break;

      case MoodType.calm:
        workoutName = 'Mindful Movement';
        workoutDescription = 'Gentle exercises to maintain your calm state';
        backgroundImage = 'assets/backgrounds/meditation_bg.jpg';
        energyLevel = 4;
        exercises = [
          Exercise(
            name: 'Deep Breathing',
            description: '4-7-8 breathing technique for mindfulness',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Gentle Stretching',
            description: 'Slow, controlled stretches for the whole body',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 90,
          ),
          Exercise(
            name: 'Standing Forward Bend',
            description:
                'Bend forward from your waist with knees slightly bent',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Mindful Walking',
            description: 'Walk slowly in place with attention to each step',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
        ];
        break;

      case MoodType.tired:
        workoutName = 'Gentle Energizer';
        workoutDescription = 'Light exercises to boost energy when tired';
        backgroundImage = 'assets/backgrounds/relaxation_bg.jpg';
        energyLevel = 3;
        exercises = [
          Exercise(
            name: 'Neck and Shoulder Rolls',
            description: 'Gentle mobility exercises to release tension',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 45,
          ),
          Exercise(
            name: 'Torso Twists',
            description: 'Standing twists to wake up your spine',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 45,
          ),
          rest,
          Exercise(
            name: 'Arm Circles',
            description: 'Small to large circles with your arms',
            imageAsset: 'assets/icons/dumbell.png',
            durationSeconds: 45,
          ),
          Exercise(
            name: 'Knee Lifts',
            description: 'Gentle knee raises to get blood flowing',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 45,
          ),
          Exercise(
            name: 'Energy Breathing',
            description: 'Quick inhalations and full exhalations',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
        ];
        break;

      case MoodType.stressed:
        workoutName = 'Stress Relief';
        workoutDescription =
            'Exercises focused on releasing tension and anxiety';
        backgroundImage = 'assets/backgrounds/yoga_bg.jpg';
        energyLevel = 5;
        exercises = [
          Exercise(
            name: 'Deep Belly Breathing',
            description: 'Slow deep breaths focusing on your diaphragm',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Child\'s Pose',
            description: 'Relaxing forward fold from kneeling position',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Cat-Cow Stretch',
            description: 'Alternating between arching and rounding your back',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Standing Forward Fold',
            description: 'Bend forward letting head and arms hang down',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 45,
          ),
          rest,
          Exercise(
            name: 'Tension Release Shaking',
            description:
                'Shake out arms, legs and whole body to release tension',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 45,
          ),
          Exercise(
            name: 'Final Relaxation',
            description: 'Lie down and scan your body for tension release',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
        ];
        break;

      case MoodType.sad:
        workoutName = 'Mood Elevator';
        workoutDescription = 'Gentle exercises to lift your spirits';
        backgroundImage = 'assets/backgrounds/walking_bg.jpg';
        energyLevel = 4;
        exercises = [
          Exercise(
            name: 'Gentle Marching',
            description: 'March in place at a comfortable pace',
            imageAsset: 'assets/icons/jump_rope.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Arm Swings',
            description: 'Swing arms side to side and front to back',
            imageAsset: 'assets/icons/dumbell.png',
            durationSeconds: 45,
          ),
          rest,
          Exercise(
            name: 'Standing Side Stretch',
            description: 'Reach arms overhead and lean side to side',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
          Exercise(
            name: 'Gentle Squats',
            description: 'Partial squats with focus on breath',
            imageAsset: 'assets/icons/kettlebell.png',
            durationSeconds: 45,
          ),
          Exercise(
            name: 'Happy Thoughts Meditation',
            description: 'Focus on positive memories while breathing deeply',
            imageAsset: 'assets/icons/yoga_mat.png',
            durationSeconds: 60,
          ),
        ];
        break;
    }

    // Calculate total duration in minutes
    int totalDurationSeconds =
        // ignore: avoid_types_as_parameter_names
        exercises.fold(0, (sum, exercise) => sum + exercise.durationSeconds);
    int totalDurationMinutes = (totalDurationSeconds / 60).ceil();

    // Create workout document
    WorkoutModel workout = WorkoutModel(
      id: 'system_${moodType.toString().split('.').last.toLowerCase()}',
      name: workoutName,
      description: workoutDescription,
      exercises: exercises,
      recommendedMood: moodType,
      energyLevelRequired: energyLevel,
      totalDurationMinutes: totalDurationMinutes,
      backgroundImage: backgroundImage,
      createdBy: 'system',
    );

    // Add to Firestore
    await firestore
        .collection('workouts')
        .doc(workout.id)
        .set(workout.toJson());
    if (kDebugMode) {
      print(
        'Added workout: ${workout.name} for mood: ${moodType.toString().split('.').last}');
    }
  }

  // Create demo user if it doesn't exist
  try {
    await firestore.collection('users').doc('demo_user').set({
      'email': AppConstants.demoEmail,
      'name': 'Demo User',
      'createdAt': Timestamp.now(),
      'profilePicUrl': null,
      'preferences': {},
    });
    if (kDebugMode) {
      print('Demo user created or updated');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error creating demo user: $e');
    }
  }

  if (kDebugMode) {
    print('Seeding complete!');
  }
}
