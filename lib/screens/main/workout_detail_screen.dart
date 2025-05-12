// lib/screens/main/workout_detail_screen.dart - Display workout details and start workout
import 'package:flutter/material.dart';
import 'package:moodfit/models/mood_model.dart';
import 'package:moodfit/models/workout_model.dart';
import 'package:moodfit/providers/auth_provider.dart';
import 'package:moodfit/providers/mood_provider.dart';
import 'package:moodfit/providers/progress_provider.dart';
import 'package:moodfit/providers/workout_provider.dart';
import 'package:moodfit/screens/main/workout_session_screen.dart';
import 'package:provider/provider.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutModel workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final progressProvider = Provider.of<ProgressProvider>(context);

    final MoodModel moodModel = MoodModel(
      id: '',
      type: workout.recommendedMood,
      energyLevel: workout.energyLevelRequired,
      timestamp: DateTime.now(),
      userId: '',
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                workout.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    workout.backgroundImage,
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black54],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (workout.createdBy == authProvider.uid ||
                  workout.createdBy == 'system')
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'delete' && authProvider.uid != null) {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Workout'),
                          content: const Text(
                              'Are you sure you want to delete this workout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        final result = await workoutProvider.deleteWorkout(
                          workout.id,
                          authProvider.uid!,
                        );

                        if (result && context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Workout deleted successfully')),
                          );
                        }
                      }
                    }
                  },
                ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Workout Info Section
                    Row(
                      children: [
                        Chip(
                          backgroundColor: moodModel.moodColor.withOpacity(0.2),
                          label: Row(
                            children: [
                              Icon(
                                moodModel.moodIcon,
                                size: 16,
                                color: moodModel.moodColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                workout.recommendedMood
                                    .toString()
                                    .split('.')
                                    .last,
                                style: TextStyle(color: moodModel.moodColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          label: Row(
                            children: [
                              const Icon(
                                Icons.battery_charging_full,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Energy: ${workout.energyLevelRequired}/10',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      workout.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Exercise List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Exercises',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total: ${workout.totalDurationMinutes} min',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workout.exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = workout.exercises[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: exercise.isRest
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              child: Icon(
                                exercise.isRest
                                    ? Icons.pause
                                    : Icons.fitness_center,
                                color: exercise.isRest
                                    ? Colors.blue
                                    : Colors.orange,
                              ),
                            ),
                            title: Text(
                              exercise.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(exercise.description),
                            trailing: Text(
                              '${exercise.durationSeconds}s',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // Compatibility with current mood
                    if (moodProvider.currentMood != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _getCompatibilityColor(
                            workout.recommendedMood,
                            moodProvider.currentMood!.type,
                            workout.energyLevelRequired,
                            moodProvider.currentMood!.energyLevel,
                          ).withOpacity(0.1),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getCompatibilityIcon(
                                workout.recommendedMood,
                                moodProvider.currentMood!.type,
                                workout.energyLevelRequired,
                                moodProvider.currentMood!.energyLevel,
                              ),
                              color: _getCompatibilityColor(
                                workout.recommendedMood,
                                moodProvider.currentMood!.type,
                                workout.energyLevelRequired,
                                moodProvider.currentMood!.energyLevel,
                              ),
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getCompatibilityText(
                                      workout.recommendedMood,
                                      moodProvider.currentMood!.type,
                                      workout.energyLevelRequired,
                                      moodProvider.currentMood!.energyLevel,
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getCompatibilityColor(
                                        workout.recommendedMood,
                                        moodProvider.currentMood!.type,
                                        workout.energyLevelRequired,
                                        moodProvider.currentMood!.energyLevel,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getCompatibilityDescription(
                                      workout.recommendedMood,
                                      moodProvider.currentMood!.type,
                                      workout.energyLevelRequired,
                                      moodProvider.currentMood!.energyLevel,
                                    ),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (authProvider.uid != null &&
                    moodProvider.currentMood != null) {
                  // Log workout start to progress
                  progressProvider.addWorkoutProgress(
                    authProvider.uid!,
                    workout.id,
                    workout.name,
                    workout.totalDurationMinutes,
                    moodProvider.currentMood!.type,
                    moodProvider.currentMood!.energyLevel,
                  );

                  // Navigate to workout session
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutSessionScreen(
                        workout: workout,
                      ),
                    ),
                  );
                } else if (moodProvider.currentMood == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please set your current mood before starting a workout'),
                    ),
                  );

                  // Navigate to mood selection
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/mood_selection');
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Workout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCompatibilityColor(MoodType workoutMood, MoodType userMood,
      int workoutEnergy, int userEnergy) {
    if (workoutMood == userMood && (workoutEnergy - userEnergy).abs() <= 2) {
      return Colors.green;
    } else if ((workoutEnergy - userEnergy).abs() <= 3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  IconData _getCompatibilityIcon(MoodType workoutMood, MoodType userMood,
      int workoutEnergy, int userEnergy) {
    if (workoutMood == userMood && (workoutEnergy - userEnergy).abs() <= 2) {
      return Icons.check_circle;
    } else if ((workoutEnergy - userEnergy).abs() <= 3) {
      return Icons.info;
    } else {
      return Icons.warning;
    }
  }

  String _getCompatibilityText(MoodType workoutMood, MoodType userMood,
      int workoutEnergy, int userEnergy) {
    if (workoutMood == userMood && (workoutEnergy - userEnergy).abs() <= 2) {
      return 'Perfect Match!';
    } else if ((workoutEnergy - userEnergy).abs() <= 3) {
      return 'Good Match';
    } else {
      return 'Not Recommended';
    }
  }

  String _getCompatibilityDescription(MoodType workoutMood, MoodType userMood,
      int workoutEnergy, int userEnergy) {
    if (workoutMood == userMood && (workoutEnergy - userEnergy).abs() <= 2) {
      return 'This workout is perfectly suited for your current mood and energy level.';
    } else if (workoutMood == userMood) {
      return 'This workout matches your mood but requires ${workoutEnergy > userEnergy ? 'more' : 'less'} energy than your current level.';
    } else if ((workoutEnergy - userEnergy).abs() <= 3) {
      return 'This workout is designed for a different mood but matches your energy level.';
    } else {
      return 'This workout might not be the best choice for your current mood and energy level.';
    }
  }
}
