// lib/screens/main/mood_history_screen.dart - View and manage mood history
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodfit/models/mood_model.dart';
import 'package:moodfit/providers/mood_provider.dart';
import 'package:provider/provider.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({Key? key}) : super(key: key);

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // No need to reload if there are already entries
    if (Provider.of<MoodProvider>(context, listen: false).moods.isEmpty) {
      _refreshMoodHistory();
    }
  }

  Future<void> _refreshMoodHistory() async {
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the simple method as it doesn't require indices
      await moodProvider.loadUserMoodsSimple(
        Provider.of<MoodProvider>(context, listen: false).currentMood?.userId ??
            '',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading mood history: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _confirmDeleteMood(MoodModel mood) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Mood Entry'),
        content: const Text('Are you sure you want to delete this mood entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              final moodProvider =
                  Provider.of<MoodProvider>(context, listen: false);
              final success = await moodProvider.deleteMood(mood.id);

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mood entry deleted'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Error: ${moodProvider.error ?? 'Unknown error'}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshMoodHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<MoodProvider>(
              builder: (context, moodProvider, child) {
                if (moodProvider.moods.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.mood_bad,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No mood entries yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Track your mood to see your history',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _refreshMoodHistory,
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshMoodHistory,
                  child: ListView.builder(
                    itemCount: moodProvider.moods.length,
                    itemBuilder: (context, index) {
                      final mood = moodProvider.moods[index];
                      return Dismissible(
                        key: Key(mood.id),
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
                          bool? result = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Mood Entry'),
                              content: const Text(
                                  'Are you sure you want to delete this mood entry?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.red),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          return result ?? false;
                        },
                        onDismissed: (direction) async {
                          final success =
                              await moodProvider.deleteMood(mood.id);
                          if (mounted && !success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error: ${moodProvider.error ?? 'Unknown error'}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      mood.moodColor.withOpacity(0.2),
                                  child: Icon(
                                    mood.moodIcon,
                                    color: mood.moodColor,
                                  ),
                                ),
                                title: Text(
                                  mood.type
                                      .toString()
                                      .split('.')
                                      .last
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  DateFormat.yMMMMd()
                                      .add_jm()
                                      .format(mood.timestamp),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Energy level indicator
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.bolt,
                                            size: 16,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            mood.energyLevel.toString(),
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Delete button
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _confirmDeleteMood(mood),
                                    ),
                                  ],
                                ),
                              ),
                              if (mood.note != null && mood.note!.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '"${mood.note!}"',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
