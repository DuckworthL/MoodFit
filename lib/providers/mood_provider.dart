// lib/providers/mood_provider.dart - Mood state management

import 'package:flutter/material.dart';
import 'package:moodfit/data/models/mood_model.dart';

class MoodProvider extends ChangeNotifier {
  List<MoodModel> _moods = [];
  MoodModel? _selectedMood;
  final List<MoodModel> _recentMoods = [];
  bool _isLoading = false;
  String? _error;

  List<MoodModel> get moods => _moods;
  MoodModel? get selectedMood => _selectedMood;
  List<MoodModel> get recentMoods => _recentMoods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize moods data
  Future<void> loadMoods() async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Load mock data
      _moods = getMockMoods();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Select a mood
  void selectMood(String moodId) {
    final mood = _moods.firstWhere((m) => m.id == moodId);
    _selectedMood = mood;

    // Add to recent moods if not already there
    if (!_recentMoods.any((m) => m.id == moodId)) {
      if (_recentMoods.length >= 5) {
        _recentMoods.removeLast();
      }
      _recentMoods.insert(0, mood);
    } else {
      // Move to the front if already exists
      _recentMoods.removeWhere((m) => m.id == moodId);
      _recentMoods.insert(0, mood);
    }

    notifyListeners();
  }

  // Clear selected mood
  void clearSelectedMood() {
    _selectedMood = null;
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
