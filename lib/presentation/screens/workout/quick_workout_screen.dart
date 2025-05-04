// lib/presentation/screens/workout/quick_workout_screen.dart - Quick workout screen

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moodfit/core/navigation/routes.dart';
import 'package:moodfit/data/models/workout_model.dart';
import 'package:moodfit/presentation/common/app_button.dart';
import 'package:moodfit/presentation/common/breadcrumb.dart';
import 'package:moodfit/presentation/common/loading_indicator.dart';
import 'package:moodfit/providers/workout_provider.dart';
import 'package:provider/provider.dart';

class QuickWorkoutScreen extends StatefulWidget {
  final String workoutId;
  final int? duration;

  const QuickWorkoutScreen({super.key, required this.workoutId, this.duration});

  @override
  State<QuickWorkoutScreen> createState() => _QuickWorkoutScreenState();
}

class _QuickWorkoutScreenState extends State<QuickWorkoutScreen> {
  late WorkoutProvider workoutProvider;
  WorkoutModel? workout;
  int currentExerciseIndex = 0;
  bool isWorkoutActive = false;
  bool isWorkoutCompleted = false;
  bool isResting = false;

  // Timer related
  int secondsRemaining = 0;
  Timer? exerciseTimer;

  // Overall workout progress tracking
  int totalExercises = 0;
  int completedExercises = 0;
  int totalDuration = 0;
  int elapsedDuration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      _loadWorkout();
    });
  }

  @override
  void dispose() {
    exerciseTimer?.cancel();
    super.dispose();
  }

  void _loadWorkout() {
    workoutProvider.selectWorkout(widget.workoutId);
    setState(() {
      workout = workoutProvider.selectedWorkout;

      if (workout != null) {
        // Calculate total workout stats
        totalExercises = workout!.exercises.length;
        totalDuration = workout!.duration * 60; // Convert to seconds

        // Set initial timer value for first exercise
        _setupExerciseTimer();
      }
    });
  }

  void _setupExerciseTimer() {
    if (workout == null || currentExerciseIndex >= workout!.exercises.length) {
      return;
    }

    final exercise = workout!.exercises[currentExerciseIndex];

    // If it's a timed exercise, use its duration
    if (exercise.repetitions == null) {
      setState(() {
        secondsRemaining = exercise.durationSeconds;
      });
    } else {
      // For rep-based exercises, allocate a reasonable amount of time
      // based on reps and sets (approx. 3 seconds per rep)
      setState(() {
        secondsRemaining = exercise.repetitions! * 3;
      });
    }
  }

  void _startWorkout() {
    setState(() {
      isWorkoutActive = true;
    });
    _startExerciseTimer();
  }

  void _startExerciseTimer() {
    exerciseTimer?.cancel();

    exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
          elapsedDuration++;
        } else {
          timer.cancel();

          // If it was a rest period, move to next exercise
          if (isResting) {
            isResting = false;
            currentExerciseIndex++;
            completedExercises++;

            // Check if workout is completed
            if (currentExerciseIndex >= workout!.exercises.length) {
              _completeWorkout();
            } else {
              _setupExerciseTimer();
              _startExerciseTimer();
            }
          } else {
            // Move to rest period if not the last exercise
            if (currentExerciseIndex < workout!.exercises.length - 1) {
              isResting = true;
              secondsRemaining = 15; // 15 seconds rest between exercises
              _startExerciseTimer();
            } else {
              _completeWorkout();
            }
          }
        }
      });
    });
  }

  void _pauseWorkout() {
    exerciseTimer?.cancel();
    setState(() {
      isWorkoutActive = false;
    });
  }

  void _resumeWorkout() {
    setState(() {
      isWorkoutActive = true;
    });
    _startExerciseTimer();
  }

  void _skipExercise() {
    exerciseTimer?.cancel();

    setState(() {
      if (isResting) {
        isResting = false;
      }

      currentExerciseIndex++;
      completedExercises++;

      // Check if workout is completed
      if (currentExerciseIndex >= workout!.exercises.length) {
        _completeWorkout();
      } else {
        _setupExerciseTimer();
        if (isWorkoutActive) {
          _startExerciseTimer();
        }
      }
    });
  }

  void _completeWorkout() async {
    exerciseTimer?.cancel();

    setState(() {
      isWorkoutCompleted = true;
      isWorkoutActive = false;
    });

    // Mark workout as completed
    await workoutProvider.completeWorkout(widget.workoutId);
  }

  void _confirmExit() {
    if (!isWorkoutCompleted && (isWorkoutActive || elapsedDuration > 0)) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Exit Workout?'),
              content: const Text(
                'Your progress will not be saved if you leave now. Are you sure you want to exit?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Exit'),
                ),
              ],
            ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    workoutProvider = Provider.of<WorkoutProvider>(context);

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        _confirmExit();
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child:
              workout == null
                  ? const LoadingIndicator(message: 'Loading workout...')
                  : isWorkoutCompleted
                  ? _buildWorkoutCompletedScreen()
                  : _buildWorkoutInProgressScreen(),
        ),
      ),
    );
  }

  Widget _buildWorkoutInProgressScreen() {
    final exercise =
        currentExerciseIndex < workout!.exercises.length
            ? workout!.exercises[currentExerciseIndex]
            : null;

    return Column(
      children: [
        // App Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _confirmExit(),
              ),
              const Expanded(
                child: Text(
                  'Quick Workout',
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
              BreadcrumbItem(label: 'Home', onTap: () => _confirmExit()),
              BreadcrumbItem(
                label: 'Quick Workouts',
                onTap: () => _confirmExit(),
              ),
              BreadcrumbItem(label: workout!.name, isActive: true),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Overall Progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercise ${currentExerciseIndex + 1} of ${workout!.exercises.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_formatDuration(elapsedDuration)} / ${_formatDuration(totalDuration)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value:
                    workout!.exercises.isNotEmpty
                        ? (currentExerciseIndex / workout!.exercises.length)
                        : 0,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Current Exercise
        if (exercise != null) ...[
          // Status (Rest or Exercise)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isResting
                      // ignore: deprecated_member_use
                      ? Colors.blue.withOpacity(0.2)
                      // ignore: deprecated_member_use
                      : Theme.of(context).primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isResting ? 'REST' : 'EXERCISE',
              style: TextStyle(
                color: isResting ? Colors.blue : Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Exercise name
          Text(
            isResting ? 'Rest' : exercise.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Exercise description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              isResting
                  ? 'Take a short break before the next exercise'
                  : exercise.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Timer display
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: isResting ? Colors.blue : Theme.of(context).primaryColor,
                width: 8,
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(secondsRemaining),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color:
                          isResting
                              ? Colors.blue
                              : Theme.of(context).primaryColor,
                    ),
                  ),
                  if (!isResting && exercise.repetitions != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${exercise.repetitions} reps',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Exercise details
          if (!isResting) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildExerciseDetailChip(
                    Icons.repeat,
                    '${exercise.sets} sets',
                    Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 24),
                  _buildExerciseDetailChip(
                    exercise.repetitions != null
                        ? Icons.fitness_center
                        : Icons.timer,
                    exercise.repetitions != null
                        ? '${exercise.repetitions} reps'
                        : '${exercise.durationSeconds} sec',
                    Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ],

        const Spacer(),

        // Control buttons
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.skip_next),
                  color: Colors.grey[800],
                  onPressed: _skipExercise,
                  tooltip: 'Skip',
                  iconSize: 28,
                ),
              ),
              CircleAvatar(
                radius: 36,
                backgroundColor:
                    isWorkoutActive
                        ? Colors.red
                        : Theme.of(context).primaryColor,
                child: IconButton(
                  icon: Icon(isWorkoutActive ? Icons.pause : Icons.play_arrow),
                  color: Colors.white,
                  onPressed:
                      isWorkoutActive
                          ? _pauseWorkout
                          : (secondsRemaining > 0
                              ? _resumeWorkout
                              : _startWorkout),
                  tooltip: isWorkoutActive ? 'Pause' : 'Start',
                  iconSize: 36,
                ),
              ),
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.stop),
                  color: Colors.grey[800],
                  onPressed: () {
                    _confirmEndWorkout();
                  },
                  tooltip: 'End Workout',
                  iconSize: 28,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmEndWorkout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('End Workout?'),
            content: const Text(
              'Are you sure you want to end this workout early?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _completeWorkout();
                },
                child: const Text('End Workout'),
              ),
            ],
          ),
    );
  }

  Widget _buildWorkoutCompletedScreen() {
    return Column(
      children: [
        // App Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: Text(
                  'Workout Complete',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // To balance the appbar
            ],
          ),
        ),

        const Spacer(),

        // Completion graphic
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // ignore: deprecated_member_use
            color: Colors.green.withOpacity(0.1),
            border: Border.all(color: Colors.green, width: 8),
          ),
          child: const Center(
            child: Icon(Icons.check, size: 100, color: Colors.green),
          ),
        ),

        const SizedBox(height: 32),

        // Congratulations text
        const Text(
          'Great Job!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        Text(
          'You completed the ${workout!.name} workout',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompletionStat(
                context,
                Icons.timer,
                _formatDuration(elapsedDuration),
                'Duration',
              ),
              _buildCompletionStat(
                context,
                Icons.whatshot,
                '${(elapsedDuration / 60 * 5).round()}',
                'Calories',
              ),
              _buildCompletionStat(
                context,
                Icons.fitness_center,
                completedExercises.toString(),
                'Exercises',
              ),
            ],
          ),
        ),

        const Spacer(),

        // Buttons
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              AppButton(
                text: 'Back to Dashboard',
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(Routes.dashboard, (route) => false);
                },
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'View Workout Details',
                isOutlined: true,
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(
                    Routes.workoutDetails,
                    arguments: {'workoutId': workout!.id},
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseDetailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStat(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 30, color: Colors.green),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  // Format seconds to MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Format seconds to human-readable duration
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
