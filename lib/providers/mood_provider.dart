// lib/providers/mood_provider.dart - Mood state management
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moodfit/models/mood_model.dart';

class MoodProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<MoodModel> _moods = [];
  MoodModel? _currentMood;
  bool _isLoading = false;
  String? _error;

  List<MoodModel> get moods => _moods;
  MoodModel? get currentMood => _currentMood;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Original method with indexed query
  Future<void> loadUserMoods(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      QuerySnapshot querySnapshot = await _firestore
          .collection('moods')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      _moods = querySnapshot.docs
          .map((doc) => MoodModel.fromFirestore(doc))
          .toList();

      if (_moods.isNotEmpty) {
        _currentMood = _moods.first;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // New method that doesn't require indexes
  Future<void> loadUserMoodsSimple(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get documents without ordering first (avoids index requirement)
      QuerySnapshot querySnapshot = await _firestore
          .collection('moods')
          .where('userId', isEqualTo: userId)
          .get();

      List<MoodModel> userMoods = [];
      for (var doc in querySnapshot.docs) {
        try {
          userMoods.add(MoodModel.fromFirestore(doc));
        } catch (e) {
          debugPrint('Error parsing mood: $e');
        }
      }

      // Sort in memory instead of database
      userMoods.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _moods = userMoods;
      _currentMood = _moods.isNotEmpty ? _moods.first : null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addMood(String userId, MoodType type, int energyLevel,
      {String? note}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      MoodModel newMood = MoodModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        energyLevel: energyLevel,
        timestamp: DateTime.now(),
        userId: userId,
        note: note,
      );

      DocumentReference docRef =
          await _firestore.collection('moods').add(newMood.toJson());

      // Update the ID with the Firestore document ID
      MoodModel updatedMood = MoodModel(
        id: docRef.id,
        type: type,
        energyLevel: energyLevel,
        timestamp: newMood.timestamp,
        userId: userId,
        note: note,
      );

      _currentMood = updatedMood;
      _moods.insert(0, updatedMood);

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

  Future<bool> updateMood(String moodId, MoodType type, int energyLevel,
      {String? note}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.collection('moods').doc(moodId).update({
        'type': type.toString().split('.').last,
        'energyLevel': energyLevel,
        'note': note,
      });

      int index = _moods.indexWhere((mood) => mood.id == moodId);
      if (index != -1) {
        MoodModel oldMood = _moods[index];
        MoodModel updatedMood = MoodModel(
          id: moodId,
          type: type,
          energyLevel: energyLevel,
          timestamp: oldMood.timestamp,
          userId: oldMood.userId,
          note: note,
        );

        _moods[index] = updatedMood;
        if (_currentMood?.id == moodId) {
          _currentMood = updatedMood;
        }
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

  Future<bool> deleteMood(String moodId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.collection('moods').doc(moodId).delete();

      _moods.removeWhere((mood) => mood.id == moodId);
      if (_currentMood?.id == moodId) {
        _currentMood = _moods.isNotEmpty ? _moods.first : null;
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

  List<MoodModel> getMoodsForDateRange(DateTime start, DateTime end) {
    return _moods
        .where((mood) =>
            mood.timestamp.isAfter(start) && mood.timestamp.isBefore(end))
        .toList();
  }

  void setCurrentMood(MoodModel mood) {
    _currentMood = mood;
    notifyListeners();
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }
}
