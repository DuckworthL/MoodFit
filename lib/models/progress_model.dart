// lib/models/progress_model.dart - Progress tracking model for workouts
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moodfit/models/mood_model.dart';

class WorkoutProgressModel {
  final String id;
  final String userId;
  final String workoutId;
  final String workoutName;
  final DateTime completedAt;
  final int durationMinutes;
  final MoodType moodBefore;
  final MoodType? moodAfter;
  final int energyLevelBefore;
  final int? energyLevelAfter;
  final String? notes;

  WorkoutProgressModel({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.workoutName,
    required this.completedAt,
    required this.durationMinutes,
    required this.moodBefore,
    required this.energyLevelBefore,
    this.moodAfter,
    this.energyLevelAfter,
    this.notes,
  });

  factory WorkoutProgressModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WorkoutProgressModel(
      id: doc.id,
      userId: data['userId'],
      workoutId: data['workoutId'],
      workoutName: data['workoutName'],
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'],
      moodBefore: MoodType.values.firstWhere(
        (e) => e.toString() == 'MoodType.${data['moodBefore']}',
        orElse: () => MoodType.calm,
      ),
      moodAfter: data['moodAfter'] != null
          ? MoodType.values.firstWhere(
              (e) => e.toString() == 'MoodType.${data['moodAfter']}',
              orElse: () => MoodType.calm,
            )
          : null,
      energyLevelBefore: data['energyLevelBefore'] ?? 5,
      energyLevelAfter: data['energyLevelAfter'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'workoutId': workoutId,
      'workoutName': workoutName,
      'completedAt': Timestamp.fromDate(completedAt),
      'durationMinutes': durationMinutes,
      'moodBefore': moodBefore.toString().split('.').last,
      'moodAfter': moodAfter?.toString().split('.').last,
      'energyLevelBefore': energyLevelBefore,
      'energyLevelAfter': energyLevelAfter,
      'notes': notes,
    };
  }
}
