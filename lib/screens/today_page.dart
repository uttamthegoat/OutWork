import 'package:flutter/material.dart';
import 'package:outwork/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:outwork/providers/workout_provider.dart';
import 'package:outwork/models/workout_split.dart';

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

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    todayDay = _getDayName(today.weekday);
    _fetchWorkouts();
    _checkWorkoutStatus();
    _isWorkoutFinished();
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

  Future<void> _startWorkout(
      BuildContext context, List<WorkoutSplit> workouts) async {
    if (_isLoading || _workoutInProgress) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (workouts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No workouts scheduled for today')),
        );
        return;
      }

      // Create a new workout log entry dynamically
      final Map<String, dynamic> workoutLog = {
        'date': DateTime.now().toIso8601String().split('T').first,
        'status': 'In Progress',
      };

      // Fill remaining workout slots with null
      for (int i = workouts.length; i < 5; i++) {
        workoutLog['workout_${i + 1}'] = null;
      }

      // Log the workout
      await Provider.of<WorkoutProvider>(context, listen: false)
          .logWorkout(workoutLog);

      setState(() {
        _workoutInProgress = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout session started')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _endWorkout(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> workoutLog = {};
      
      // Get the workout splits to access the reps
      final workoutSplits = Provider.of<WorkoutProvider>(context, listen: false).workoutSplits;
      
      // Create a map of workout_id to reps from splits
      final workoutRepsMap = {
        for (var split in workoutSplits) split.workout_id: split.reps
      };

      // Add selected workouts and their reps to the log
      for (int id in selectedWorkoutIds) {
        final index = workoutLog.length ~/ 2 + 1;
        workoutLog['workout_$index'] = id;
        workoutLog['workout_${index}_reps'] = workoutRepsMap[id] ?? 0;
      }
      
      workoutLog['status'] = 'Completed';
      
      // Update the workout status to completed
      await Provider.of<WorkoutProvider>(context, listen: false)
          .updateWorkoutStatus(workoutLog);

      setState(() {
        _workoutInProgress = false;
        _workoutFinished = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout session completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
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
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {
          final todayWorkouts = provider.workoutSplits;

          if (todayWorkouts.isEmpty) {
            return const Center(child: Text('No workouts for today'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: todayWorkouts.length,
            itemBuilder: (context, index) {
              final workout = todayWorkouts[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(workout.workout_name),
                  subtitle: Text(
                    '${workout.reps} reps | Category: ${workout.category}',
                  ),
                  trailing: Checkbox(
                    value: selectedWorkoutIds.contains(workout.workout_id),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedWorkoutIds.add(workout.workout_id);
                        } else {
                          selectedWorkoutIds.remove(workout.workout_id);
                        }
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_workoutFinished) {
            
          } else if (_workoutInProgress) {
            _endWorkout(context);
          } else {
            _startWorkout(
                context,
                Provider.of<WorkoutProvider>(context, listen: false)
                    .workoutSplits);
          }
        },
        label: Text(_workoutFinished ? 'Finished' : _workoutInProgress ? 'End' : 'Start'),
        icon: Icon(_workoutFinished ? Icons.stop_circle : _workoutInProgress ? Icons.stop : Icons.play_arrow),
      ),
    );
  }
}
