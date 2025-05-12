// lib/screens/main/create_workout_screen.dart - Create custom workouts
import 'package:flutter/material.dart';
import 'package:moodfit/models/mood_model.dart';
import 'package:moodfit/models/workout_model.dart';
import 'package:moodfit/providers/auth_provider.dart';
import 'package:moodfit/providers/workout_provider.dart';
import 'package:provider/provider.dart';

class CreateWorkoutScreen extends StatefulWidget {
  final WorkoutModel? editWorkout;

  const CreateWorkoutScreen({super.key, this.editWorkout});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  MoodType _selectedMoodType = MoodType.energetic;
  int _energyLevelRequired = 5;
  String _selectedBackgroundImage = 'assets/backgrounds/workout_bg.jpg';
  List<Exercise> _exercises = [];
  bool _isSubmitting = false;
  bool _isEditMode = false;

  final List<Map<String, String>> _backgroundImages = [
    {'path': 'assets/backgrounds/workout_bg.jpg', 'name': 'General'},
    {'path': 'assets/backgrounds/strength_bg.jpg', 'name': 'Strength'},
    {'path': 'assets/backgrounds/yoga_bg.jpg', 'name': 'Yoga'},
    {'path': 'assets/backgrounds/meditation_bg.jpg', 'name': 'Meditation'},
    {'path': 'assets/backgrounds/dance_bg.jpg', 'name': 'Dance'},
    {'path': 'assets/backgrounds/jogging_bg.jpg', 'name': 'Cardio'},
    {'path': 'assets/backgrounds/walking_bg.jpg', 'name': 'Walking'},
  ];

  @override
  void initState() {
    super.initState();

    // Determine if we're in edit mode and populate form fields
    if (widget.editWorkout != null) {
      _isEditMode = true;
      _nameController.text = widget.editWorkout!.name;
      _descriptionController.text = widget.editWorkout!.description;
      _selectedMoodType = widget.editWorkout!.recommendedMood;
      _energyLevelRequired = widget.editWorkout!.energyLevelRequired;
      _selectedBackgroundImage = widget.editWorkout!.backgroundImage;
      _exercises = List.from(widget.editWorkout!.exercises);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addExercise() {
    showDialog(
      context: context,
      builder: (context) => AddExerciseDialog(
        onAddExercise: (exercise) {
          setState(() {
            _exercises.add(exercise);
          });
        },
      ),
    );
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Exercise item = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, item);
    });
  }

  void _removeExerciseAt(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _editExerciseAt(int index) {
    final exercise = _exercises[index];
    showDialog(
      context: context,
      builder: (context) => AddExerciseDialog(
        exercise: exercise,
        onAddExercise: (updatedExercise) {
          setState(() {
            _exercises[index] = updatedExercise;
          });
        },
      ),
    );
  }

  Future<void> _saveWorkout() async {
    if (_formKey.currentState!.validate()) {
      if (_exercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one exercise'),
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final workoutProvider =
          Provider.of<WorkoutProvider>(context, listen: false);

      if (authProvider.uid != null) {
        bool result;

        if (_isEditMode && widget.editWorkout != null) {
          // Update existing workout
          result = await workoutProvider.updateWorkout(
            widget.editWorkout!.id,
            _nameController.text.trim(),
            _descriptionController.text.trim(),
            _exercises,
            _selectedMoodType,
            _energyLevelRequired,
            _selectedBackgroundImage,
            authProvider.uid!,
          );
        } else {
          // Create new workout
          result = await workoutProvider.createCustomWorkout(
            _nameController.text.trim(),
            _descriptionController.text.trim(),
            _exercises,
            _selectedMoodType,
            _energyLevelRequired,
            _selectedBackgroundImage,
            authProvider.uid!,
          );
        }

        if (result && mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditMode
                  ? 'Workout updated successfully'
                  : 'Workout created successfully'),
            ),
          );
        } else if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(workoutProvider.error ??
                  'Error ${_isEditMode ? 'updating' : 'creating'} workout'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() {
          _isSubmitting = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not authenticated'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Workout' : 'Create New Workout'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workout Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a workout name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Workout Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Describe your workout...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Mood Type Selection
              const Text(
                'Best for mood:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<MoodType>(
                value: _selectedMoodType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: MoodType.values.map((moodType) {
                  final mood = MoodModel(
                    id: '',
                    type: moodType,
                    energyLevel: 5,
                    timestamp: DateTime.now(),
                    userId: '',
                  );

                  return DropdownMenuItem<MoodType>(
                    value: moodType,
                    child: Row(
                      children: [
                        Icon(
                          mood.moodIcon,
                          color: mood.moodColor,
                        ),
                        const SizedBox(width: 8),
                        Text(moodType.toString().split('.').last),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMoodType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Energy Level Required
              const Text(
                'Energy level required:',
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
                      value: _energyLevelRequired.toDouble(),
                      label: _energyLevelRequired.toString(),
                      onChanged: (value) {
                        setState(() {
                          _energyLevelRequired = value.toInt();
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
              const SizedBox(height: 24),

              // Background Image Selection
              const Text(
                'Background Image:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _backgroundImages.length,
                  itemBuilder: (context, index) {
                    final image = _backgroundImages[index];
                    final isSelected =
                        _selectedBackgroundImage == image['path'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBackgroundImage = image['path']!;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.asset(
                                image['path']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.black26,
                              ),
                              child: Center(
                                child: Text(
                                  image['name']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Exercises Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Exercises:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Exercise'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_exercises.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'No exercises added yet.\nClick "Add Exercise" to add your first exercise.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _exercises.length,
                  onReorder: _reorderExercises,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return Card(
                      key: Key('$index'),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: exercise.isRest
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              exercise.isRest
                                  ? Icons.pause
                                  : Icons.fitness_center,
                              color:
                                  exercise.isRest ? Colors.blue : Colors.orange,
                            ),
                          ),
                        ),
                        title: Text(
                          exercise.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${exercise.durationSeconds}s'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editExerciseAt(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeExerciseAt(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveWorkout,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : Text(
                          _isEditMode ? 'Update Workout' : 'Save Workout',
                          style: const TextStyle(
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
    );
  }
}

class AddExerciseDialog extends StatefulWidget {
  final Function(Exercise) onAddExercise;
  final Exercise? exercise; // For editing mode

  const AddExerciseDialog({
    super.key,
    required this.onAddExercise,
    this.exercise,
  });

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _durationSeconds = 60;
  bool _isRest = false;
  String _selectedImage = 'assets/icons/dumbell.png';

  final List<String> _exerciseImages = [
    'assets/icons/dumbell.png',
    'assets/icons/jump_rope.png',
    'assets/icons/kettlebell.png',
    'assets/icons/yoga_mat.png',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      // Editing mode
      _nameController.text = widget.exercise!.name;
      _descriptionController.text = widget.exercise!.description;
      _durationSeconds = widget.exercise!.durationSeconds;
      _isRest = widget.exercise!.isRest;
      _selectedImage = widget.exercise!.imageAsset;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exercise != null ? 'Edit Exercise' : 'Add Exercise'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Type Switch
              Row(
                children: [
                  const Text('Exercise Type:'),
                  const Spacer(),
                  const Text('Exercise'),
                  Switch(
                    value: _isRest,
                    onChanged: (value) {
                      setState(() {
                        _isRest = value;
                        if (_isRest && _nameController.text.isEmpty) {
                          _nameController.text = 'Rest';
                        } else if (!_isRest &&
                            _nameController.text.toLowerCase() == 'rest') {
                          _nameController.text = '';
                        }
                      });
                    },
                  ),
                  const Text('Rest'),
                ],
              ),
              const SizedBox(height: 8),

              // Exercise Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an exercise name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Exercise Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'How to perform this exercise',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Duration
              const Text(
                'Duration (seconds):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _durationSeconds > 5
                        ? () => setState(() => _durationSeconds -= 5)
                        : null,
                  ),
                  Expanded(
                    child: Slider(
                      min: 5,
                      max: 180,
                      divisions: 35,
                      value: _durationSeconds.toDouble(),
                      label: '$_durationSeconds sec',
                      onChanged: (value) {
                        setState(() {
                          _durationSeconds = value.toInt();
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _durationSeconds < 180
                        ? () => setState(() => _durationSeconds += 5)
                        : null,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  '$_durationSeconds seconds',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // Image Selection (Only show for non-rest exercises)
              if (!_isRest) ...[
                const Text(
                  'Exercise Icon:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: _exerciseImages.map((image) {
                    final isSelected = _selectedImage == image;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = image;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                          color: isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : null,
                        ),
                        child: Image.asset(
                          image,
                          width: 40,
                          height: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final exercise = Exercise(
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim(),
                durationSeconds: _durationSeconds,
                imageAsset: _selectedImage,
                isRest: _isRest,
              );
              widget.onAddExercise(exercise);
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.exercise != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
