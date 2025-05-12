// lib/screens/main/dashboard_screen.dart - Main application dashboard
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moodfit/models/workout_model.dart';
import 'package:moodfit/providers/auth_provider.dart';
import 'package:moodfit/providers/mood_provider.dart';
import 'package:moodfit/providers/progress_provider.dart';
import 'package:moodfit/providers/workout_provider.dart';
import 'package:moodfit/screens/main/mood_selection_screen.dart';
import 'package:moodfit/screens/main/profile_screen.dart';
import 'package:moodfit/screens/main/progress_screen.dart';
import 'package:moodfit/screens/main/workout_detail_screen.dart';
import 'package:moodfit/screens/main/workouts_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // IMPORTANT: Not 'final' anymore so we can update it
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Use WidgetsBinding to schedule work after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      final workoutProvider =
          Provider.of<WorkoutProvider>(context, listen: false);
      final progressProvider =
          Provider.of<ProgressProvider>(context, listen: false);

      try {
        // Load workouts first (they don't depend on user mood)
        await workoutProvider.loadWorkouts();

        if (authProvider.uid != null) {
          // Try loading using the simple methods first
          try {
            await moodProvider.loadUserMoodsSimple(authProvider.uid!);
          } catch (e) {
            if (kDebugMode) {
              print('Error loading moods with simple method: $e');
            }
            // Try the normal method as fallback
            try {
              await moodProvider.loadUserMoods(authProvider.uid!);
            } catch (e) {
              if (kDebugMode) {
                print('Both mood loading methods failed: $e');
              }
            }
          }

          try {
            await progressProvider.loadUserProgressSimple(authProvider.uid!);
          } catch (e) {
            if (kDebugMode) {
              print('Error loading progress with simple method: $e');
            }
            // Try the normal method as fallback
            try {
              await progressProvider.loadUserProgress(authProvider.uid!);
            } catch (e) {
              if (kDebugMode) {
                print('Both progress loading methods failed: $e');
              }
            }
          }

          await workoutProvider.loadUserCreatedWorkouts(authProvider.uid!);

          // Update recommended workouts based on current mood if available
          if (moodProvider.currentMood != null) {
            await workoutProvider.updateRecommendedWorkouts(
              moodProvider.currentMood!.type,
              moodProvider.currentMood!.energyLevel,
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error loading data: $e');
        }
        _error = e.toString();
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  // Fixed onItemTapped method to actually change the screen
  void _onItemTapped(int index) {
    if (kDebugMode) {
      print('Tab tapped: $index');
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeTab(),
      const WorkoutsScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/backgrounds/dashboard_bg.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black45,
                BlendMode.darken,
              ),
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/backgrounds/dashboard_bg.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black45,
                BlendMode.darken,
              ),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Error loading data',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      // Use IndexedStack to preserve state when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final progressProvider = Provider.of<ProgressProvider>(context);

    final currentDate = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final hasCurrentMood = moodProvider.currentMood != null;
    final totalWorkoutsCompleted = progressProvider.getTotalWorkoutsCompleted();
    final totalMinutesWorkout = progressProvider.getTotalMinutesWorkout();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: hasCurrentMood
              ? AssetImage(moodProvider.currentMood!.backgroundImage)
              : const AssetImage('assets/backgrounds/dashboard_bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(
            Colors.black45,
            BlendMode.darken,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${authProvider.user?.name.split(' ').first ?? 'there'}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentDate,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    if (authProvider.user?.profilePicUrl != null)
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          authProvider.user!.profilePicUrl!,
                        ),
                      )
                    else
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),

              // Current Mood Card
              Card(
                margin: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white.withOpacity(0.85),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Mood',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Update'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MoodSelectionScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (hasCurrentMood)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: moodProvider.currentMood!.moodColor
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                moodProvider.currentMood!.moodIcon,
                                color: moodProvider.currentMood!.moodColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  moodProvider.currentMood!.type
                                      .toString()
                                      .split('.')
                                      .last
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text('Energy Level:'),
                                    const SizedBox(width: 8),
                                    _buildEnergyLevelIndicator(
                                        moodProvider.currentMood!.energyLevel),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MoodSelectionScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.add_reaction_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Select Your Mood',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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

              // Recommended Workouts Section
              if (hasCurrentMood &&
                  workoutProvider.recommendedWorkouts.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                        child: Text(
                          'Recommended for your ${moodProvider.currentMood!.type.toString().split('.').last} mood',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: workoutProvider.recommendedWorkouts.length,
                          itemBuilder: (context, index) {
                            final workout =
                                workoutProvider.recommendedWorkouts[index];
                            return _buildWorkoutCard(context, workout);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              else if (hasCurrentMood)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No recommended workouts yet.\nTry updating your mood or creating custom workouts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text(
                      'Select your mood to get personalized workout recommendations',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),

              // Stats Bar
              Card(
                margin: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white.withOpacity(0.85),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('$totalWorkoutsCompleted', 'Workouts'),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      _buildStatColumn('$totalMinutesWorkout', 'Minutes'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnergyLevelIndicator(int level) {
    return Row(
      children: List.generate(
        10,
        (index) => Container(
          width: 8,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: index < level ? Colors.green : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(BuildContext context, WorkoutModel workout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigate to workout detail
          Provider.of<WorkoutProvider>(context, listen: false)
              .setCurrentWorkout(workout);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailScreen(workout: workout),
            ),
          );
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(workout.backgroundImage),
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(
                Colors.black45,
                BlendMode.darken,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  workout.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${workout.totalDurationMinutes} min',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (workout.isQuickWorkout())
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Quick',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
