import 'package:flutter/material.dart';
import 'package:outwork/screens/stats_screen.dart';
import 'package:outwork/screens/today_page.dart';
import 'package:outwork/screens/workout_history_screen.dart';
import 'package:outwork/screens/workout_split_screen.dart';

class AppConstants {
  static const String appName = 'OutWork';
  static const String appDescription = 'Workout Tracking App';
  static const String version = '1.0.0';

  // Database
  static const String dbName = 'outwork.db';

  // Routes
  static const String homeRoute = '/';
  static const String allWorkoutsRoute = '/all-workouts';
  static const String personalRecordsRoute = '/personal-records';
  static const String workoutHistoryRoute = '/workout-history';
  static const String settingsRoute = '/settings';
  static const String helpSupportRoute = '/help-support';

  static const List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  static const List<String> muscleGroups = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Biceps',
    'Triceps',
    'Core',
    'Abs',
    'Calves',
    'Quadriceps',
    'Hamstrings',
    'Glutes',
    'Forearms',
    'Traps',
    'Lats',
    'Cardio',
    'Full Body'
        'Jaw'
        'Neck'
  ];
  static const List<String> workoutTypes = ['Strength', 'Endurance', 'Cardio'];
  static const Map<String, String> bottomNavBarItems = {
    'today': 'Today',
    'history': 'History',
    'split': 'Split',
    'stats': 'Stats',
  };
  static const Map<String, String> appDrawerItems = {
    'allWorkouts': 'All Workouts',
    'personalRecords': 'Personal Records',
    'databaseViewer': 'Database Viewer',
    'settings': 'Settings',
    'helpSupport': 'Help & Support',
    'backupOrRestore': 'Backup or Restore',
  };
  static const List<Widget> pages = [
    TodayPage(),
    WorkoutHistoryScreen(),
    WorkoutSplitScreen(),
    StatsPage(),
  ];

  static const List<String> workoutSplit = [
    'Skipping Rope',
    'Rows',
    'Hanging Leg Raises',
    'Burpees',
    'Push Ups',
    'Pull Ups',
    'Dips',
    'Squats',
    'Lunges',
    'Planks',
    'Mountain Climbers',
    'Leg Raises',
    'Handstand Push Ups',
    'Box Jumps',
    'Tuck Jumps',
    'Pike Push Ups',
    'Inverted Rows',
    'Wall Sits',
  ];

  static const settingsPageContent = [
    {
      'icon': '',
      'title': 'Appearance',
    },
  ];
}
