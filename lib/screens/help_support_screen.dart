import 'package:flutter/material.dart';
import 'package:outwork/constants/app_constants.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.book),
              title: const Text('User Guide'),
              onTap: () {
                // TODO: Show user guide
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('FAQ'),
              onTap: () {
                // TODO: Show FAQ
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Contact Support'),
              onTap: () {
                // TODO: Show contact form
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              subtitle: Text('Version ${AppConstants.version}'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: AppConstants.version,
                  applicationLegalese: '© 2024',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
