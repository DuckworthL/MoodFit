// lib/data/models/mood_model.dart - Mood data model

class MoodModel {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String intensity; // low, medium, high
  final String color;
  final List<String> suggestedWorkoutTypes;
  final DateTime createdAt;

  MoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.intensity,
    required this.color,
    required this.suggestedWorkoutTypes,
    required this.createdAt,
  });

  // Convert MoodModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'intensity': intensity,
      'color': color,
      'suggestedWorkoutTypes': suggestedWorkoutTypes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create MoodModel from JSON
  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      emoji: json['emoji'],
      intensity: json['intensity'],
      color: json['color'],
      suggestedWorkoutTypes: List<String>.from(json['suggestedWorkoutTypes']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// Predefined list of moods
List<MoodModel> getMockMoods() {
  return [
    MoodModel(
      id: '1',
      name: 'Energetic',
      description: 'Full of energy and ready to take on a challenge',
      emoji: '⚡',
      intensity: 'high',
      color: '#FF5733',
      suggestedWorkoutTypes: ['HIIT', 'Running', 'Boxing'],
      createdAt: DateTime.now(),
    ),
    MoodModel(
      id: '2',
      name: 'Happy',
      description: 'Feeling good and looking for some fun',
      emoji: '😊',
      intensity: 'medium',
      color: '#FFC300',
      suggestedWorkoutTypes: ['Dance', 'Cycling', 'Swimming'],
      createdAt: DateTime.now(),
    ),
    MoodModel(
      id: '3',
      name: 'Calm',
      description: 'Peaceful and steady',
      emoji: '😌',
      intensity: 'low',
      color: '#4CAF50',
      suggestedWorkoutTypes: ['Yoga', 'Pilates', 'Walking'],
      createdAt: DateTime.now(),
    ),
    MoodModel(
      id: '4',
      name: 'Tired',
      description: 'Low on energy but still want to move',
      emoji: '😴',
      intensity: 'low',
      color: '#9E9E9E',
      suggestedWorkoutTypes: ['Stretching', 'Light Walking', 'Gentle Yoga'],
      createdAt: DateTime.now(),
    ),
    MoodModel(
      id: '5',
      name: 'Stressed',
      description: 'Need to release tension and clear your mind',
      emoji: '😣',
      intensity: 'medium',
      color: '#F44336',
      suggestedWorkoutTypes: ['Running', 'Boxing', 'HIIT'],
      createdAt: DateTime.now(),
    ),
    MoodModel(
      id: '6',
      name: 'Focused',
      description: 'In the zone and ready for structured activity',
      emoji: '🧠',
      intensity: 'medium',
      color: '#2196F3',
      suggestedWorkoutTypes: [
        'Weight Training',
        'Circuit Training',
        'Climbing',
      ],
      createdAt: DateTime.now(),
    ),
  ];
}
