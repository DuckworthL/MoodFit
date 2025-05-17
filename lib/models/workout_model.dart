// lib/models/workout_model.dart - Workout data model for exercise routines
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moodfit/models/mood_model.dart';

class Exercise {
  final String name;
  final String description;
  final String imageAsset;
  final int durationSeconds;
  final bool isRest;

  Exercise({
    required this.name,
    required this.description,
    required this.imageAsset,
    required this.durationSeconds,
    this.isRest = false,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      description: json['description'],
      imageAsset: json['imageAsset'],
      durationSeconds: json['durationSeconds'],
      isRest: json['isRest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageAsset': imageAsset,
      'durationSeconds': durationSeconds,
      'isRest': isRest,
    };
  }
}

class WorkoutModel {
  final String id;
  final String name;
  final String description;
  final List<Exercise> exercises;
  final MoodType recommendedMood;
  final int energyLevelRequired; // 1-10
  final int totalDurationMinutes;
  final String backgroundImage;
  final String? createdBy; // userId or 'system' for pre-defined workouts
  final String type; // Added to fix missing getter
  final int difficulty; // Added to fix missing getter
  final String imageAsset; // Added to fix missing getter

  WorkoutModel({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.recommendedMood,
    required this.energyLevelRequired,
    required this.totalDurationMinutes,
    required this.backgroundImage,
    this.createdBy,
    this.type = 'general', // Default value
    this.difficulty = 5, // Default value (1-10)
    this.imageAsset = 'assets/backgrounds/workout_bg.jpg', // Default value
  });

  factory WorkoutModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<Exercise> exerciseList = [];
    if (data['exercises'] != null) {
      for (var ex in data['exercises']) {
        exerciseList.add(Exercise.fromJson(ex));
      }
    }

    return WorkoutModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      exercises: exerciseList,
      recommendedMood: MoodType.values.firstWhere(
        (e) => e.toString() == 'MoodType.${data['recommendedMood']}',
        orElse: () => MoodType.calm,
      ),
      energyLevelRequired: data['energyLevelRequired'] ?? 5,
      totalDurationMinutes: data['totalDurationMinutes'] ?? 0,
      backgroundImage:
          data['backgroundImage'] ?? 'assets/backgrounds/workout_bg.jpg',
      createdBy: data['createdBy'],
      type: data['type'] ?? 'general', // Parse from data
      difficulty: data['difficulty'] ?? 5, // Parse from data
      imageAsset: data['imageAsset'] ??
          'assets/backgrounds/workout_bg.jpg', // Parse from data
    );
  }

  int get durationMinutes =>
      totalDurationMinutes; // Changed to properly return value

  String? get userId => createdBy; // Fixed to return the correct value

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'recommendedMood': recommendedMood.toString().split('.').last,
      'energyLevelRequired': energyLevelRequired,
      'totalDurationMinutes': totalDurationMinutes,
      'backgroundImage': backgroundImage,
      'createdBy': createdBy,
      'type': type, // Added to JSON
      'difficulty': difficulty, // Added to JSON
      'imageAsset': imageAsset, // Added to JSON
    };
  }

  bool isQuickWorkout() {
    return totalDurationMinutes <= 10;
  }
}
