import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:moodfit/models/mood_model.dart';
import 'package:moodfit/providers/auth_provider.dart';
import 'package:moodfit/providers/mood_provider.dart';
import 'package:moodfit/providers/workout_provider.dart';
import 'package:moodfit/screens/main/dashboard_screen.dart';
import 'package:moodfit/screens/main/mood_history_screen.dart';
import 'package:moodfit/utils/constants.dart';
import 'package:provider/provider.dart';

import '../../toast_util.dart';

class MoodSelectionScreen extends StatefulWidget {
  final bool isInitialSetup;

  const MoodSelectionScreen({Key? key, this.isInitialSetup = false})
      : super(key: key);

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  MoodType? _selectedMoodType;
  int _energyLevel = 5;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    debugPrint(
        "MoodSelectionScreen initialized with isInitialSetup: ${widget.isInitialSetup}");
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveNewMood() async {
    if (_selectedMoodType == null) {
      ToastUtil.showErrorToast('Please select a mood');
      return;
    }

    // Show confirmation dialog before saving
    final confirmed = await ToastUtil.showConfirmationDialog(
      context: context,
      title: 'Save Mood',
      message: 'Do you want to save your current mood?',
      confirmText: 'Save',
    );

    if (!confirmed) return;

    setState(() {
      _isSubmitting = true;
    });

    // ignore: use_build_context_synchronously
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // ignore: use_build_context_synchronously
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final workoutProvider =
        // ignore: use_build_context_synchronously
        Provider.of<WorkoutProvider>(context, listen: false);

    bool success = false;

    if (authProvider.uid != null) {
      try {
        success = await moodProvider.addMood(
          authProvider.uid!,
          _selectedMoodType!,
          _energyLevel,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
        );

        // Update recommended workouts based on the new mood
        await workoutProvider.updateRecommendedWorkouts(
          _selectedMoodType!,
          _energyLevel,
        );

        if (widget.isInitialSetup) {
          // Reset the new user flag after completing onboarding
          authProvider.resetNewUserFlag();
        }

        if (success && mounted) {
          ToastUtil.showSuccessToast('Mood saved successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error saving mood: $e');
        }
        if (mounted) {
          ToastUtil.showErrorToast('Error saving mood: $e');
        }
      }

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (success) {
          // Different navigation based on whether this is initial setup
          if (widget.isInitialSetup) {
            debugPrint(
                "MoodSelectionScreen: Initial setup complete, navigating to dashboard");
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false, // Remove all routes from stack
            );
          } else {
            // For existing users updating mood, just go back
            Navigator.of(context).pop();
          }
        }
      }
    } else {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ToastUtil.showErrorToast('User not authenticated');
      }
    }
  }

  void _viewMoodHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MoodHistoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Custom title based on whether this is initial setup or regular mood update
    final title = widget.isInitialSetup
        ? 'Let\'s get started! How are you feeling?'
        : 'How are you feeling?';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // Only show back button if not in initial setup
        automaticallyImplyLeading: !widget.isInitialSetup,
        actions: !widget.isInitialSetup
            ? [
                // Only show history button if not initial setup
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'Mood History',
                  onPressed: _viewMoodHistory,
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select your mood',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: MoodType.values.map((moodType) {
                  final isSelected = _selectedMoodType == moodType;
                  final mood = MoodModel(
                    id: '',
                    type: moodType,
                    energyLevel: 5,
                    timestamp: DateTime.now(),
                    userId: '',
                  );

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMoodType = moodType;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected
                            ? mood.moodColor.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.1),
                        border: Border.all(
                          color:
                              isSelected ? mood.moodColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            mood.moodIcon,
                            size: 32,
                            color: isSelected
                                ? mood.moodColor
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            moodType.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? mood.moodColor
                                  : Colors.grey.shade800,
                            ),
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                AppConstants.moodDescriptions[moodType] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              const Text(
                'Energy Level',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Low',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Expanded(
                    child: Slider(
                      min: 1,
                      max: 10,
                      divisions: 9,
                      value: _energyLevel.toDouble(),
                      label: _energyLevel.toString(),
                      onChanged: (value) {
                        setState(() {
                          _energyLevel = value.toInt();
                        });
                      },
                    ),
                  ),
                  const Text(
                    'High',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Add a note (optional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'How are you feeling today?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveNewMood,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : Text(
                          widget.isInitialSetup ? 'Get Started' : 'Save Mood'),
                ),
              ),
              if (!widget.isInitialSetup) ...[
                const SizedBox(height: 20),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text('View Mood History'),
                    onPressed: _viewMoodHistory,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
