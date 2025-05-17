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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = theme.cardColor;

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
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        title: _isSearchMode
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search workouts...',
                  hintStyle:
                      TextStyle(color: colorScheme.onPrimary.withOpacity(0.7)),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: colorScheme.onPrimary),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isSearchMode = false;
                      });
                    },
                  ),
                ),
                style: TextStyle(color: colorScheme.onPrimary),
                autofocus: true,
              )
            : Text('Workouts', style: TextStyle(color: colorScheme.onPrimary)),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        actions: [
          if (!_isSearchMode)
            IconButton(
              icon: Icon(Icons.search, color: colorScheme.onPrimary),
              onPressed: () {
                setState(() {
                  _isSearchMode = true;
                });
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.secondary,
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.7),
          indicatorWeight: 3,
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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('Manage My Workouts',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkoutListScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                minimumSize: const Size(double.infinity, 48),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Workouts Tab
                _buildWorkoutList(allWorkouts, cardColor, colorScheme, theme),

                // Quick Workouts Tab
                _buildWorkoutList(quickWorkouts, cardColor, colorScheme, theme),

                // By Mood Tab
                _buildMoodFilteredWorkouts(
                    moodWorkouts, cardColor, colorScheme, theme),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateWorkoutScreen(),
            ),
          );
        },
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildWorkoutList(List<WorkoutModel> workouts, Color cardColor,
      ColorScheme colorScheme, ThemeData theme) {
    if (workouts.isEmpty) {
      return Center(
        child: Text('No workouts found',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onBackground.withOpacity(0.7))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return _buildWorkoutCard(workout, cardColor, colorScheme, theme);
      },
    );
  }

  Widget _buildMoodFilteredWorkouts(
    Map<MoodType, List<WorkoutModel>> moodWorkouts,
    Color cardColor,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: MoodType.values.map((moodType) {
          final workouts = moodWorkouts[moodType] ?? [];
          if (workouts.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Text(
                  moodType.toString().split('.').last.toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ...workouts
                  .map((workout) =>
                      _buildWorkoutCard(workout, cardColor, colorScheme, theme))
                  .toList(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutModel workout, Color cardColor,
      ColorScheme colorScheme, ThemeData theme) {
    final MoodModel moodModel = MoodModel(
      id: '',
      type: workout.recommendedMood,
      energyLevel: workout.energyLevelRequired,
      timestamp: DateTime.now(),
      userId: '',
    );

    return GestureDetector(
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 17),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18), topRight: Radius.circular(18)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  workout.backgroundImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: colorScheme.surfaceVariant,
                    alignment: Alignment.center,
                    child: Icon(Icons.image_not_supported,
                        size: 40,
                        color: colorScheme.onSurface.withOpacity(0.4)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and mood chip
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          workout.name,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _MoodChip(
                        moodType: workout.recommendedMood,
                        color: moodModel.moodColor,
                        isDark: Theme.of(context).brightness == Brightness.dark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Description
                  if (workout.description.isNotEmpty)
                    Text(
                      workout.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.72),
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Meta info row
                  Row(
                    children: [
                      _MetaChip(
                        icon: Icons.timer,
                        label: '${workout.totalDurationMinutes} min',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: 10),
                      _MetaChip(
                        icon: Icons.fitness_center,
                        label: '${workout.exercises.length} exercises',
                        colorScheme: colorScheme,
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

// Mood chip widget
class _MoodChip extends StatelessWidget {
  final MoodType moodType;
  final Color color;
  final bool isDark;
  const _MoodChip(
      {required this.moodType, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    String label = moodType.toString().split('.').last;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.22 : 0.16),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

// Meta info chip widget
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  const _MetaChip(
      {required this.icon, required this.label, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: colorScheme.secondary),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
