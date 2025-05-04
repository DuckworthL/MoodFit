// lib/presentation/screens/mood_selection/mood_selection_screen.dart - Mood selection screen

import 'package:flutter/material.dart';
import 'package:moodfit/core/navigation/routes.dart';
import 'package:moodfit/data/models/mood_model.dart';
import 'package:moodfit/data/models/workout_model.dart';
import 'package:moodfit/presentation/common/breadcrumb.dart';
import 'package:moodfit/presentation/common/loading_indicator.dart';
import 'package:moodfit/providers/mood_provider.dart';
import 'package:moodfit/providers/workout_provider.dart';
import 'package:provider/provider.dart';

class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Ensure moods and workouts are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      final workoutProvider = Provider.of<WorkoutProvider>(
        context,
        listen: false,
      );

      if (moodProvider.moods.isEmpty) {
        moodProvider.loadMoods();
      }

      if (workoutProvider.workouts.isEmpty) {
        workoutProvider.loadWorkouts();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
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
                      'Mood & Workouts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  BreadcrumbItem(label: 'Mood Selection', isActive: true),
                ],
              ),
            ),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Theme.of(context).primaryColor,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [Tab(text: 'Moods'), Tab(text: 'Workouts')],
                ),
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Moods Tab
                  moodProvider.isLoading
                      ? const LoadingIndicator(message: 'Loading moods...')
                      : _buildMoodsGrid(moodProvider.moods),

                  // Workouts Tab (based on selected mood or all workouts)
                  moodProvider.selectedMood == null
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.mood,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Select a mood first',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _tabController.animateTo(0);
                              },
                              child: const Text('Go to Moods'),
                            ),
                          ],
                        ),
                      )
                      : workoutProvider.isLoading
                      ? const LoadingIndicator(message: 'Loading workouts...')
                      : _buildWorkoutsList(
                        workoutProvider.getWorkoutsForMood(
                          moodProvider.selectedMood!.id,
                        ),
                        moodProvider.selectedMood!,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodsGrid(List<MoodModel> moods) {
    if (moods.isEmpty) {
      return const Center(child: Text('No moods available'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: moods.length,
      itemBuilder: (context, index) {
        final mood = moods[index];
        return _buildMoodCard(mood);
      },
    );
  }

  Widget _buildMoodCard(MoodModel mood) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final isSelected = moodProvider.selectedMood?.id == mood.id;

    // Convert HEX color to Flutter Color
    Color cardColor;
    try {
      cardColor = Color(
        int.parse(mood.color.substring(1, 7), radix: 16) + 0xFF000000,
      );
    } catch (e) {
      cardColor = Colors.blueGrey;
    }

    return GestureDetector(
      onTap: () {
        moodProvider.selectMood(mood.id);
        _tabController.animateTo(1); // Switch to workouts tab
      },
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected
                  // ignore: deprecated_member_use
                  ? cardColor.withOpacity(0.3)
                  // ignore: deprecated_member_use
                  : cardColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // ignore: deprecated_member_use
            color: isSelected ? cardColor : cardColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              mood.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                mood.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: cardColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Selected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutsList(
    List<WorkoutModel> workouts,
    MoodModel selectedMood,
  ) {
    if (workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No workouts for ${selectedMood.name} mood',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _tabController.animateTo(0);
              },
              child: const Text('Try another mood'),
            ),
          ],
        ),
      );
    }

    Color moodColor;
    try {
      moodColor = Color(
        int.parse(selectedMood.color.substring(1, 7), radix: 16) + 0xFF000000,
      );
    } catch (e) {
      moodColor = Colors.blueGrey;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected mood info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: moodColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              // ignore: deprecated_member_use
              border: Border.all(color: moodColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: moodColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: moodColor),
                  ),
                  child: Center(
                    child: Text(
                      selectedMood.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedMood.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedMood.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recommended workouts heading
          const Text(
            'Recommended Workouts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Workouts list
          ...workouts.map((workout) => _buildWorkoutCard(workout)),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutModel workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).pushNamed(
              Routes.workoutDetails,
              arguments: {
                'workoutId': workout.id,
                'mood':
                    Provider.of<MoodProvider>(
                      context,
                      listen: false,
                    ).selectedMood,
              },
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workout image/header
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  // ignore: deprecated_member_use
                  color: _getWorkoutColor(workout.type).withOpacity(0.7),
                ),
                child: Center(
                  child: Icon(
                    _getWorkoutIcon(workout.type),
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),

              // Workout info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            workout.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getWorkoutColor(
                              workout.type,
                              // ignore: deprecated_member_use
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getWorkoutColor(
                                workout.type,
                                // ignore: deprecated_member_use
                              ).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            workout.type,
                            style: TextStyle(
                              color: _getWorkoutColor(workout.type),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      workout.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildWorkoutInfoChip(
                          Icons.timer,
                          '${workout.duration} min',
                        ),
                        const SizedBox(width: 16),
                        _buildWorkoutInfoChip(
                          Icons.whatshot,
                          workout.intensity.toUpperCase(),
                        ),
                        const SizedBox(width: 16),
                        _buildWorkoutInfoChip(
                          Icons.fitness_center,
                          '${workout.exercises.length} exercises',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
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
