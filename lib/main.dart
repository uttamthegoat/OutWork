import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:outwork/providers/workout_provider.dart';
import 'package:outwork/screens/home_page.dart';
import 'package:outwork/constants/app_constants.dart';
import 'package:outwork/themes/themes.dart';
import 'providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  await SharedPreferences.getInstance();
  runApp(const MyApp());
}

Future<void> requestPermissions() async {
  // Get Android version
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;
  final androidVersion = androidInfo.version.sdkInt;

  if (androidVersion >= 30) {
    // Android 11 or higher
    // Request manage external storage permission
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      // Show dialog to guide user to settings
      await openAppSettings();
      throw Exception('Storage permission required');
    }
  } else {
    // For Android 10 and below
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      await openAppSettings();
      throw Exception('Storage permission required');
    }
  }

  print('All permissions granted');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkoutProvider(),
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              title: AppConstants.appName,
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
              themeMode: themeProvider.themeMode,
              debugShowCheckedModeBanner: false,
              home: const HomePage(),
            );
          },
        ),
      ),
    );
  }
}
