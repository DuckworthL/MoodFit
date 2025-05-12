// lib/screens/main/workouts_screen.dart - Browse and manage workouts
import 'package:flutter/material.dart';
import 'package:moodfit/models/mood_model.dart';
import 'package:moodfit/models/workout_model.dart';
import 'package:moodfit/providers/workout_provider.dart';
import 'package:moodfit/screens/main/create_workout_screen.dart';
import 'package:moodfit/screens/main/workout_detail_screen.dart';
import 'package:moodfit/screens/main/workout_list_screen.dart';
import 'package:provider/provider.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<WorkoutModel> _filterWorkouts(List<WorkoutModel> workouts) {
    if (_searchController.text.isEmpty) {
      return workouts;
    }

    final searchTerm = _searchController.text.toLowerCase();
    return workouts.where((workout) {
      return workout.name.toLowerCase().contains(searchTerm) ||
          workout.description.toLowerCase().contains(searchTerm);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    // Filter workouts based on search
    final allWorkouts = _filterWorkouts(workoutProvider.workouts);
    final quickWorkouts = _filterWorkouts(workoutProvider.getQuickWorkouts());

    // Group workouts by mood type
    Map<MoodType, List<WorkoutModel>> moodWorkouts = {};
    for (var moodType in MoodType.values) {
      moodWorkouts[moodType] = _filterWorkouts(workoutProvider.workouts
          .where((w) => w.recommendedMood == moodType)
          .toList());
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearchMode
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search workouts...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isSearchMode = false;
                      });
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
              )
            : const Text('Workouts'),
        actions: [
          if (!_isSearchMode)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearchMode = true;
                });
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Quick'),
            Tab(text: 'By Mood'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Manage Workouts button
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('Manage My Workouts'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkoutListScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Workouts Tab
                _buildWorkoutList(allWorkouts),

                // Quick Workouts Tab
                _buildWorkoutList(quickWorkouts),

                // By Mood Tab
                _buildMoodFilteredWorkouts(moodWorkouts),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateWorkoutScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWorkoutList(List<WorkoutModel> workouts) {
    if (workouts.isEmpty) {
      return const Center(
        child: Text('No workouts found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return _buildWorkoutCard(workout);
      },
    );
  }

  Widget _buildMoodFilteredWorkouts(
      Map<MoodType, List<WorkoutModel>> moodWorkouts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: MoodType.values.map((moodType) {
          final workouts = moodWorkouts[moodType] ?? [];
          if (workouts.isEmpty) {
            return Container();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  moodType.toString().split('.').last.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...workouts.map((workout) => _buildWorkoutCard(workout)).toList(),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutModel workout) {
    final MoodModel moodModel = MoodModel(
      id: '',
      type: workout.recommendedMood,
      energyLevel: workout.energyLevelRequired,
      timestamp: DateTime.now(),
      userId: '',
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Provider.of<WorkoutProvider>(context, listen: false)
              .setCurrentWorkout(workout);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailScreen(workout: workout),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(workout.backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: moodModel.moodColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          workout.recommendedMood.toString().split('.').last,
                          style: TextStyle(
                            color: moodModel.moodColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workout.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.totalDurationMinutes} min',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.exercises.length} exercises',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
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
}
