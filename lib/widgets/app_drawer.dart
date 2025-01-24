import 'package:flutter/material.dart';
import 'package:outwork/screens/all_workouts_screen.dart';
import 'package:outwork/screens/personal_records_screen.dart';
import 'package:outwork/screens/settings_screen.dart';
import 'package:outwork/screens/help_support_screen.dart';
import 'package:outwork/constants/app_constants.dart';
import 'package:outwork/screens/database_viewer_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  final Map<String, String> appDrawerItems = AppConstants.appDrawerItems;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  AppConstants.appDescription,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(appDrawerItems['allWorkouts']!),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AllWorkoutsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: Text(appDrawerItems['personalRecords']!),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PersonalRecordsScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.storage),
            title: Text(appDrawerItems['databaseViewer']!),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DatabaseViewerScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(appDrawerItems['settings']!),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(appDrawerItems['helpSupport']!),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen()),
              );
            },
          ),
          
        ],
      ),
    );
  }
}
