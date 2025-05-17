import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:moodfit/models/workout_model.dart';
import 'package:moodfit/providers/auth_provider.dart';
import 'package:moodfit/screens/main/workout_complete_screen.dart';
import 'package:moodfit/utils/toast_util.dart';
import 'package:provider/provider.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutModel workout;
  final int? caloriesBurned;

  const WorkoutSessionScreen({
    super.key, 
    required this.workout,
    this.caloriesBurned,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> with TickerProviderStateMixin {
  int _currentExerciseIndex = 0;
  int _timeRemaining = 0;
  late Timer _timer;
  bool _isPaused = false;
  bool _isCountingDown = true;
  int _countdownValue = 3;
  double _progress = 0.0;
  late AnimationController _pulseAnimationController;
  late AnimationController _countdownAnimationController;
  bool _isHalfwayDone = false;
  int _totalCaloriesBurned = 0;
  
  // Estimated calories per minute based on exercise type
  final Map<String, double> _caloriesPerMinute = {
    'jumping jacks': 8.0,
    'high knees': 9.0,
    'burpees': 10.0,
    'mountain climbers': 9.0,
    'squat': 7.0,
    'plank': 5.0,
    'push': 8.0,
    'crunch': 5.0,
    'lunge': 6.0,
    'rest': 1.0,
    'default': 4.0,
  };

  @override
  void initState() {
    super.initState();
    
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _countdownAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    _startCountdown();
  }

  void _startCountdown() {
    _countdownAnimationController.reset();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownAnimationController.forward(from: 0.0);
      
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
      _timeRemaining = widget.workout.exercises[_currentExerciseIndex].durationSeconds;
      _progress = 0.0;
    });
    
    _startTimer();
  }

  void _startTimer() {
    final totalDuration = widget.workout.exercises[_currentExerciseIndex].durationSeconds;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
          _progress = 1 - (_timeRemaining / totalDuration);
          
          // Mark halfway point
          if (!_isHalfwayDone && _timeRemaining <= totalDuration ~/ 2) {
            _isHalfwayDone = true;
          }
          
          // Calculate calories burned
          _updateCaloriesBurned();
        } else {
          _timer.cancel();
          _moveToNextExercise();
        }
      });
    });
  }
  
  void _updateCaloriesBurned() {
    // Estimate calories based on exercise type and duration
    if (!_isPaused) {
      final currentExercise = widget.workout.exercises[_currentExerciseIndex];
      final exerciseName = currentExercise.name.toLowerCase();
      
      // Find calories per minute for this exercise type
      double calsPerMinute = _caloriesPerMinute['default']!;
      for (var key in _caloriesPerMinute.keys) {
        if (exerciseName.contains(key)) {
          calsPerMinute = _caloriesPerMinute[key]!;
          break;
        }
      }
      
      // Convert to calories per second
      double calsPerSecond = calsPerMinute / 60;
      
      // Add to total
      _totalCaloriesBurned += calsPerSecond.round();
    }
  }

  void _moveToNextExercise() {
    if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _timeRemaining = widget.workout.exercises[_currentExerciseIndex].durationSeconds;
        _progress = 0.0;
        _isHalfwayDone = false;
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
            caloriesBurned: _totalCaloriesBurned,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseAnimationController.dispose();
    _countdownAnimationController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
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
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _countdownAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: Tween<double>(begin: 1.0, end: 1.5)
                          .animate(CurvedAnimation(
                            parent: _countdownAnimationController,
                            curve: Curves.easeOutBack,
                          ))
                          .value,
                      child: child,
                    );
                  },
                  child: Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _countdownValue.toString(),
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  widget.workout.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.workout.exercises.length} exercises - ${widget.workout.totalDurationMinutes} min',
                  style: const TextStyle(
                    fontSize: 18,
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
    final totalExercises = widget.workout.exercises.length;
    final completionProgress = (_currentExerciseIndex + _progress) / totalExercises;
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                            ToastUtil.showConfirmationDialog(
                              context: context,
                              title: 'Quit Workout?',
                              message: 'Are you sure you want to quit? Your progress will be lost.',
                              confirmText: 'Quit',
                              cancelText: 'Cancel',
                              isDestructive: true,
                            ).then((quit) {
                              if (quit) {
                                Navigator.pop(context);
                              }
                            });
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

                  // Overall Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 8,
                          width: MediaQuery.of(context).size.width * 
                            completionProgress * 0.9, // Accounting for padding
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exercise ${_currentExerciseIndex + 1}/$totalExercises',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '${(completionProgress * 100).toInt()}% Complete',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Exercise Information Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: currentExercise.isRest
                                    ? Colors.blue.withOpacity(0.2)
                                    : Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                currentExercise.isRest ? 'REST TIME' : 'EXERCISE',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: currentExercise.isRest
                                      ? Colors.blue
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Exercise name with animation
                        AnimatedBuilder(
                          animation: _pulseAnimationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: currentExercise.isRest
                                ? 1.0
                                : Tween<double>(begin: 1.0, end: 1.05)
                                    .animate(CurvedAnimation(
                                      parent: _pulseAnimationController,
                                      curve: Curves.easeInOut,
                                    ))
                                    .value,
                              child: child,
                            );
                          },
                          child: Text(
                            currentExercise.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: currentExercise.isRest
                                  ? Colors.blue
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        Text(
                          currentExercise.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        if (!currentExercise.isRest && !_isPaused)
                          Text(
                            _getMotivationalText(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: primaryColor,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Timer Circle
                  Center(
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Center(
                        child: Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.85),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Progress circle
                              SizedBox(
                                height: 180,
                                width: 180,
                                child: CircularProgressIndicator(
                                  value: _progress,
                                  strokeWidth: 12,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    currentExercise.isRest
                                        ? Colors.blue
                                        : primaryColor,
                                  ),
                                ),
                              ),
                              
                              // Timer text
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatTime(_timeRemaining),
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: currentExercise.isRest
                                          ? Colors.blue
                                          : primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'seconds left',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Next Exercise Preview
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _currentExerciseIndex < widget.workout.exercises.length - 1
                          ? Row(
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
                                        widget.workout.exercises[_currentExerciseIndex + 1].name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatTime(widget.workout.exercises[_currentExerciseIndex + 1].durationSeconds),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.celebration,
                                                                        color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Last exercise! Finish strong!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _timer.cancel();
          _moveToNextExercise();
        },
        icon: const Icon(Icons.skip_next),
        label: const Text('SKIP'),
        elevation: 8,
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  String _getMotivationalText() {
    final motivationalTexts = [
      "Keep pushing, you're doing great!",
      "Stay focused, every rep counts!",
      "You're stronger than you think!",
      "Mind over matter, you can do this!",
      "Embrace the burn, it means it's working!",
      "Challenge yourself, transform yourself!",
      "You'll never regret a good workout!",
      "When it burns, you're building!",
      "Don't stop when you're tired, stop when you're done!",
      "This is your time to shine!",
    ];

    final random = Random();
    return motivationalTexts[random.nextInt(motivationalTexts.length)];
  }
}
