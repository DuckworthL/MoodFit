// lib/screens/main/workout_complete_screen.dart - Workout completion and feedback
import 'package:flutter/material.dart';
import 'package:moodfit/models/mood_model.dart';
import 'package:moodfit/models/workout_model.dart';
import 'package:moodfit/providers/auth_provider.dart';
import 'package:moodfit/providers/mood_provider.dart';
import 'package:moodfit/providers/progress_provider.dart';
import 'package:moodfit/screens/main/dashboard_screen.dart';
import 'package:provider/provider.dart';

class WorkoutCompleteScreen extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutCompleteScreen({super.key, required this.workout, required int caloriesBurned});

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen> {
  MoodType? _selectedMoodType;
  int _energyLevel = 5;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkoutCompletion() async {
    if (_selectedMoodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your mood after workout'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final progressProvider =
        Provider.of<ProgressProvider>(context, listen: false);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);

    if (authProvider.uid != null &&
        progressProvider.progressEntries.isNotEmpty) {
      // Find the most recent entry for this workout
      final workoutProgress = progressProvider.progressEntries.firstWhere(
        (progress) => progress.workoutId == widget.workout.id,
        orElse: () => throw Exception('Workout progress not found'),
      );

      // Update the workout progress with post-workout mood and energy
      await progressProvider.updateWorkoutProgressAfterCompletion(
        workoutProgress.id,
        _selectedMoodType!,
        _energyLevel,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Also add the new mood to the user's mood history
      await moodProvider.addMood(
        authProvider.uid!,
        _selectedMoodType!,
        _energyLevel,
        note: 'After ${widget.workout.name} workout',
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      }
    } else {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating workout progress'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.workout.backgroundImage),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(
              Colors.black54,
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Completed Badge
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Completion Message
                  const Text(
                    'WORKOUT COMPLETE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.workout.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Workout Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatCard(
                        '${widget.workout.exercises.length}',
                        'Exercises',
                        Icons.fitness_center,
                      ),
                      const SizedBox(width: 20),
                      _buildStatCard(
                        '${widget.workout.totalDurationMinutes}',
                        'Minutes',
                        Icons.timer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Post-workout Mood Section
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'How do you feel now?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Mood Selection
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: MoodType.values.map((moodType) {
                              final isSelected = _selectedMoodType == moodType;
                              final mood = MoodModel(
                                id: '',
                                type: moodType,
                                energyLevel: 5,
                                timestamp: DateTime.now(),
                                userId: '',
                              );

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedMoodType = moodType;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: isSelected
                                        ? mood.moodColor.withOpacity(0.3)
                                        : Colors.grey.withOpacity(0.1),
                                    border: Border.all(
                                      color: isSelected
                                          ? mood.moodColor
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        mood.moodIcon,
                                        size: 16,
                                        color: isSelected
                                            ? mood.moodColor
                                            : Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        moodType.toString().split('.').last,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? mood.moodColor
                                              : Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          // Energy Level
                          const Text(
                            'Energy Level',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Low',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Expanded(
                                child: Slider(
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  value: _energyLevel.toDouble(),
                                  label: _energyLevel.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      _energyLevel = value.toInt();
                                    });
                                  },
                                ),
                              ),
                              const Text(
                                'High',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Notes
                          const Text(
                            'Notes (optional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'How was your workout?',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Submit Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _saveWorkoutCompletion,
                      child: _isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Complete',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
