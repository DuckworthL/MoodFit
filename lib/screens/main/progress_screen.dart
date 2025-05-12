// lib/screens/main/progress_screen.dart - Track workout and mood progress
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moodfit/models/mood_model.dart';
import 'package:moodfit/models/progress_model.dart';
import 'package:moodfit/providers/mood_provider.dart';
import 'package:moodfit/providers/progress_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        bottom: TabBar(
          controller: _tabController,
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
          _buildSummaryTab(),
          _buildCalendarTab(),
          _buildMoodTab(),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
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
              color: Theme.of(context).primaryColor,
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
                  'Total Workouts',
                  totalWorkouts.toString(),
                  Icons.fitness_center,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
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
          const Text(
            'Workouts - Last 7 Days',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (totalWorkouts == 0)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: const Text(
                'No workout data yet.\nComplete your first workout to see your progress!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Container(
              height: 200,
              padding: const EdgeInsets.all(8),
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
                                  style: const TextStyle(fontSize: 10)),
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
                              child: Text(value.toInt().toString()),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 1,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    ),
                  ),
                  barGroups: barGroups,
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Recent Workouts
          const Text(
            'Recent Workouts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (progressProvider.progressEntries.isEmpty)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No workout history yet.\nStart your first workout to track your progress!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
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

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: moodBefore.moodColor.withOpacity(0.2),
                      child: Icon(
                        moodBefore.moodIcon,
                        color: moodBefore.moodColor,
                      ),
                    ),
                    title: Text(entry.workoutName),
                    subtitle: Text(
                      '${DateFormat('MMM d, y').format(entry.completedAt)} • ${entry.durationMinutes} minutes',
                    ),
                    trailing: entry.moodAfter != null
                        ? CircleAvatar(
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
                          )
                        : null,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
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
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (moods.isNotEmpty)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 2),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Workouts for selected day
                const Text(
                  'Workouts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if ((workoutsByDate[_selectedDay] ?? []).isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                    ),
                    child: const Text('No workouts on this day'),
                  )
                else
                  ...workoutsByDate[_selectedDay]!.map((progress) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(progress.workoutName),
                        subtitle: Text(
                          '${DateFormat.jm().format(progress.completedAt)} • ${progress.durationMinutes} minutes',
                        ),
                        trailing: progress.moodAfter != null
                            ? Row(
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
                              )
                            : null,
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 24),

                // Moods for selected day
                const Text(
                  'Moods',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if ((moodsByDate[_selectedDay] ?? []).isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                    ),
                    child: const Text('No mood entries on this day'),
                  )
                else
                  ...moodsByDate[_selectedDay]!.map((mood) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${DateFormat.jm().format(mood.timestamp)} • Energy: ${mood.energyLevel}/10',
                        ),
                        trailing: mood.note != null && mood.note!.isNotEmpty
                            ? const Icon(Icons.notes)
                            : null,
                        onTap: mood.note != null && mood.note!.isNotEmpty
                            ? () {
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
                              }
                            : null,
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

  Widget _buildMoodTab() {
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
          const Text(
            'Mood Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (moodProvider.moods.isEmpty)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: const Text(
                'No mood data yet.\nLog your first mood to see your distribution!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            SizedBox(
              height: 250,
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
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 24),

          // Recent Moods
          const Text(
            'Recent Mood Entries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (last7DaysMoods.isEmpty)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No recent mood entries.\nUpdate your mood to track how you feel!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: last7DaysMoods.length > 5 ? 5 : last7DaysMoods.length,
              itemBuilder: (context, index) {
                final mood = last7DaysMoods[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${DateFormat('MMM d, y').format(mood.timestamp)} • Energy: ${mood.energyLevel}/10',
                    ),
                    trailing: mood.note != null
                        ? IconButton(
                            icon: const Icon(Icons.notes),
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
                          )
                        : null,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
