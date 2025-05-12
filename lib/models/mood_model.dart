// lib/models/mood_model.dart - Mood data model for tracking user emotions
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MoodType {
  energetic,
  happy,
  calm,
  tired,
  stressed,
  sad,
}

class MoodModel {
  final String id;
  final MoodType type;
  final int energyLevel; // 1-10
  final DateTime timestamp;
  final String? note;
  final String userId;

  MoodModel({
    required this.id,
    required this.type,
    required this.energyLevel,
    required this.timestamp,
    required this.userId,
    this.note,
  });

  factory MoodModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MoodModel(
      id: doc.id,
      type: MoodType.values.firstWhere(
        (e) => e.toString() == 'MoodType.${data['type']}',
        orElse: () => MoodType.calm,
      ),
      energyLevel: data['energyLevel'] ?? 5,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'],
      note: data['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'energyLevel': energyLevel,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      'note': note,
    };
  }

  // Helper method to get color associated with mood
  Color get moodColor {
    switch (type) {
      case MoodType.energetic:
        return Colors.orange;
      case MoodType.happy:
        return Colors.yellow;
      case MoodType.calm:
        return Colors.blue;
      case MoodType.tired:
        return Colors.brown;
      case MoodType.stressed:
        return Colors.red;
      case MoodType.sad:
        return Colors.indigo;
    }
  }

  // Helper method to get icon associated with mood
  IconData get moodIcon {
    switch (type) {
      case MoodType.energetic:
        return Icons.bolt;
      case MoodType.happy:
        return Icons.sentiment_very_satisfied;
      case MoodType.calm:
        return Icons.spa;
      case MoodType.tired:
        return Icons.airline_seat_flat;
      case MoodType.stressed:
        return Icons.psychology;
      case MoodType.sad:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  // Helper method to get background image path for mood
  String get backgroundImage {
    switch (type) {
      case MoodType.energetic:
        return 'assets/backgrounds/jogging_bg.jpg';
      case MoodType.happy:
        return 'assets/backgrounds/dance_bg.jpg';
      case MoodType.calm:
        return 'assets/backgrounds/meditation_bg.jpg';
      case MoodType.tired:
        return 'assets/backgrounds/relaxation_bg.jpg';
      case MoodType.stressed:
        return 'assets/backgrounds/yoga_bg.jpg';
      case MoodType.sad:
        return 'assets/backgrounds/walking_bg.jpg';
    }
  }
}
