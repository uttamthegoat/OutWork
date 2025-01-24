import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              // TODO: Implement profile settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              // TODO: Implement notification settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme'),
            onTap: () {
              // TODO: Implement theme settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            onTap: () {
              // TODO: Implement backup settings
            },
          ),
        ],
      ),
    );
  }
}
