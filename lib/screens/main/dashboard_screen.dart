import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import 'package:moodfit/utils/design_system.dart';
import 'package:moodfit/utils/theme_provider.dart';
import 'package:moodfit/utils/toast_util.dart';
import 'package:moodfit/widgets/mood_fit_card.dart';
import 'package:moodfit/widgets/mood_fit_button.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
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
          await moodProvider.loadUserMoods(authProvider.uid!);
          await progressProvider.loadUserProgress(authProvider.uid!);
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
  Widget build(BuildContext context) {
    final screens = [
      const HomeTab(),
      const WorkoutsScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_error != null) {
      return _buildErrorScreen();
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLoadingScreen() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: MoodFitDesignSystem.backgroundDecoration(
          context,
          assetPath: 'assets/backgrounds/dashboard_bg.jpg',
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/moodfit_logo.png',
                  height: 100,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  backgroundColor: colorScheme.primary.withOpacity(0.3),
                  strokeWidth: 6,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading your mood data...',
                style: MoodFitDesignSystem.subtitle1(context).copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
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

  Widget _buildErrorScreen() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: MoodFitDesignSystem.backgroundDecoration(
          context,
          assetPath: 'assets/backgrounds/dashboard_bg.jpg',
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: MoodFitCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.error,
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Error Loading Data',
                    style: MoodFitDesignSystem.heading3(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: MoodFitDesignSystem.body1(context).copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  MoodFitButton(
                    label: 'Try Again',
                    onPressed: _loadData,
                    icon: Icons.refresh,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 0
                  ? Icons.home_rounded
                  : Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 1
                  ? Icons.fitness_center_rounded
                  : Icons.fitness_center_outlined),
              label: 'Workouts',
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 2
                  ? Icons.insert_chart_rounded
                  : Icons.insert_chart_outlined),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 3
                  ? Icons.person_rounded
                  : Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor:
              isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
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
  final List<String> _motivationalQuotes = [
    "Your mood doesn't have to determine your day, but it can guide your workout.",
    "Exercise is a celebration of what your body can do, not a punishment for what you ate.",
    "The only bad workout is the one that didn't happen.",
    "Fitness is not about being better than someone else, it's about being better than you used to be.",
    "Take care of your body. It's the only place you have to live.",
    "The mind leads the body. Your mood is your greatest ally.",
    "Whether you're sad, happy, tired, or energetic—there's a workout for that.",
    "The only way to find your perfect workout is to listen to your body.",
    "Some days it's okay to take it easy. Other days, push your limits.",
    "Movement is medicine for changing your mood."
  ];

  String get _randomQuote => _motivationalQuotes[
      DateTime.now().millisecond % _motivationalQuotes.length];

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
    final isDark = theme.brightness == Brightness.dark;

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
            isDark
                ? Colors.black.withOpacity(0.85)
                : Colors.black.withOpacity(0.65),
            BlendMode.darken,
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
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
                          style: MoodFitDesignSystem.heading2(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentDate,
                          style: MoodFitDesignSystem.body1(context).copyWith(
                            color: Colors.white.withOpacity(0.9),
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _buildProfileAvatar(authProvider),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Motivational Quote Card
                    _buildQuoteCard(),

                    const SizedBox(height: 16),

                    // Current Mood Card
                    _buildCurrentMoodCard(context, moodProvider, themeProvider),

                    const SizedBox(height: 16),

                    // Stats Bar
                    _buildStatsBar(context, totalWorkoutsCompleted,
                        totalMinutesWorkout, streak),

                    const SizedBox(height: 24),

                    // Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withOpacity(0.4)
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withOpacity(0.6),
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelStyle:
                            MoodFitDesignSystem.subtitle2(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle:
                            MoodFitDesignSystem.subtitle2(context),
                        tabs: const [
                          Tab(text: 'Recommended'),
                          Tab(text: 'Recent Workouts'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tab content
                    SizedBox(
                      height: 400, // Fixed height for tab content
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(AuthProvider authProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: authProvider.user?.profilePicUrl != null
            ? CircleAvatar(
                radius: 26,
                backgroundImage:
                    NetworkImage(authProvider.user!.profilePicUrl!),
              )
            : CircleAvatar(
                radius: 26,
                backgroundColor: colorScheme.primary.withOpacity(0.8),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
      ),
    );
  }

  Widget _buildQuoteCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.8),
            colorScheme.primary.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.format_quote,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _randomQuote,
              style: MoodFitDesignSystem.body1(context).copyWith(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMoodCard(BuildContext context, MoodProvider moodProvider,
      ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasCurrentMood = moodProvider.currentMood != null;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.7)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: hasCurrentMood
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: moodProvider.currentMood!.moodColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: moodProvider.currentMood!.moodColor
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                        style: MoodFitDesignSystem.subtitle1(context).copyWith(
                          color: moodProvider.currentMood!.moodColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Updated ${_getMoodTime(moodProvider.currentMood!.timestamp)}',
                        style: MoodFitDesignSystem.caption(context).copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Energy:',
                            style: MoodFitDesignSystem.body2(context).copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
                MoodFitButton(
                  label: 'Update',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MoodSelectionScreen()),
                    );
                  },
                  type: MoodFitButtonType.secondary,
                  icon: Icons.edit,
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_reaction_outlined,
                        size: 44,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'How are you feeling today?',
                      style: MoodFitDesignSystem.subtitle1(context).copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your mood to get personalized workouts',
                      style: MoodFitDesignSystem.body2(context).copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    MoodFitButton(
                      label: 'Set Mood',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MoodSelectionScreen(),
                          ),
                        );
                      },
                      icon: Icons.add_reaction,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsBar(
      BuildContext context, int totalWorkouts, int totalMinutes, int streak) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.7)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, totalWorkouts.toString(), 'Workouts',
              Icons.fitness_center_rounded),
          _buildStatDivider(),
          _buildStatItem(
              context, totalMinutes.toString(), 'Minutes', Icons.timer_rounded),
          _buildStatDivider(),
          _buildStatItem(context, streak.toString(), 'Day Streak',
              Icons.local_fire_department_rounded),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 50,
      width: 1,
      color: isDark
          ? Colors.white.withOpacity(0.2)
          : Colors.black.withOpacity(0.1),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String value, String label, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: MoodFitDesignSystem.heading3(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: MoodFitDesignSystem.caption(context).copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Continuing with the remaining build methods for the Dashboard...
  // Add the following methods to complete the Dashboard screen:

  Widget _buildRecommendedWorkoutsTab(
    MoodProvider moodProvider,
    WorkoutProvider workoutProvider,
    bool hasCurrentMood,
  ) {

    if (hasCurrentMood && workoutProvider.recommendedWorkouts.isNotEmpty) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: workoutProvider.recommendedWorkouts.length,
        itemBuilder: (context, index) {
          final workout = workoutProvider.recommendedWorkouts[index];
          return _buildWorkoutCard(context, workout);
        },
      );
    } else if (hasCurrentMood) {
      return _buildEmptyStateCard(
        icon: Icons.fitness_center,
        title: 'No recommended workouts yet',
        subtitle: 'Create custom workouts or try updating your mood',
        buttonLabel: 'Create Workout',
        buttonIcon: Icons.add,
        onPressed: () {
          Navigator.pushNamed(context, '/create_workout');
        },
      );
    } else {
      return _buildEmptyStateCard(
        icon: Icons.mood,
        title: 'Select your mood first',
        subtitle: 'We\'ll recommend workouts based on how you feel',
        buttonLabel: 'Set Mood',
        buttonIcon: Icons.add_reaction,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MoodSelectionScreen(),
            ),
          );
        },
      );
    }
  }

  Widget _buildRecentWorkoutsTab(
      ProgressProvider progressProvider, WorkoutProvider workoutProvider) {
    if (progressProvider.progressEntries.isEmpty) {
      return _buildEmptyStateCard(
        icon: Icons.history,
        title: 'No workout history yet',
        subtitle: 'Complete your first workout to see it here',
        buttonLabel: 'Browse Workouts',
        buttonIcon: Icons.fitness_center,
        onPressed: () {
          // Switch to workouts tab
          (context.findAncestorStateOfType<_DashboardScreenState>())
              ?._onItemTapped(1);
        },
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
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

        WorkoutModel? workout;
        try {
          workout = workoutProvider.workouts.firstWhere(
            (w) => w.id == entry.workoutId,
          );
        } catch (e) {
          workout = null;
        }

        return _buildWorkoutHistoryCard(context, entry, beforeMood, workout);
      },
    );
  }

  Widget _buildEmptyStateCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required IconData buttonIcon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.7)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: MoodFitDesignSystem.subtitle1(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: MoodFitDesignSystem.body2(context).copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          MoodFitButton(
            label: buttonLabel,
            onPressed: onPressed,
            icon: buttonIcon,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, WorkoutModel workout) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.7)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutDetailScreen(workout: workout),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(workout.imageAsset),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getWorkoutIcon(workout.type),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style:
                              MoodFitDesignSystem.subtitle1(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workout.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: MoodFitDesignSystem.body2(context).copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildWorkoutChip(
                                context,
                                '${workout.durationMinutes} min',
                                Icons.timer_outlined),
                            const SizedBox(width: 8),
                            _buildWorkoutChip(
                                context,
                                _getDifficultyText(workout.difficulty),
                                Icons.fitness_center_outlined),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutHistoryCard(BuildContext context, dynamic entry,
      MoodModel beforeMood, WorkoutModel? workout) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.7)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (workout != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutDetailScreen(workout: workout),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Workout details not found")),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.workoutName,
                          style:
                              MoodFitDesignSystem.subtitle2(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, y • h:mm a')
                              .format(entry.completedAt),
                          style: MoodFitDesignSystem.caption(context).copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              beforeMood.moodIcon,
                              color: beforeMood.moodColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              beforeMood.type.toString().split('.').last,
                              style: MoodFitDesignSystem.caption(context),
                            ),
                            const SizedBox(width: 12),
                            _buildWorkoutChip(
                                context,
                                '${entry.durationMinutes} min',
                                Icons.timer_outlined),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutChip(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: MoodFitDesignSystem.caption(context).copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyLevelIndicator(int level, Color color) {
    return Row(
      children: List.generate(
        10,
        (index) => Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: index < level
                  ? color.withOpacity(0.7 + ((index / 10) * 0.3))
                  : Colors.grey.withOpacity(0.3),
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

    // Rest of the streak calculation logic...
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    bool hasWorkoutToday = entries.any((entry) =>
        entry.completedAt.isAfter(todayStart) ||
        entry.completedAt.isAtSameMomentAs(todayStart));

    // Calculate streak
    int streak = hasWorkoutToday ? 1 : 0;
    DateTime currentDate = hasWorkoutToday
        ? todayStart.subtract(const Duration(days: 1))
        : todayStart;

    for (int i = 0; i < 100; i++) {
      // Limit to prevent infinite loops
      bool hasWorkoutOnDate = entries.any((entry) {
        final entryDate = DateTime(entry.completedAt.year,
            entry.completedAt.month, entry.completedAt.day);
        return entryDate.isAtSameMomentAs(currentDate);
      });

      if (hasWorkoutOnDate) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
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
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }

  IconData _getWorkoutIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run;
      case 'strength':
        return Icons.fitness_center;
      case 'yoga':
        return Icons.self_improvement;
      case 'meditation':
        return Icons.spa;
      default:
        return Icons.fitness_center;
    }
  }

  String _getDifficultyText(int difficulty) {
    if (difficulty <= 3) {
      return 'Beginner';
    } else if (difficulty <= 7) {
      return 'Intermediate';
    } else {
      return 'Advanced';
    }
  }
}
