import 'package:flutter/material.dart';
import 'package:outwork/constants/app_constants.dart';
import 'package:outwork/widgets/toast.dart';
import 'package:provider/provider.dart';
import 'package:outwork/providers/workout_provider.dart';
import 'package:outwork/models/workout_split.dart';
import 'package:outwork/models/workout_log.dart';
import 'dart:convert';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late String todayDay;
  bool _isLoading = false;
  bool _workoutInProgress = false;
  bool _workoutFinished = false;
  Set<int> selectedWorkoutIds = {}; // Set to store selected workout IDs
  List<Map<String, dynamic>> workoutList = [];
  Map<String, TextEditingController> controllers = {};
  bool _isCompletedWorkoutsExpanded = false;
  List<dynamic> todayLogs = [];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    todayDay = _getDayName(today.weekday);
    _fetchWorkouts();
    _fetchWorkoutLogs();
    _checkWorkoutStatus();
    _isWorkoutFinished();
  }

  Future<void> _fetchWorkoutLogs() async {
    await Provider.of<WorkoutProvider>(context, listen: false)
        .fetchWorkoutLogs();
    final todayDate = DateTime.now().toIso8601String().split('T').first;
    setState(() {
      todayLogs = Provider.of<WorkoutProvider>(context, listen: false)
              .workoutLogsByDate[todayDate] ??
          [];
    });
  }

  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _createSetForWorkout(int workoutId) {
    int workoutIndex =
        workoutList.indexWhere((set) => set['workout_id'] == workoutId);
    if (workoutIndex == -1) {
      setState(() {
        workoutList.add({'workout_id': workoutId, 'weight': '', 'sets': []});
      });
    }
  }

  void _addSet(int workoutId) {
    setState(() {
      int workoutIndex =
          workoutList.indexWhere((set) => set['workout_id'] == workoutId);

      (workoutList[workoutIndex]['sets'] as List).add('');
    });
  }

  String _getDayName(int weekday) {
    const days = AppConstants.weekDays;
    return days[weekday - 1];
  }

  Future<void> _fetchWorkouts() async {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    await provider.fetchWorkoutSplitsForDay(todayDay);
  }

  Future<void> _checkWorkoutStatus() async {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    final hasActiveWorkout = await provider.hasActiveWorkoutForToday();
    setState(() {
      _workoutInProgress = hasActiveWorkout;
    });
  }

  Future<void> _isWorkoutFinished() async {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    final isWorkoutFinished = await provider.isWorkoutFinished();
    setState(() {
      _workoutFinished = isWorkoutFinished;
    });
  }

  Future<void> _saveWorkout(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if workoutList is empty
      if (workoutList.isEmpty) {
        showCustomToast('No workouts to save. Please add workouts first.', 'error');
        return; // Exit the function early
      }

      final todayWorkouts =
          Provider.of<WorkoutProvider>(context, listen: false).workoutSplits;

      // First, create the workout_logs entry
      final Map<String, dynamic> workoutLogEntry = {
        'date': DateTime.now().toIso8601String().split('T').first,
        'status': 'completed'
      };

      // Insert the log entry and get the log_id
      final int logId =
          await Provider.of<WorkoutProvider>(context, listen: false)
              .createWorkoutLog(workoutLogEntry);

      // Create workout_details entries for each workout
      for (var workout in workoutList) {
        // Find the workout from todayWorkouts
        final workoutSplit = todayWorkouts.firstWhere(
          (w) => w.workout_id == workout['workout_id'],
          orElse: () => throw Exception('Workout not found'),
        );

        // Convert weight to double
        final weight = workout['weight'].toString().isEmpty
            ? null
            : double.parse(workout['weight'].toString());

        // Convert sets to JSON array of reps
        List<Map<String, dynamic>> setsData = [];
        for (var rep in workout['sets']) {
          if (rep.toString().isNotEmpty) {
            setsData.add({'reps': rep.toString()});
          }
        }

        // Create the workout_details entry
        final Map<String, dynamic> workoutDetails = {
          'log_id': logId,
          'workout_id': workout['workout_id'],
          'weight': weight,
          'sets_data': setsData,
        };

        // Insert the workout details
        await Provider.of<WorkoutProvider>(context, listen: false)
            .addWorkoutDetails(workoutDetails);
      }

      setState(() {
        _workoutInProgress = false;
        _workoutFinished = true;
      });

      showCustomToast('Workout session completed', 'success');
    } catch (e) {
      showCustomToast('Error saving workout: $e', 'error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Workouts'),
        actions: [
          TextButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  side: BorderSide(
                    color: Colors.white,
                    width: 1.0,
                    style: BorderStyle.solid,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                builder: (context) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.8, // 90% of screen height
                    child: _buildCompletedWorkoutsModal(context, todayLogs),
                  );
                },
              );
            },
            child: const Row(
              children: [Icon(Icons.list), Text('Today\'s Workouts')],
            ),
          )
        ],
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {
          final todayWorkouts = provider.workoutSplits;

          return Column(
            children: [
              Expanded(
                flex: 2,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: todayWorkouts.length,
                  itemBuilder: (context, index) {
                    final workout = todayWorkouts[index];

                    return ExpansionTile(
                      onExpansionChanged: (expanded) {
                        if (expanded) {
                          _createSetForWorkout(workout.workout_id);
                        }
                      },
                      leading: const Icon(Icons.fitness_center),
                      title: Text(workout.workout_name),
                      children: [
                        Column(
                          children: [
                            ...(() {
                              // Find the workout's data
                              final workoutEntry = workoutList.firstWhere(
                                (entry) =>
                                    entry['workout_id'] == workout.workout_id,
                                orElse: () => {
                                  'workout_id': workout.workout_id,
                                  'weight': '',
                                  'sets': []
                                },
                              );

                              // Ensure sets are initialized properly
                              if (workoutEntry['sets'].isEmpty) {
                                workoutEntry['sets'] =
                                    []; // Initialize with one empty rep if empty
                              }

                              List<Widget> widgets = [
                                // Weight Row
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: controllers.putIfAbsent(
                                            '${workout.workout_id}_weight',
                                            () => TextEditingController(
                                                text: workoutEntry['weight']
                                                    .toString()),
                                          ),
                                          decoration: const InputDecoration(
                                            labelText: 'Weight',
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            setState(() {
                                              // Find and update the specific workout entry in workoutList
                                              int workoutIndex = workoutList
                                                  .indexWhere((entry) =>
                                                      entry['workout_id'] ==
                                                      workout.workout_id);
                                              if (workoutIndex == -1) {
                                                // If entry doesn't exist, create it
                                                workoutList.add({
                                                  'workout_id':
                                                      workout.workout_id,
                                                  'weight': value,
                                                  'sets': []
                                                });
                                              } else {
                                                // Update existing entry
                                                workoutList[workoutIndex]
                                                    ['weight'] = value;
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ];

                              // Add Reps Rows
                              final sets = (workoutEntry['sets'] as List);
                              for (int i = 0; i < sets.length; i++) {
                                widgets.add(
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Text('Set ${i + 1}:',
                                            style:
                                                const TextStyle(fontSize: 16)),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextField(
                                            controller: controllers.putIfAbsent(
                                              '${workout.workout_id}_rep_$i',
                                              () => TextEditingController(
                                                  text: sets[i].toString()),
                                            ),
                                            decoration: const InputDecoration(
                                              labelText: 'Reps',
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.text,
                                            onChanged: (value) {
                                              setState(() {
                                                sets[i] =
                                                    value.isEmpty ? '' : value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              widgets.add(
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _addSet(workout.workout_id),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Set'),
                                  ),
                                ),
                              );

                              return widgets;
                            })(),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _saveWorkout(context);
        },
        label: Text('Save'),
        icon: Icon(Icons.save),
      ),
    );
  }

  Widget _buildCompletedWorkoutsModal(
      BuildContext context, List<dynamic> todayLogs) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Completed Workouts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: todayLogs.length,
              itemBuilder: (context, index) {
                final log = todayLogs[index];
                final workoutName = log['workout_name'] as String;
                final weight = log['weight'] as double?;
                final setsData = jsonDecode(log['sets_data'] as String) as List;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: Colors.blue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                workoutName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (weight != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Weight: ${weight}kg',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(setsData.length, (setIndex) {
                            final setData =
                                setsData[setIndex] as Map<String, dynamic>;
                            final reps = setData['reps'] as String?;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Set ${setIndex + 1}: ${reps != null
                                        ? (RegExp(r'^\d+$')
                                                .hasMatch(reps.toString())
                                        ? '$reps reps'
                                        : reps)
                                        : 'No reps recorded'}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
