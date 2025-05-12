// lib/providers/progress_provider.dart - Progress tracking state management
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moodfit/models/mood_model.dart';
import 'package:moodfit/models/progress_model.dart';

class ProgressProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<WorkoutProgressModel> _progressEntries = [];
  bool _isLoading = false;
  String? _error;

  List<WorkoutProgressModel> get progressEntries => _progressEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Original method that requires an index
  Future<void> loadUserProgress(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      QuerySnapshot querySnapshot = await _firestore
          .collection('workout_progress')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      _progressEntries = querySnapshot.docs
          .map((doc) => WorkoutProgressModel.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // New method that doesn't require an index
  Future<void> loadUserProgressSimple(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get documents without ordering first (avoids index requirement)
      QuerySnapshot querySnapshot = await _firestore
          .collection('workout_progress')
          .where('userId', isEqualTo: userId)
          .get();

      List<WorkoutProgressModel> userProgress = [];
      for (var doc in querySnapshot.docs) {
        try {
          userProgress.add(WorkoutProgressModel.fromFirestore(doc));
        } catch (e) {
          debugPrint('Error parsing workout progress: $e');
        }
      }

      // Sort in memory instead of database
      userProgress.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      _progressEntries = userProgress;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addWorkoutProgress(
      String userId,
      String workoutId,
      String workoutName,
      int durationMinutes,
      MoodType moodBefore,
      int energyLevelBefore,
      {MoodType? moodAfter,
      int? energyLevelAfter,
      String? notes}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      WorkoutProgressModel newProgress = WorkoutProgressModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        workoutId: workoutId,
        workoutName: workoutName,
        completedAt: DateTime.now(),
        durationMinutes: durationMinutes,
        moodBefore: moodBefore,
        energyLevelBefore: energyLevelBefore,
        moodAfter: moodAfter,
        energyLevelAfter: energyLevelAfter,
        notes: notes,
      );

      DocumentReference docRef = await _firestore
          .collection('workout_progress')
          .add(newProgress.toJson());

      // Update with the Firestore document ID
      WorkoutProgressModel updatedProgress = WorkoutProgressModel(
        id: docRef.id,
        userId: userId,
        workoutId: workoutId,
        workoutName: workoutName,
        completedAt: newProgress.completedAt,
        durationMinutes: durationMinutes,
        moodBefore: moodBefore,
        energyLevelBefore: energyLevelBefore,
        moodAfter: moodAfter,
        energyLevelAfter: energyLevelAfter,
        notes: notes,
      );

      _progressEntries.insert(0, updatedProgress);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // New method to delete workout progress entries
  Future<bool> deleteWorkoutProgress(String progressId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.collection('workout_progress').doc(progressId).delete();

      _progressEntries.removeWhere((progress) => progress.id == progressId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateWorkoutProgressAfterCompletion(
      String progressId, MoodType moodAfter, int energyLevelAfter,
      {String? notes}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.collection('workout_progress').doc(progressId).update({
        'moodAfter': moodAfter.toString().split('.').last,
        'energyLevelAfter': energyLevelAfter,
        'notes': notes,
      });

      int index =
          _progressEntries.indexWhere((progress) => progress.id == progressId);
      if (index != -1) {
        WorkoutProgressModel oldProgress = _progressEntries[index];
        WorkoutProgressModel updatedProgress = WorkoutProgressModel(
          id: progressId,
          userId: oldProgress.userId,
          workoutId: oldProgress.workoutId,
          workoutName: oldProgress.workoutName,
          completedAt: oldProgress.completedAt,
          durationMinutes: oldProgress.durationMinutes,
          moodBefore: oldProgress.moodBefore,
          energyLevelBefore: oldProgress.energyLevelBefore,
          moodAfter: moodAfter,
          energyLevelAfter: energyLevelAfter,
          notes: notes,
        );

        _progressEntries[index] = updatedProgress;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<WorkoutProgressModel> getProgressForDateRange(
      DateTime start, DateTime end) {
    return _progressEntries
        .where((progress) =>
            progress.completedAt.isAfter(start) &&
            progress.completedAt.isBefore(end))
        .toList();
  }

  int getTotalWorkoutsCompleted() {
    return _progressEntries.length;
  }

  int getTotalMinutesWorkout() {
    return _progressEntries.fold(
        // ignore: avoid_types_as_parameter_names
        0, (sum, progress) => sum + progress.durationMinutes);
  }

  Map<MoodType, int> getMoodDistribution() {
    Map<MoodType, int> distribution = {};
    for (var progress in _progressEntries) {
      distribution[progress.moodBefore] =
          (distribution[progress.moodBefore] ?? 0) + 1;
    }
    return distribution;
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }
}
