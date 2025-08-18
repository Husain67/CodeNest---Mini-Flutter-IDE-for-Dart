import 'package:flutter/material.dart';
import 'package:simple_app/screens/feedback_screen.dart';
import 'package:simple_app/screens/privacy_policy_screen.dart';
import 'package:simple_app/screens/cloud_emulator_screen.dart';
import 'package:simple_app/widgets/social_media_buttons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_circle),
              title: const Text('Cloud Emulator'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CloudEmulatorScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
            const Divider(),
            const ListTile(
              title: Text('App Version 1.0.0'),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to our App!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 40),
            Text(
              'Follow us on social media:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            SocialMediaButtons(),
          ],
        ),
      ),
    );
  }
}
