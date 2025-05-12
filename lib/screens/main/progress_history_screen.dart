// lib/screens/main/progress_history_screen.dart - View and manage workout progress history
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodfit/models/progress_model.dart';
import 'package:moodfit/providers/auth_provider.dart';
import 'package:moodfit/providers/progress_provider.dart';
import 'package:provider/provider.dart';

class ProgressHistoryScreen extends StatefulWidget {
  const ProgressHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ProgressHistoryScreen> createState() => _ProgressHistoryScreenState();
}

class _ProgressHistoryScreenState extends State<ProgressHistoryScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProgressHistory();
  }

  Future<void> _loadProgressHistory() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.uid == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<ProgressProvider>(context, listen: false)
          .loadUserProgressSimple(authProvider.uid!);
    } catch (e) {
      debugPrint('Error loading progress: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading progress: $e')),
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

  void _confirmDeleteProgress(WorkoutProgressModel progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Progress'),
        content: const Text(
            'Are you sure you want to delete this workout progress?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              try {
                final success =
                    await Provider.of<ProgressProvider>(context, listen: false)
                        .deleteWorkoutProgress(progress.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Progress deleted successfully'
                          : 'Failed to delete progress'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting progress: $e'),
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
        title: const Text('Workout History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProgressHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ProgressProvider>(
              builder: (context, provider, _) {
                if (provider.progressEntries.isEmpty) {
                  return const Center(
                    child: Text('No workout history found.'),
                  );
                }

                return ListView.builder(
                  itemCount: provider.progressEntries.length,
                  itemBuilder: (context, index) {
                    final progress = provider.progressEntries[index];
                    return Dismissible(
                      key: Key(progress.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        bool? result = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Progress'),
                            content: const Text(
                                'Are you sure you want to delete this workout progress?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
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
                      onDismissed: (_) async {
                        await provider.deleteWorkoutProgress(progress.id);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: ListTile(
                          title: Text(progress.workoutName),
                          subtitle: Text(
                            DateFormat.yMMMd()
                                .add_jm()
                                .format(progress.completedAt),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteProgress(progress),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
