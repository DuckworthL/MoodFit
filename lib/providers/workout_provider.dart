import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moodfit/models/mood_model.dart';
import 'package:moodfit/models/workout_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<WorkoutModel> _workouts = [];
  List<WorkoutModel> _recommendedWorkouts = [];
  List<WorkoutModel> _userWorkouts = []; // Add this for user-created workouts
  WorkoutModel? _currentWorkout;
  bool _isLoading = false;
  String? _error;

  List<WorkoutModel> get workouts => _workouts;
  List<WorkoutModel> get recommendedWorkouts => _recommendedWorkouts;
  List<WorkoutModel> get userWorkouts => _userWorkouts; // Add this getter
  WorkoutModel? get currentWorkout => _currentWorkout;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWorkouts() async {
    try {
      _isLoading = true;
      _error = null;

      // Don't notify listeners yet - collect the data first
      QuerySnapshot querySnapshot =
          await _firestore.collection('workouts').get();

      List<WorkoutModel> tempWorkouts = [];

      // Process all documents one by one to catch potential parsing errors
      for (var doc in querySnapshot.docs) {
        try {
          tempWorkouts.add(WorkoutModel.fromFirestore(doc));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing workout document ${doc.id}: $e');
          }
        }
      }

      // Only after all data is processed, update state and notify
      _workouts = tempWorkouts;
      _isLoading = false;
      notifyListeners(); // Single notification after all processing
    } catch (e) {
      if (kDebugMode) {
        print('Error loading workouts: $e');
      }
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add new method to specifically load user workouts
  Future<void> loadUserWorkouts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String? userId = await _getCurrentUserId();
      if (userId == null) {
        _isLoading = false;
        _error = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Load workouts created by this user
      QuerySnapshot querySnapshot = await _firestore
          .collection('workouts')
          .where('createdBy', isEqualTo: userId)
          .get();

      List<WorkoutModel> userWorkouts = [];
      for (var doc in querySnapshot.docs) {
        try {
          userWorkouts.add(WorkoutModel.fromFirestore(doc));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing user workout document ${doc.id}: $e');
          }
        }
      }

      _userWorkouts = userWorkouts;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUserCreatedWorkouts(String userId) async {
    try {
      // Don't set loading or notify yet
      QuerySnapshot querySnapshot = await _firestore
          .collection('workouts')
          .where('createdBy', isEqualTo: userId)
          .get();

      List<WorkoutModel> userWorkouts = [];
      // Process documents individually
      for (var doc in querySnapshot.docs) {
        try {
          userWorkouts.add(WorkoutModel.fromFirestore(doc));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing user workout document ${doc.id}: $e');
          }
        }
      }

      // First update the state (without notifying)
      for (var workout in userWorkouts) {
        if (!_workouts.any((w) => w.id == workout.id)) {
          _workouts.add(workout);
        }
      }

      // Now notify once after all changes
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user workouts: $e');
      }
      _error = e.toString();
      notifyListeners();
    }
  }

  List<WorkoutModel> getQuickWorkouts() {
    return _workouts.where((workout) => workout.isQuickWorkout()).toList();
  }

  Future<void> updateRecommendedWorkouts(MoodType mood, int energyLevel) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Updated mood-based workout recommendation algorithm
      List<WorkoutModel> recommended = [];

      // Filter workouts based on mood type first
      switch (mood) {
        case MoodType.happy:
          // For happy moods, recommend maintaining the positive mood
          recommended = _workouts
              .where((w) =>
                  w.recommendedMood == MoodType.happy ||
                  w.recommendedMood == MoodType.energetic ||
                  w.energyLevelRequired >= 5)
              .toList();
          break;

        case MoodType.sad:
          // For sad moods, recommend mood lifting gentle workouts
          recommended = _workouts
              .where((w) =>
                  w.recommendedMood == MoodType.happy ||
                  (w.energyLevelRequired >= 3 && w.energyLevelRequired <= 6))
              .toList();
          break;

        case MoodType.tired:
          // For tired moods, recommend gentle, restorative workouts
          recommended = _workouts
              .where((w) =>
                  w.recommendedMood == MoodType.calm ||
                  (w.energyLevelRequired <= 5 && w.totalDurationMinutes <= 20))
              .toList();
          break;

        case MoodType.stressed:
          // For stressed moods, recommend calming workouts
          recommended = _workouts
              .where((w) =>
                  w.recommendedMood == MoodType.calm ||
                  w.energyLevelRequired <= 4)
              .toList();
          break;

        case MoodType.energetic:
          // For energetic moods, recommend channeling that energy
          recommended = _workouts
              .where((w) =>
                  w.recommendedMood == MoodType.energetic ||
                  w.energyLevelRequired >= 7)
              .toList();
          break;

        case MoodType.calm:
          // For calm moods, recommend maintaining or enhancing that state
          recommended = _workouts
              .where((w) =>
                  w.recommendedMood == MoodType.calm ||
                  (w.energyLevelRequired >= 3 && w.energyLevelRequired <= 7))
              .toList();
          break;

        default:
          // Default recommendations based on energy level
          recommended = _workouts
              .where((w) =>
                  (w.energyLevelRequired >= energyLevel - 2) &&
                  (w.energyLevelRequired <= energyLevel + 2))
              .toList();
      }

      // If we don't have enough recommendations, add some based on energy level
      if (recommended.length < 3) {
        List<WorkoutModel> additionalWorkouts = _workouts
            .where((w) =>
                !recommended.contains(w) &&
                (w.energyLevelRequired >= energyLevel - 3) &&
                (w.energyLevelRequired <= energyLevel + 3))
            .take(5 - recommended.length)
            .toList();

        recommended.addAll(additionalWorkouts);
      }

      // Sort by how closely they match the energy level
      recommended.sort((a, b) => (a.energyLevelRequired - energyLevel)
          .abs()
          .compareTo((b.energyLevelRequired - energyLevel).abs()));

      // Take the top 5 recommendations
      _recommendedWorkouts = recommended.take(5).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createCustomWorkout(
      String name,
      String description,
      List<Exercise> exercises,
      MoodType recommendedMood,
      int energyLevelRequired,
      String backgroundImage,
      String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Calculate total duration
      int totalDurationMinutes = exercises.fold(
          // ignore: avoid_types_as_parameter_names
          0,
          // ignore: avoid_types_as_parameter_names
          (sum, exercise) => sum + (exercise.durationSeconds ~/ 60));
      if (totalDurationMinutes == 0 && exercises.isNotEmpty) {
        totalDurationMinutes = 1; // Minimum 1 minute
      }

      WorkoutModel newWorkout = WorkoutModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        exercises: exercises,
        recommendedMood: recommendedMood,
        energyLevelRequired: energyLevelRequired,
        totalDurationMinutes: totalDurationMinutes,
        backgroundImage: backgroundImage,
        createdBy: userId,
      );

      DocumentReference docRef =
          await _firestore.collection('workouts').add(newWorkout.toJson());

      // Update with the Firestore document ID
      WorkoutModel updatedWorkout = WorkoutModel(
        id: docRef.id,
        name: name,
        description: description,
        exercises: exercises,
        recommendedMood: recommendedMood,
        energyLevelRequired: energyLevelRequired,
        totalDurationMinutes: totalDurationMinutes,
        backgroundImage: backgroundImage,
        createdBy: userId,
      );

      _workouts.add(updatedWorkout);
      _userWorkouts.add(updatedWorkout); // Add to user workouts too

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

  // Update workout method for editing workouts
  Future<bool> updateWorkout(
      String workoutId,
      String name,
      String description,
      List<Exercise> exercises,
      MoodType recommendedMood,
      int energyLevelRequired,
      String backgroundImage,
      String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Calculate total duration
      int totalDurationMinutes = exercises.fold(
          // ignore: avoid_types_as_parameter_names
          0,
          // ignore: avoid_types_as_parameter_names
          (sum, exercise) => sum + (exercise.durationSeconds ~/ 60));
      if (totalDurationMinutes == 0 && exercises.isNotEmpty) {
        totalDurationMinutes = 1; // Minimum 1 minute
      }

      WorkoutModel updatedWorkout = WorkoutModel(
        id: workoutId,
        name: name,
        description: description,
        exercises: exercises,
        recommendedMood: recommendedMood,
        energyLevelRequired: energyLevelRequired,
        totalDurationMinutes: totalDurationMinutes,
        backgroundImage: backgroundImage,
        createdBy: userId,
      );

      // Update in Firestore
      await _firestore
          .collection('workouts')
          .doc(workoutId)
          .update(updatedWorkout.toJson());

      // Update in local lists
      int indexInWorkouts = _workouts.indexWhere((w) => w.id == workoutId);
      if (indexInWorkouts != -1) {
        _workouts[indexInWorkouts] = updatedWorkout;
      }

      int indexInUserWorkouts =
          _userWorkouts.indexWhere((w) => w.id == workoutId);
      if (indexInUserWorkouts != -1) {
        _userWorkouts[indexInUserWorkouts] = updatedWorkout;
      }

      int indexInRecommended =
          _recommendedWorkouts.indexWhere((w) => w.id == workoutId);
      if (indexInRecommended != -1) {
        _recommendedWorkouts[indexInRecommended] = updatedWorkout;
      }

      if (_currentWorkout?.id == workoutId) {
        _currentWorkout = updatedWorkout;
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

  // Updated deleteWorkout method that returns a Map with success status and message
  Future<Map<String, dynamic>> deleteWorkout(
      String workoutId, String workoutName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get the current user ID
      String? userId = await _getCurrentUserId();
      if (userId == null) {
        _isLoading = false;
        _error = 'User not authenticated';
        notifyListeners();
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Get the workout document
      DocumentSnapshot workoutDoc =
          await _firestore.collection('workouts').doc(workoutId).get();

      if (!workoutDoc.exists) {
        _isLoading = false;
        _error = 'Workout not found';
        notifyListeners();
        return {'success': false, 'message': 'Workout not found'};
      }

      Map<String, dynamic> data = workoutDoc.data() as Map<String, dynamic>;

      // Only allow deletion if the user created the workout or it's a system workout
      if (data['createdBy'] != userId && data['createdBy'] != 'system') {
        _isLoading = false;
        _error = 'You can only delete workouts you created';
        notifyListeners();
        return {
          'success': false,
          'message': 'You can only delete workouts you created'
        };
      }

      // Delete from Firestore
      await _firestore.collection('workouts').doc(workoutId).delete();

      // Update local data
      _workouts.removeWhere((workout) => workout.id == workoutId);
      _userWorkouts.removeWhere((workout) => workout.id == workoutId);
      _recommendedWorkouts.removeWhere((workout) => workout.id == workoutId);

      if (_currentWorkout?.id == workoutId) {
        _currentWorkout = null;
      }

      _isLoading = false;
      notifyListeners();
      return {
        'success': true,
        'message': '"$workoutName" has been deleted successfully'
      };
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return {
        'success': false,
        'message': 'Error deleting workout: ${e.toString()}'
      };
    }
  }

  // Helper method to get current user ID
  Future<String?> _getCurrentUserId() async {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  void setCurrentWorkout(WorkoutModel workout) {
    _currentWorkout = workout;
    notifyListeners();
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }
}
