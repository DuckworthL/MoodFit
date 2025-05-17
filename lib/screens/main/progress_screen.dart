import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moodfit/models/mood_model.dart';
import 'package:moodfit/models/progress_model.dart';
import 'package:moodfit/providers/mood_provider.dart';
import 'package:moodfit/providers/progress_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../toast_util.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateTime _now = DateTime.now();
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _selectedDay = DateTime(_now.year, _now.month, _now.day);
    _focusedDay = _selectedDay;
    _firstDay = _now.subtract(const Duration(days: 365));
    _lastDay = _now.add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteProgressEntry(WorkoutProgressModel entry) async {
    final confirmed = await ToastUtil.showConfirmationDialog(
      context: context,
      title: 'Delete Progress Entry',
      message: 'Are you sure you want to delete this workout progress entry?',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;

    if (!mounted) return; // Fix: Don't use context if not mounted

    try {
      final progressProvider =
          Provider.of<ProgressProvider>(context, listen: false);
      final success = await progressProvider.deleteWorkoutProgress(entry.id);

      if (!mounted) return; // Fix: Don't use context if not mounted

      if (success) {
        ToastUtil.showSuccessToast('Progress entry deleted successfully');
      } else {
        ToastUtil.showErrorToast('Failed to delete progress entry');
      }
    } catch (e) {
      if (!mounted) return;
      ToastUtil.showErrorToast('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        title: Text('Progress', style: TextStyle(color: colorScheme.onPrimary)),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.secondary,
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Summary'),
            Tab(text: 'Calendar'),
            Tab(text: 'Mood'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(theme, colorScheme),
          _buildCalendarTab(theme, colorScheme),
          _buildMoodTab(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildSummaryTab(ThemeData theme, ColorScheme colorScheme) {
    final progressProvider = Provider.of<ProgressProvider>(context);
    final totalWorkouts = progressProvider.getTotalWorkoutsCompleted();
    final totalMinutes = progressProvider.getTotalMinutesWorkout();

    // Get data for the last 7 days
    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 7));
    final last7DaysWorkouts = progressProvider.getProgressForDateRange(
        weekAgo, today.add(const Duration(days: 1)));

    // Group workouts by day for the chart
    final Map<String, int> dailyWorkoutCount = {};
    final Map<String, int> dailyWorkoutMinutes = {};

    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final dateStr = DateFormat('MM-dd').format(date);
      dailyWorkoutCount[dateStr] = 0;
      dailyWorkoutMinutes[dateStr] = 0;
    }

    for (var workout in last7DaysWorkouts) {
      final dateStr = DateFormat('MM-dd').format(workout.completedAt);
      dailyWorkoutCount[dateStr] = (dailyWorkoutCount[dateStr] ?? 0) + 1;
      dailyWorkoutMinutes[dateStr] =
          (dailyWorkoutMinutes[dateStr] ?? 0) + workout.durationMinutes;
    }

    final List<String> labels = dailyWorkoutCount.keys.toList()..sort();
    labels.reversed.toList();

    final List<BarChartGroupData> barGroups = [];
    for (var i = 0; i < labels.length; i++) {
      final count = dailyWorkoutCount[labels[i]] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
              width: 16,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  colorScheme,
                  'Total Workouts',
                  totalWorkouts.toString(),
                  Icons.fitness_center,
                  colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  theme,
                  colorScheme,
                  'Total Minutes',
                  totalMinutes.toString(),
                  Icons.timer,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Last 7 Days Chart
          Text(
            'Workouts - Last 7 Days',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          if (totalWorkouts == 0)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Text(
                'No workout data yet.\nComplete your first workout to see your progress!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          else
            Container(
              height: 200,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (barGroups.fold<double>(
                          0,
                          (prev, element) => prev > element.barRods.first.toY
                              ? prev
                              : element.barRods.first.toY) +
                      1),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value >= 0 && value < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(labels[value.toInt()],
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: colorScheme.onSurface)),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == value.toInt() && value >= 0) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                value.toInt().toString(),
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: colorScheme.onSurface),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 1,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colorScheme.outline.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  barGroups: barGroups,
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Recent Workouts
          Text(
            'Recent Workouts',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          if (progressProvider.progressEntries.isEmpty)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No workout history yet.\nStart your first workout to track your progress!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          else
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: progressProvider.progressEntries.length > 5
                  ? 5
                  : progressProvider.progressEntries.length,
              itemBuilder: (context, index) {
                final entry = progressProvider.progressEntries[index];
                final MoodModel moodBefore = MoodModel(
                  id: '',
                  type: entry.moodBefore,
                  energyLevel: entry.energyLevelBefore,
                  timestamp: entry.completedAt,
                  userId: entry.userId,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: moodBefore.moodColor.withOpacity(0.2),
                      child: Icon(
                        moodBefore.moodIcon,
                        color: moodBefore.moodColor,
                      ),
                    ),
                    title: Text(
                      entry.workoutName,
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      '${DateFormat('MMM d, y').format(entry.completedAt)} • ${entry.durationMinutes} minutes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (entry.moodAfter != null)
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: MoodModel(
                              id: '',
                              type: entry.moodAfter!,
                              energyLevel: entry.energyLevelAfter ?? 5,
                              timestamp: entry.completedAt,
                              userId: entry.userId,
                            ).moodColor.withOpacity(0.2),
                            child: Icon(
                              MoodModel(
                                id: '',
                                type: entry.moodAfter!,
                                energyLevel: entry.energyLevelAfter ?? 5,
                                timestamp: entry.completedAt,
                                userId: entry.userId,
                              ).moodIcon,
                              size: 16,
                              color: MoodModel(
                                id: '',
                                type: entry.moodAfter!,
                                energyLevel: entry.energyLevelAfter ?? 5,
                                timestamp: entry.completedAt,
                                userId: entry.userId,
                              ).moodColor,
                            ),
                          ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              color: colorScheme.error, size: 20),
                          onPressed: () async {
                            await _deleteProgressEntry(entry);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab(ThemeData theme, ColorScheme colorScheme) {
    final progressProvider = Provider.of<ProgressProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);

    // Create a map of dates to count workouts
    final Map<DateTime, List<WorkoutProgressModel>> workoutsByDate = {};
    for (var progress in progressProvider.progressEntries) {
      final date = DateTime(
        progress.completedAt.year,
        progress.completedAt.month,
        progress.completedAt.day,
      );

      if (workoutsByDate[date] == null) {
        workoutsByDate[date] = [];
      }

      workoutsByDate[date]!.add(progress);
    }

    // Create a map of dates to moods
    final Map<DateTime, List<MoodModel>> moodsByDate = {};
    for (var mood in moodProvider.moods) {
      final date = DateTime(
        mood.timestamp.year,
        mood.timestamp.month,
        mood.timestamp.day,
      );

      if (moodsByDate[date] == null) {
        moodsByDate[date] = [];
      }

      moodsByDate[date]!.add(mood);
    }

    return Column(
      children: [
        // Calendar
        TableCalendar(
          firstDay: _firstDay,
          lastDay: _lastDay,
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              final workouts =
                  workoutsByDate[DateTime(date.year, date.month, date.day)] ??
                      [];
              final moods =
                  moodsByDate[DateTime(date.year, date.month, date.day)] ?? [];

              if (workouts.isEmpty && moods.isEmpty) return null;

              return Positioned(
                bottom: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (workouts.isNotEmpty)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (moods.isNotEmpty)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        // Daily Summary
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMMd().format(_selectedDay),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 16),

                // Workouts for selected day
                Text(
                  'Workouts',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if ((workoutsByDate[_selectedDay] ?? []).isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.cardColor,
                    ),
                    child: Text('No workouts on this day',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        )),
                  )
                else
                  ...workoutsByDate[_selectedDay]!.map((progress) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(
                          progress.workoutName,
                          style: theme.textTheme.bodyLarge,
                        ),
                        subtitle: Text(
                          '${DateFormat.jm().format(progress.completedAt)} • ${progress.durationMinutes} minutes',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  MoodModel(
                                    id: '',
                                    type: progress.moodBefore,
                                    energyLevel: progress.energyLevelBefore,
                                    timestamp: progress.completedAt,
                                    userId: progress.userId,
                                  ).moodIcon,
                                  color: MoodModel(
                                    id: '',
                                    type: progress.moodBefore,
                                    energyLevel: progress.energyLevelBefore,
                                    timestamp: progress.completedAt,
                                    userId: progress.userId,
                                  ).moodColor,
                                  size: 16,
                                ),
                                const Icon(
                                  Icons.arrow_right_alt,
                                  size: 16,
                                ),
                                if (progress.moodAfter != null)
                                  Icon(
                                    MoodModel(
                                      id: '',
                                      type: progress.moodAfter!,
                                      energyLevel:
                                          progress.energyLevelAfter ?? 5,
                                      timestamp: progress.completedAt,
                                      userId: progress.userId,
                                    ).moodIcon,
                                    color: MoodModel(
                                      id: '',
                                      type: progress.moodAfter!,
                                      energyLevel:
                                          progress.energyLevelAfter ?? 5,
                                      timestamp: progress.completedAt,
                                      userId: progress.userId,
                                    ).moodColor,
                                    size: 16,
                                  ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: colorScheme.error, size: 20),
                              onPressed: () async {
                                await _deleteProgressEntry(progress);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 24),

                // Moods for selected day
                Text(
                  'Moods',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if ((moodsByDate[_selectedDay] ?? []).isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.cardColor,
                    ),
                    child: Text('No mood entries on this day',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        )),
                  )
                else
                  ...moodsByDate[_selectedDay]!.map((mood) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: mood.moodColor.withOpacity(0.2),
                          child: Icon(
                            mood.moodIcon,
                            color: mood.moodColor,
                          ),
                        ),
                        title: Text(
                          mood.type.toString().split('.').last,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${DateFormat.jm().format(mood.timestamp)} • Energy: ${mood.energyLevel}/10',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (mood.note != null && mood.note!.isNotEmpty)
                              IconButton(
                                icon: Icon(Icons.notes,
                                    color: colorScheme.secondary),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        'Note - ${mood.type.toString().split('.').last}',
                                      ),
                                      content: Text(mood.note!),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: colorScheme.error, size: 20),
                              onPressed: () async {
                                final confirmed =
                                    await ToastUtil.showConfirmationDialog(
                                  context: context,
                                  title: 'Delete Mood Entry',
                                  message:
                                      'Are you sure you want to delete this mood entry?',
                                  confirmText: 'Delete',
                                  isDestructive: true,
                                );
                                if (!confirmed) return;
                                if (!mounted) return;

                                try {
                                  final moodProvider =
                                      Provider.of<MoodProvider>(context,
                                          listen: false);
                                  final success =
                                      await moodProvider.deleteMood(mood.id);
                                  if (!mounted) return;
                                  if (success) {
                                    ToastUtil.showSuccessToast(
                                        'Mood entry deleted successfully');
                                  } else {
                                    ToastUtil.showErrorToast(
                                        'Failed to delete mood entry');
                                  }
                                } catch (e) {
                                  if (!mounted) return;
                                  ToastUtil.showErrorToast('Error: $e');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodTab(ThemeData theme, ColorScheme colorScheme) {
    final moodProvider = Provider.of<MoodProvider>(context);

    // Count moods by type
    final Map<MoodType, int> moodCounts = {};
    for (var mood in moodProvider.moods) {
      moodCounts[mood.type] = (moodCounts[mood.type] ?? 0) + 1;
    }

    // Prepare data for pie chart
    final List<PieChartSectionData> pieChartData = [];
    for (var entry in moodCounts.entries) {
      final MoodModel mood = MoodModel(
        id: '',
        type: entry.key,
        energyLevel: 5,
        timestamp: DateTime.now(),
        userId: '',
      );

      pieChartData.add(
        PieChartSectionData(
          value: entry.value.toDouble(),
          title: '${entry.value}',
          color: mood.moodColor,
          radius: 80,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    // Last 7 days mood entries
    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 7));
    final last7DaysMoods = moodProvider.moods
        .where((mood) =>
            mood.timestamp.isAfter(weekAgo) &&
            mood.timestamp.isBefore(today.add(const Duration(days: 1))))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mood Distribution
          Text(
            'Mood Distribution',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          if (moodProvider.moods.isEmpty)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Text(
                'No mood data yet.\nLog your first mood to see your distribution!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          else
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: PieChart(
                PieChartData(
                  sections: pieChartData,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),

          // Mood Types Legend
          if (moodProvider.moods.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: MoodType.values.map((type) {
                  final MoodModel mood = MoodModel(
                    id: '',
                    type: type,
                    energyLevel: 5,
                    timestamp: DateTime.now(),
                    userId: '',
                  );

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: mood.moodColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type.toString().split('.').last,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 24),

          // Recent Moods
          Text(
            'Recent Mood Entries',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          if (last7DaysMoods.isEmpty)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No recent mood entries.\nUpdate your mood to track how you feel!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          else
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: last7DaysMoods.length > 5 ? 5 : last7DaysMoods.length,
              itemBuilder: (context, index) {
                final mood = last7DaysMoods[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: mood.moodColor.withOpacity(0.2),
                      child: Icon(
                        mood.moodIcon,
                        color: mood.moodColor,
                      ),
                    ),
                    title: Text(
                      mood.type.toString().split('.').last,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${DateFormat('MMM d, y').format(mood.timestamp)} • Energy: ${mood.energyLevel}/10',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (mood.note != null && mood.note!.isNotEmpty)
                          IconButton(
                            icon:
                                Icon(Icons.notes, color: colorScheme.secondary),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    'Note - ${mood.type.toString().split('.').last}',
                                  ),
                                  content: Text(mood.note!),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              color: colorScheme.error, size: 20),
                          onPressed: () async {
                            final confirmed =
                                await ToastUtil.showConfirmationDialog(
                              context: context,
                              title: 'Delete Mood Entry',
                              message:
                                  'Are you sure you want to delete this mood entry?',
                              confirmText: 'Delete',
                              isDestructive: true,
                            );
                            if (!confirmed) return;
                            if (!mounted) return;

                            try {
                              final moodProvider = Provider.of<MoodProvider>(
                                  context,
                                  listen: false);
                              final success =
                                  await moodProvider.deleteMood(mood.id);
                              if (!mounted) return;
                              if (success) {
                                ToastUtil.showSuccessToast(
                                    'Mood entry deleted successfully');
                              } else {
                                ToastUtil.showErrorToast(
                                    'Failed to delete mood entry');
                              }
                            } catch (e) {
                              if (!mounted) return;
                              ToastUtil.showErrorToast('Error: $e');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, ColorScheme colorScheme, String title,
      String value, IconData icon, Color iconColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.70),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
