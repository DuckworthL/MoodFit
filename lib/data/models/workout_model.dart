// lib/data/models/workout_model.dart - Workout data model

class WorkoutModel {
  final String id;
  final String name;
  final String description;
  final String type; // e.g., HIIT, yoga, strength, cardio
  final String intensity; // low, medium, high
  final int duration; // in minutes
  final String imageUrl;
  final List<ExerciseModel> exercises;
  final List<String> moodIds; // which moods this workout is good for
  final bool isQuickWorkout;
  final DateTime createdAt;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.intensity,
    required this.duration,
    required this.imageUrl,
    required this.exercises,
    required this.moodIds,
    this.isQuickWorkout = false,
    required this.createdAt,
  });

  // Convert WorkoutModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'intensity': intensity,
      'duration': duration,
      'imageUrl': imageUrl,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'moodIds': moodIds,
      'isQuickWorkout': isQuickWorkout,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create WorkoutModel from JSON
  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      intensity: json['intensity'],
      duration: json['duration'],
      imageUrl: json['imageUrl'],
      exercises:
          (json['exercises'] as List)
              .map((e) => ExerciseModel.fromJson(e))
              .toList(),
      moodIds: List<String>.from(json['moodIds']),
      isQuickWorkout: json['isQuickWorkout'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ExerciseModel {
  final String id;
  final String name;
  final String description;
  final int durationSeconds; // duration in seconds
  final int sets;
  final int? repetitions; // can be null for timed exercises
  final String? imageUrl;
  final String? videoUrl;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.durationSeconds,
    required this.sets,
    this.repetitions,
    this.imageUrl,
    this.videoUrl,
  });

  // Convert ExerciseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'durationSeconds': durationSeconds,
      'sets': sets,
      'repetitions': repetitions,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
    };
  }

  // Create ExerciseModel from JSON
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      durationSeconds: json['durationSeconds'],
      sets: json['sets'],
      repetitions: json['repetitions'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
    );
  }
}

// Mock workout data
List<WorkoutModel> getMockWorkouts() {
  return [
    WorkoutModel(
      id: '1',
      name: 'High Energy HIIT',
      description: 'An intense workout to burn energy and boost your mood',
      type: 'HIIT',
      intensity: 'high',
      duration: 30,
      imageUrl: 'assets/backgrounds/hiit_bg.jpg',
      exercises: [
        ExerciseModel(
          id: '1',
          name: 'Jumping Jacks',
          description: 'Traditional jumping jacks to warm up',
          durationSeconds: 45,
          sets: 1,
          repetitions: null,
        ),
        ExerciseModel(
          id: '2',
          name: 'Push-ups',
          description: 'Standard push-ups, modify as needed',
          durationSeconds: 30,
          sets: 3,
          repetitions: 10,
        ),
        ExerciseModel(
          id: '3',
          name: 'Mountain Climbers',
          description: 'Quick-paced mountain climbers',
          durationSeconds: 45,
          sets: 3,
          repetitions: null,
        ),
        ExerciseModel(
          id: '4',
          name: 'Burpees',
          description: 'Full burpees with push-up',
          durationSeconds: 30,
          sets: 3,
          repetitions: 10,
        ),
        ExerciseModel(
          id: '5',
          name: 'Rest',
          description: 'Take a short break',
          durationSeconds: 30,
          sets: 3,
          repetitions: null,
        ),
      ],
      moodIds: ['1', '5'], // Energetic, Stressed
      createdAt: DateTime.now(),
    ),
    WorkoutModel(
      id: '2',
      name: 'Calming Yoga Flow',
      description: 'A gentle sequence to relax your body and mind',
      type: 'Yoga',
      intensity: 'low',
      duration: 20,
      imageUrl: 'assets/backgrounds/yoga_bg.jpg',
      exercises: [
        ExerciseModel(
          id: '1',
          name: 'Deep Breathing',
          description: 'Focus on slow, deep breaths',
          durationSeconds: 60,
          sets: 1,
          repetitions: null,
        ),
        ExerciseModel(
          id: '2',
          name: 'Child\'s Pose',
          description: 'Restful pose to relax and stretch',
          durationSeconds: 45,
          sets: 1,
          repetitions: null,
        ),
        ExerciseModel(
          id: '3',
          name: 'Cat-Cow Stretch',
          description: 'Flowing between cat and cow poses',
          durationSeconds: 60,
          sets: 1,
          repetitions: 10,
        ),
        ExerciseModel(
          id: '4',
          name: 'Downward Dog',
          description: 'Classic yoga pose to stretch and strengthen',
          durationSeconds: 45,
          sets: 1,
          repetitions: null,
        ),
      ],
      moodIds: ['3', '4'], // Calm, Tired
      isQuickWorkout: true,
      createdAt: DateTime.now(),
    ),
    WorkoutModel(
      id: '3',
      name: 'Dance Party Cardio',
      description: 'Fun dance moves to lift your spirits',
      type: 'Dance',
      intensity: 'medium',
      duration: 25,
      imageUrl: 'assets/backgrounds/dance_bg.jpg',
      exercises: [
        ExerciseModel(
          id: '1',
          name: 'Warm-up Dance',
          description: 'Simple steps to get moving',
          durationSeconds: 120,
          sets: 1,
          repetitions: null,
        ),
        ExerciseModel(
          id: '2',
          name: 'Shuffle Steps',
          description: 'Basic shuffle dance moves',
          durationSeconds: 60,
          sets: 2,
          repetitions: null,
        ),
        ExerciseModel(
          id: '3',
          name: 'Freestyle Dance',
          description: 'Move however feels good!',
          durationSeconds: 180,
          sets: 1,
          repetitions: null,
        ),
      ],
      moodIds: ['2'], // Happy
      isQuickWorkout: true,
      createdAt: DateTime.now(),
    ),
    WorkoutModel(
      id: '4',
      name: 'Focused Strength Training',
      description: 'Structured workout to build muscle and focus your mind',
      type: 'Strength',
      intensity: 'medium',
      duration: 40,
      imageUrl: 'assets/backgrounds/strength_bg.jpg',
      exercises: [
        ExerciseModel(
          id: '1',
          name: 'Squats',
          description: 'Standard bodyweight squats',
          durationSeconds: 0,
          sets: 3,
          repetitions: 15,
        ),
        ExerciseModel(
          id: '2',
          name: 'Lunges',
          description: 'Alternating lunges',
          durationSeconds: 0,
          sets: 3,
          repetitions: 10,
        ),
        ExerciseModel(
          id: '3',
          name: 'Plank',
          description: 'Hold a standard plank position',
          durationSeconds: 30,
          sets: 3,
          repetitions: null,
        ),
        ExerciseModel(
          id: '4',
          name: 'Dumbbell Rows',
          description: 'Use household items if no dumbbells available',
          durationSeconds: 0,
          sets: 3,
          repetitions: 12,
        ),
      ],
      moodIds: ['6'], // Focused
      createdAt: DateTime.now(),
    ),
    WorkoutModel(
      id: '5',
      name: '5-Minute Energy Boost',
      description: 'Quick exercises to wake up your body',
      type: 'HIIT',
      intensity: 'medium',
      duration: 5,
      imageUrl: 'assets/backgrounds/hiit_bg.jpg',
      exercises: [
        ExerciseModel(
          id: '1',
          name: 'Jumping Jacks',
          description: 'Quick jumping jacks to get your heart rate up',
          durationSeconds: 30,
          sets: 1,
          repetitions: null,
        ),
        ExerciseModel(
          id: '2',
          name: 'Squats',
          description: 'Bodyweight squats',
          durationSeconds: 30,
          sets: 1,
          repetitions: null,
        ),
        ExerciseModel(
          id: '3',
          name: 'Push-ups',
          description: 'As many as you can in the time',
          durationSeconds: 30,
          sets: 1,
          repetitions: null,
        ),
        ExerciseModel(
          id: '4',
          name: 'High Knees',
          description: 'Run in place with high knees',
          durationSeconds: 30,
          sets: 1,
          repetitions: null,
        ),
      ],
      moodIds: ['1', '2', '5', '6'], // Energetic, Happy, Stressed, Focused
      isQuickWorkout: true,
      createdAt: DateTime.now(),
    ),
  ];
}
