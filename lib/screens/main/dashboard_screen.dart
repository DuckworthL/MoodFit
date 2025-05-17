import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moodfit/models/mood_model.dart';
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
import 'package:moodfit/utils/theme_provider.dart';
import 'package:moodfit/utils/toast_util.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
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
        await workoutProvider.loadWorkouts();

        if (authProvider.uid != null) {
          try {
            await moodProvider.loadUserMoodsSimple(authProvider.uid!);
          } catch (e) {
            if (kDebugMode) {
              print('Error loading moods with simple method: $e');
            }
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
            try {
              await progressProvider.loadUserProgress(authProvider.uid!);
            } catch (e) {
              if (kDebugMode) {
                print('Both progress loading methods failed: $e');
              }
            }
          }

          await workoutProvider.loadUserCreatedWorkouts(authProvider.uid!);

          if (moodProvider.currentMood != null) {
            await workoutProvider.updateRecommendedWorkouts(
              moodProvider.currentMood!.type,
              moodProvider.currentMood!.energyLevel,
            );
          }

          _checkForAchievements(progressProvider);
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

  void _checkForAchievements(ProgressProvider progressProvider) {
    final workoutCount = progressProvider.getTotalWorkoutsCompleted();

    if (workoutCount > 0 && workoutCount % 5 == 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ToastUtil.showSnackBar(
            context: context,
            message:
                '🏆 Achievement Unlocked: $workoutCount workouts completed!',
            isSuccess: true,
            duration: const Duration(seconds: 5),
          );
        }
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/moodfit_logo.png',
                  height: 100,
                ),
                const SizedBox(height: 30),
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Loading your mood data...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
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
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon:
                  Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 1
                  ? Icons.fitness_center
                  : Icons.fitness_center_outlined),
              label: 'Workouts',
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 2
                  ? Icons.insert_chart
                  : Icons.insert_chart_outlined),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                  _selectedIndex == 3 ? Icons.person : Icons.person_outline),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final progressProvider = Provider.of<ProgressProvider>(context);

    final currentDate = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final hasCurrentMood = moodProvider.currentMood != null;
    final totalWorkoutsCompleted = progressProvider.getTotalWorkoutsCompleted();
    final totalMinutesWorkout = progressProvider.getTotalMinutesWorkout();
    final streak = _calculateStreak(progressProvider);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: hasCurrentMood
              ? AssetImage(moodProvider.currentMood!.backgroundImage)
              : const AssetImage('assets/backgrounds/dashboard_bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            colorScheme.background
                .withOpacity(theme.brightness == Brightness.dark ? 0.85 : 0.85),
            BlendMode.darken,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${authProvider.user?.name.split(' ').first ?? 'there'}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentDate,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  if (authProvider.user?.profilePicUrl != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()),
                        );
                      },
                      child: CircleAvatar(
                        radius: 26,
                        backgroundImage:
                            NetworkImage(authProvider.user!.profilePicUrl!),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()),
                        );
                      },
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: colorScheme.primary.withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          color: colorScheme.primary,
                          size: 30,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Motivational Quote Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Card(
                color: colorScheme.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _getRandomQuote(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Current Mood Card
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
              child:
                  _buildCurrentMoodCard(context, moodProvider, themeProvider),
            ),

            // Stats Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: _buildStatsBar(
                  context, totalWorkoutsCompleted, totalMinutesWorkout, streak),
            ),

            // Recommended Workouts / Recent Workouts Tabs
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: colorScheme.primary,
                      unselectedLabelColor:
                          colorScheme.onBackground.withOpacity(0.7),
                      indicatorColor: colorScheme.primary,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: const [
                        Tab(text: 'Recommended'),
                        Tab(text: 'Recent Workouts'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildRecommendedWorkoutsTab(
                            moodProvider,
                            workoutProvider,
                            hasCurrentMood,
                          ),
                          _buildRecentWorkoutsTab(
                              progressProvider, workoutProvider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentMoodCard(BuildContext context, MoodProvider moodProvider,
      ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasCurrentMood = moodProvider.currentMood != null;

    return Card(
      color: theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: hasCurrentMood
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          moodProvider.currentMood!.moodColor.withOpacity(0.17),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      moodProvider.currentMood!.moodIcon,
                      color: moodProvider.currentMood!.moodColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moodProvider.currentMood!.type
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: moodProvider.currentMood!.moodColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Updated ${_getMoodTime(moodProvider.currentMood!.timestamp)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text('Energy Level:',
                                style: theme.textTheme.bodyMedium),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildEnergyLevelIndicator(
                                moodProvider.currentMood!.energyLevel,
                                moodProvider.currentMood!.moodColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: Icon(Icons.edit, color: colorScheme.primary),
                    label: Text('Update',
                        style: TextStyle(color: colorScheme.primary)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MoodSelectionScreen()),
                      );
                    },
                  ),
                ],
              )
            : InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MoodSelectionScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.add_reaction_outlined,
                          size: 44, color: colorScheme.primary),
                      const SizedBox(height: 10),
                      Text('Select Your Mood',
                          style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Get personalized workout recommendations',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7))),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatsBar(
      BuildContext context, int totalWorkouts, int totalMinutes, int streak) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard(
                context, '$totalWorkouts', 'Workouts', Icons.fitness_center),
            Container(
                height: 40,
                width: 1,
                color: colorScheme.outline.withOpacity(0.4)),
            _buildStatCard(context, '$totalMinutes', 'Minutes', Icons.timer),
            Container(
                height: 40,
                width: 1,
                color: colorScheme.outline.withOpacity(0.4)),
            _buildStatCard(
                context, '$streak', 'Day Streak', Icons.local_fire_department),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String value, String label, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primary.withOpacity(0.18),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildRecommendedWorkoutsTab(
    MoodProvider moodProvider,
    WorkoutProvider workoutProvider,
    bool hasCurrentMood,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (hasCurrentMood && workoutProvider.recommendedWorkouts.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: workoutProvider.recommendedWorkouts.length,
          itemBuilder: (context, index) {
            final workout = workoutProvider.recommendedWorkouts[index];
            return _buildWorkoutCard(context, workout, index);
          },
        ),
      );
    } else if (hasCurrentMood) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.fitness_center,
                  color: colorScheme.primary, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'No recommended workouts yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create custom workouts or try updating your mood',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/create_workout');
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Workout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 4,
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mood, color: colorScheme.primary, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Select your mood first',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll recommend workouts based on how you feel',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoodSelectionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_reaction),
              label: const Text('Set Mood'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 4,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildRecentWorkoutsTab(
      ProgressProvider progressProvider, WorkoutProvider workoutProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (progressProvider.progressEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history, color: colorScheme.primary, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'No workout history yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your first workout to see it here',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: progressProvider.progressEntries.length > 5
            ? 5
            : progressProvider.progressEntries.length,
        itemBuilder: (context, index) {
          final entry = progressProvider.progressEntries[index];
          final beforeMood = MoodModel(
            id: '',
            type: entry.moodBefore,
            energyLevel: entry.energyLevelBefore,
            timestamp: entry.completedAt,
            userId: entry.userId,
          );
          final afterMood = entry.moodAfter != null
              ? MoodModel(
                  id: '',
                  type: entry.moodAfter!,
                  energyLevel: entry.energyLevelAfter ?? 5,
                  timestamp: entry.completedAt,
                  userId: entry.userId,
                )
              : null;

          WorkoutModel? workout;
          try {
            workout = workoutProvider.workouts.firstWhere(
              (w) => w.id == entry.workoutId,
            );
          } catch (e) {
            workout = null;
          }

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (workout != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutDetailScreen(workout: workout!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Workout details not found.")),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(isDark ? 0.5 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: colorScheme.primary.withOpacity(0.14),
                  child: Icon(
                    Icons.fitness_center,
                    color: colorScheme.primary,
                  ),
                ),
                title: Text(
                  entry.workoutName,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM d, y • h:mm a').format(entry.completedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(beforeMood.moodIcon,
                            color: beforeMood.moodColor, size: 16),
                        const Icon(Icons.arrow_right, size: 16),
                        if (afterMood != null)
                          Icon(afterMood.moodIcon,
                              color: afterMood.moodColor, size: 16),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${entry.durationMinutes} min',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Icon(Icons.chevron_right,
                    color: colorScheme.primary, size: 28),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnergyLevelIndicator(int level, Color color) {
    return Row(
      children: List.generate(
        10,
        (index) => Expanded(
          child: Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: index < level
                  ? color.withOpacity(0.7 + ((index / 10) * 0.3))
                  : Colors.grey.shade300,
            ),
          ),
        ),
      ),
    );
  }

  int _calculateStreak(ProgressProvider progressProvider) {
    final entries = progressProvider.progressEntries;
    if (entries.isEmpty) return 0;

    entries.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    bool hasWorkoutToday = entries.any((entry) =>
        entry.completedAt.isAfter(todayStart) ||
        entry.completedAt.isAtSameMomentAs(todayStart));

    if (!hasWorkoutToday) {
      final yesterday = todayStart.subtract(const Duration(days: 1));
      bool hasWorkoutYesterday = entries.any((entry) {
        final entryDate = DateTime(entry.completedAt.year,
            entry.completedAt.month, entry.completedAt.day);
        return entryDate.isAtSameMomentAs(yesterday);
      });
      if (!hasWorkoutYesterday) return 0;
    }

    int streak = hasWorkoutToday ? 1 : 0;
    DateTime currentDate = hasWorkoutToday
        ? todayStart
        : todayStart.subtract(const Duration(days: 1));

    while (true) {
      final previousDay = currentDate.subtract(const Duration(days: 1));
      bool hasPreviousDayWorkout = entries.any((entry) {
        final entryDate = DateTime(entry.completedAt.year,
            entry.completedAt.month, entry.completedAt.day);
        return entryDate.isAtSameMomentAs(previousDay);
      });

      if (hasPreviousDayWorkout) {
        streak++;
        currentDate = previousDay;
      } else {
        break;
      }
    }

    return streak;
  }

  String _getMoodTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return DateFormat.yMMMd().format(timestamp);
    }
  }

  Widget _buildWorkoutCard(
      BuildContext context, WorkoutModel workout, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final cardWidget = Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
        child: Stack(
          children: [
            Container(
              height: 140,
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
            ),
            Container(
              height: 140,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (workout.isQuickWorkout())
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: themeProvider.primaryColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Quick',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getDifficultyIcon(workout.energyLevelRequired),
                              color: _getDifficultyColor(
                                  workout.energyLevelRequired),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getDifficultyText(workout.energyLevelRequired),
                              style: TextStyle(
                                color: _getDifficultyColor(
                                    workout.energyLevelRequired),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
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
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.fitness_center,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${workout.exercises.length} exercises',
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
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

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: cardWidget,
    );
  }

  IconData _getDifficultyIcon(int energyLevel) {
    if (energyLevel <= 3) return Icons.spa;
    if (energyLevel <= 6) return Icons.directions_run;
    return Icons.whatshot;
  }

  Color _getDifficultyColor(int energyLevel) {
    if (energyLevel <= 3) return Colors.green;
    if (energyLevel <= 6) return Colors.orange;
    return Colors.red;
  }

  String _getDifficultyText(int energyLevel) {
    if (energyLevel <= 3) return 'Easy';
    if (energyLevel <= 6) return 'Medium';
    return 'Hard';
  }

  String _getRandomQuote() {
    final quotes = [
      "The body achieves what the mind believes.",
      "You don't have to be extreme, just consistent.",
      "The only bad workout is the one that didn't happen.",
      "Your mood is a choice. Choose wisely.",
      "Small steps lead to big changes.",
      "Your energy introduces you before you even speak.",
      "Take care of your body. It's the only place you have to live.",
      "Movement is a medicine for creating change.",
      "The difference between try and triumph is a little umph.",
      "Your body hears everything your mind says.",
    ];
    quotes.shuffle();
    return quotes.first;
  }
}
