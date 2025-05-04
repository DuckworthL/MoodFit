// lib/presentation/screens/dashboard/dashboard_screen.dart - Main dashboard

import 'package:flutter/material.dart';
import 'package:moodfit/core/navigation/routes.dart';
import 'package:moodfit/data/models/mood_model.dart';
import 'package:moodfit/data/models/workout_model.dart';
import 'package:moodfit/presentation/common/breadcrumb.dart';
import 'package:moodfit/providers/auth_provider.dart';
import 'package:moodfit/providers/mood_provider.dart';
import 'package:moodfit/providers/workout_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MoodProvider>(context, listen: false).loadMoods();
      Provider.of<WorkoutProvider>(context, listen: false).loadWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgrounds/dashboard_bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.7,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.fitness_center,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'MoodFit',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          _showProfileMenu(context);
                        },
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            authProvider.user?.displayName?.substring(0, 1) ??
                                'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Breadcrumb
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Breadcrumb(
                    items: [BreadcrumbItem(label: 'Home', isActive: true)],
                  ),
                ),

                // Main Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await moodProvider.loadMoods();
                      await workoutProvider.loadWorkouts();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome section
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${authProvider.user?.displayName ?? 'there'}!',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'How are you feeling today?',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                      ).pushNamed(Routes.moodSelection);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 24,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Select Mood'),
                                        SizedBox(width: 8),
                                        Icon(Icons.mood, size: 20),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Quick Workouts
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Quick Workouts',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          SizedBox(
                            height: 180,
                            child:
                                workoutProvider.workouts.isEmpty
                                    ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                    : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      itemCount:
                                          workoutProvider
                                              .getQuickWorkouts()
                                              .length,
                                      itemBuilder: (context, index) {
                                        final workout =
                                            workoutProvider
                                                .getQuickWorkouts()[index];
                                        return _buildQuickWorkoutCard(workout);
                                      },
                                    ),
                          ),

                          const SizedBox(height: 24),

                          // Recent Moods
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Recent Moods',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(Routes.moodSelection);
                                  },
                                  child: const Text('See All'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          SizedBox(
                            height: 110,
                            child:
                                moodProvider.recentMoods.isEmpty
                                    ? ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      itemCount:
                                          moodProvider.moods.isEmpty
                                              ? 0
                                              : moodProvider.moods.length > 5
                                              ? 5
                                              : moodProvider.moods.length,
                                      itemBuilder: (context, index) {
                                        final mood = moodProvider.moods[index];
                                        return _buildMoodCard(mood);
                                      },
                                    )
                                    : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      itemCount:
                                          moodProvider.recentMoods.length,
                                      itemBuilder: (context, index) {
                                        final mood =
                                            moodProvider.recentMoods[index];
                                        return _buildMoodCard(mood);
                                      },
                                    ),
                          ),

                          const SizedBox(height: 24),

                          // Progress Stats
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Your Progress',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(Icons.insights),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStat(
                                        context,
                                        workoutProvider.completedWorkouts.length
                                            .toString(),
                                        'Workouts',
                                        Icons.fitness_center,
                                      ),
                                      _buildStat(
                                        context,
                                        workoutProvider
                                                .completedWorkouts
                                                .isNotEmpty
                                            ? (workoutProvider.completedWorkouts
                                                .map((w) => w.duration)
                                                .reduce(
                                                  (a, b) => a + b,
                                                )).toString()
                                            : '0',
                                        'Minutes',
                                        Icons.timer,
                                      ),
                                      _buildStat(
                                        context,
                                        moodProvider.recentMoods.length
                                            .toString(),
                                        'Moods',
                                        Icons.mood,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
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

  Widget _buildQuickWorkoutCard(WorkoutModel workout) {
    // Convert HEX color to Flutter Color
    Color cardColor;
    try {
      final hexColor =
          workout.type == 'HIIT'
              ? '#FF5733'
              : workout.type == 'Yoga'
              ? '#4CAF50'
              : workout.type == 'Dance'
              ? '#FFC300'
              : workout.type == 'Strength'
              ? '#2196F3'
              : '#9E9E9E';
      cardColor = Color(
        int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000,
      );
    } catch (e) {
      cardColor = Colors.blueGrey;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.quickWorkout,
          arguments: {'workoutId': workout.id, 'duration': workout.duration},
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: cardColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          // ignore: deprecated_member_use
          border: Border.all(color: cardColor.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 90,
                width: double.infinity,
                // ignore: deprecated_member_use
                color: cardColor.withOpacity(0.7),
                child: Center(
                  child: Icon(
                    workout.type == 'HIIT'
                        ? Icons.flash_on
                        : workout.type == 'Yoga'
                        ? Icons.self_improvement
                        : workout.type == 'Dance'
                        ? Icons.music_note
                        : Icons.fitness_center,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Workout Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.duration} min',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  Widget _buildMoodCard(MoodModel mood) {
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
        // Select this mood and navigate to workout recommendations
        final moodProvider = Provider.of<MoodProvider>(context, listen: false);
        moodProvider.selectMood(mood.id);
        Navigator.of(context).pushNamed(Routes.moodSelection);
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: cardColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              mood.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      authProvider.user?.displayName?.substring(0, 1) ?? 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.user?.displayName ?? 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          authProvider.user?.email ?? '',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Add navigation to the profile screen
                  Navigator.of(context).pushNamed(Routes.profile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Add navigation to the settings screen
                  Navigator.of(context).pushNamed(Routes.settings);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(Routes.login);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
