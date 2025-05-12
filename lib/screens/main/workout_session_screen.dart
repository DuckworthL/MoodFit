// lib/screens/main/workout_session_screen.dart - Active workout session with timer
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moodfit/models/workout_model.dart';
import 'package:moodfit/providers/auth_provider.dart';
import 'package:moodfit/screens/main/workout_complete_screen.dart';
import 'package:provider/provider.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutSessionScreen({super.key, required this.workout});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  int _currentExerciseIndex = 0;
  int _timeRemaining = 0;
  late Timer _timer;
  bool _isPaused = false;
  bool _isCountingDown = true;
  int _countdownValue = 3;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownValue--;
      });
      if (_countdownValue == 0) {
        _timer.cancel();
        _startExercise();
      }
    });
  }

  void _startExercise() {
    setState(() {
      _isCountingDown = false;
      _timeRemaining =
          widget.workout.exercises[_currentExerciseIndex].durationSeconds;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _timer.cancel();
          _moveToNextExercise();
        }
      });
    });
  }

  void _moveToNextExercise() {
    if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _timeRemaining =
            widget.workout.exercises[_currentExerciseIndex].durationSeconds;
      });
      _startTimer();
    } else {
      _timer.cancel();
      _completeWorkout();
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _completeWorkout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.uid != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutCompleteScreen(
            workout: widget.workout,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isCountingDown) {
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'GET READY',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                  ),
                  child: Center(
                    child: Text(
                      _countdownValue.toString(),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  widget.workout.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.workout.exercises.length} exercises - ${widget.workout.totalDurationMinutes} min',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentExercise = widget.workout.exercises[_currentExerciseIndex];
    final progress =
        (_currentExerciseIndex + 1) / widget.workout.exercises.length;
    final progressPercentage = (progress * 100).toInt();

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
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Quit Workout?'),
                            content: const Text(
                                'Are you sure you want to quit your workout session?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Quit'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _isPaused ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _togglePause,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Exercise Information
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      currentExercise.isRest ? 'REST' : 'EXERCISE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: currentExercise.isRest
                            ? Colors.blue
                            : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentExercise.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentExercise.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Timer
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Center(
                  child: Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.85),
                    ),
                    child: Center(
                      child: Text(
                        _formatTime(_timeRemaining),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: currentExercise.isRest
                              ? Colors.blue
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        color: Colors.white,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exercise ${_currentExerciseIndex + 1}/${widget.workout.exercises.length}',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$progressPercentage% Complete',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Next Exercise Preview
              if (_currentExerciseIndex < widget.workout.exercises.length - 1)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Up Next',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              widget.workout
                                  .exercises[_currentExerciseIndex + 1].name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatTime(widget
                            .workout
                            .exercises[_currentExerciseIndex + 1]
                            .durationSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.celebration,
                        color: Colors.white,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Last exercise! You\'re almost done!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _timer.cancel();
          _moveToNextExercise();
        },
        label: const Text('SKIP'),
        icon: const Icon(Icons.skip_next),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
