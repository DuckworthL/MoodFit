// lib/presentation/screens/workout/workout_details_screen.dart - Workout details screen

import 'package:flutter/material.dart';
import 'package:moodfit/core/navigation/routes.dart';
import 'package:moodfit/data/models/mood_model.dart';
import 'package:moodfit/data/models/workout_model.dart';
import 'package:moodfit/presentation/common/app_button.dart';
import 'package:moodfit/presentation/common/breadcrumb.dart';
import 'package:moodfit/presentation/common/loading_indicator.dart';
import 'package:moodfit/providers/workout_provider.dart';
import 'package:provider/provider.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final String workoutId;
  final MoodModel? mood;

  const WorkoutDetailsScreen({super.key, required this.workoutId, this.mood});

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  late WorkoutProvider workoutProvider;
  WorkoutModel? workout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      _loadWorkout();
    });
  }

  void _loadWorkout() {
    workoutProvider.selectWorkout(widget.workoutId);
    setState(() {
      workout = workoutProvider.selectedWorkout;
    });
  }

  @override
  Widget build(BuildContext context) {
    workoutProvider = Provider.of<WorkoutProvider>(context);
    workout = workoutProvider.selectedWorkout;

    return Scaffold(
      body: SafeArea(
        child:
            workout == null
                ? const LoadingIndicator(message: 'Loading workout details...')
                : _buildWorkoutDetails(),
      ),
    );
  }

  Widget _buildWorkoutDetails() {
    return Column(
      children: [
        // App Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: Text(
                  'Workout Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // To balance the appbar
            ],
          ),
        ),

        // Breadcrumb
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Breadcrumb(
            items: [
              BreadcrumbItem(
                label: 'Home',
                onTap:
                    () => Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.dashboard,
                      (route) => false,
                    ),
              ),
              if (widget.mood != null) ...[
                BreadcrumbItem(
                  label: 'Mood Selection',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
              BreadcrumbItem(label: workout!.name, isActive: true),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workout Header
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _getWorkoutColor(workout!.type),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getWorkoutIcon(workout!.type),
                          size: 70,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          workout!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Workout Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Workout Stats
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWorkoutStat(
                              context,
                              Icons.timer,
                              '${workout!.duration} min',
                              'Duration',
                            ),
                            _buildWorkoutStat(
                              context,
                              Icons.whatshot,
                              workout!.intensity.toUpperCase(),
                              'Intensity',
                            ),
                            _buildWorkoutStat(
                              context,
                              Icons.fitness_center,
                              workout!.type,
                              'Type',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        workout!.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),

                      const SizedBox(height: 24),

                      // Exercises
                      const Text(
                        'Exercises',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...workout!.exercises.map(
                        (exercise) => _buildExerciseCard(
                          exercise,
                          workout!.exercises.indexOf(exercise) + 1,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Start Workout Button
                      AppButton(
                        text: 'Start Workout',
                        icon: Icons.play_circle_filled,
                        onPressed: () {
                          // Navigate to quick workout screen with the workout ID
                          Navigator.of(context).pushNamed(
                            Routes.quickWorkout,
                            arguments: {
                              'workoutId': workout!.id,
                              'duration': workout!.duration,
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutStat(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Index
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  index.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Exercise Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.repeat, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${exercise.sets} ${exercise.sets > 1 ? 'sets' : 'set'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      if (exercise.repetitions != null) ...[
                        Icon(
                          Icons.fitness_center,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${exercise.repetitions} reps',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ] else ...[
                        Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${exercise.durationSeconds} sec',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getWorkoutColor(String workoutType) {
    switch (workoutType) {
      case 'HIIT':
        return const Color(0xFFFF5733);
      case 'Yoga':
        return const Color(0xFF4CAF50);
      case 'Dance':
        return const Color(0xFFFFC300);
      case 'Strength':
        return const Color(0xFF2196F3);
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getWorkoutIcon(String workoutType) {
    switch (workoutType) {
      case 'HIIT':
        return Icons.flash_on;
      case 'Yoga':
        return Icons.self_improvement;
      case 'Dance':
        return Icons.music_note;
      case 'Strength':
        return Icons.fitness_center;
      default:
        return Icons.directions_run;
    }
  }
}
