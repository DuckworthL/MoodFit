// lib/providers/workout_provider.dart - Workout state management

import 'package:flutter/material.dart';
import 'package:moodfit/data/models/workout_model.dart';

class WorkoutProvider extends ChangeNotifier {
  List<WorkoutModel> _workouts = [];
  WorkoutModel? _selectedWorkout;
  final List<WorkoutModel> _completedWorkouts = [];
  bool _isLoading = false;
  String? _error;

  List<WorkoutModel> get workouts => _workouts;
  WorkoutModel? get selectedWorkout => _selectedWorkout;
  List<WorkoutModel> get completedWorkouts => _completedWorkouts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get workouts for a specific mood
  List<WorkoutModel> getWorkoutsForMood(String moodId) {
    return _workouts.where((w) => w.moodIds.contains(moodId)).toList();
  }

  // Get quick workouts
  List<WorkoutModel> getQuickWorkouts() {
    return _workouts.where((w) => w.isQuickWorkout).toList();
  }

  // Initialize workouts data
  Future<void> loadWorkouts() async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Load mock data
      _workouts = getMockWorkouts();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Select a workout
  void selectWorkout(String workoutId) {
    _selectedWorkout = _workouts.firstWhere((w) => w.id == workoutId);
    notifyListeners();
  }

  // Mark workout as completed
  Future<void> completeWorkout(String workoutId) async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final workout = _workouts.firstWhere((w) => w.id == workoutId);

      if (!_completedWorkouts.any((w) => w.id == workoutId)) {
        _completedWorkouts.add(workout);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Clear selected workout
  void clearSelectedWorkout() {
    _selectedWorkout = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
