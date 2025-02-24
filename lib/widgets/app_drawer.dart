import 'package:flutter/material.dart';
import 'package:outwork/providers/theme_provider.dart';
import 'package:outwork/screens/all_workouts_screen.dart';
import 'package:outwork/screens/personal_records_screen.dart';
import 'package:outwork/screens/data_settings.dart';
import 'package:outwork/screens/help_support_screen.dart';
import 'package:outwork/constants/app_constants.dart';
import 'package:outwork/screens/database_viewer_screen.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final Map<String, String> appDrawerItems = AppConstants.appDrawerItems;

  // Define drawer items structure
  final List<DrawerItem> _drawerItems = [
    DrawerItem(
      icon: Icons.fitness_center,
      title: 'allWorkouts',
      screen: const AllWorkoutsScreen(),
    ),
    DrawerItem(
        icon: Icons.emoji_events,
        title: 'personalRecords',
        screen: const PersonalRecordsScreen(),
        addDivider: true),
    DrawerItem(
        icon: Icons.backup_table,
        title: 'databaseViewer',
        screen: const DatabaseViewerScreen(),
        addDivider: true),
    DrawerItem(
      icon: Icons.cloud_upload,
      title: 'backupOrRestore',
      screen: const DataSettings(),
    ),
    DrawerItem(
      icon: Icons.help_outline,
      title: 'helpSupport',
      screen: const HelpSupportScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 320,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/icon/icon.png',
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        AppConstants.appName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppConstants.appDescription,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                            ),
                            onPressed: () async {
                              await themeProvider.toggleTheme();
                            },
                            style: IconButton.styleFrom(
                              shape: CircleBorder(),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              ..._drawerItems
                  .map((item) => Column(
                        children: [
                          ListTile(
                            leading: Icon(item.icon),
                            title: Text(appDrawerItems[item.title]!),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => item.screen),
                              );
                            },
                          ),
                          if (item.addDivider) const Divider(),
                        ],
                      ))
                  .toList(),
            ],
          ),
        ),
      );
    });
  }
}

// Define a class to hold drawer item data
class DrawerItem {
  final IconData icon;
  final String title;
  final Widget screen;
  final bool addDivider;

  DrawerItem({
    required this.icon,
    required this.title,
    required this.screen,
    this.addDivider = false,
  });
}
