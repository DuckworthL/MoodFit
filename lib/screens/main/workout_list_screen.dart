import 'package:flutter/material.dart';
import 'package:moodfit/models/workout_model.dart';
import 'package:moodfit/providers/workout_provider.dart';
import 'package:moodfit/screens/main/create_workout_screen.dart';
import 'package:moodfit/screens/main/workout_detail_screen.dart';
import 'package:provider/provider.dart';

import '../../toast_util.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<WorkoutProvider>(context, listen: false)
          .loadUserWorkouts();
    } catch (e) {
      if (mounted) {
        ToastUtil.showErrorToast('Error loading workouts: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _confirmDeleteWorkout(WorkoutModel workout) async {
    final confirmed = await ToastUtil.showConfirmationDialog(
      context: context,
      title: 'Delete Workout',
      message: 'Are you sure you want to delete "${workout.name}"?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (!confirmed) return;

    try {
      // ignore: use_build_context_synchronously
      final result = await Provider.of<WorkoutProvider>(context, listen: false)
          .deleteWorkout(workout.id, workout.name);

      if (mounted) {
        if (result['success']) {
          ToastUtil.showSuccessToast(result['message']);
        } else {
          ToastUtil.showErrorToast(result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showErrorToast('Error deleting workout: $e');
      }
    }
  }

  void _navigateToCreateWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateWorkoutScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadWorkouts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateWorkout,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<WorkoutProvider>(
              builder: (context, workoutProvider, child) {
                final userWorkouts = workoutProvider.userWorkouts;

                if (userWorkouts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No workouts created yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the + button to create your first workout',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _navigateToCreateWorkout,
                          child: const Text('Create Workout'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadWorkouts,
                  child: ListView.builder(
                    itemCount: userWorkouts.length,
                    itemBuilder: (context, index) {
                      final workout = userWorkouts[index];
                      return Dismissible(
                        key: Key(workout.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await ToastUtil.showConfirmationDialog(
                            context: context,
                            title: 'Delete Workout',
                            message:
                                'Are you sure you want to delete "${workout.name}"?',
                            confirmText: 'Delete',
                            isDestructive: true,
                          );
                        },
                        onDismissed: (direction) async {
                          final result = await workoutProvider.deleteWorkout(
                              workout.id, workout.name);

                          if (result['success']) {
                            ToastUtil.showSuccessToast(result['message']);
                          } else {
                            // If there's an error, we should show an error toast
                            ToastUtil.showErrorToast(result['message']);
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              child: Icon(
                                Icons.fitness_center,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            title: Text(
                              workout.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${workout.exercises.length} exercises • ${workout.totalDurationMinutes} min',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  tooltip: 'Edit',
                                  onPressed: () async {
                                    final confirmed =
                                        await ToastUtil.showConfirmationDialog(
                                      context: context,
                                      title: 'Edit Workout',
                                      message:
                                          'Do you want to edit "${workout.name}"?',
                                      confirmText: 'Edit',
                                    );

                                    if (confirmed) {
                                      // Navigate to edit workout (reuse create screen)
                                      // ignore: use_build_context_synchronously
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreateWorkoutScreen(
                                            editWorkout: workout,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  tooltip: 'Delete',
                                  onPressed: () =>
                                      _confirmDeleteWorkout(workout),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkoutDetailScreen(
                                    workout: workout,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
