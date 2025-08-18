import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for Simple App',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: August 17, 2025',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16),
            Text(
              'This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You.',
            ),
            SizedBox(height: 16),
             Text(
              'Interpretation and Definitions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '[Placeholder] This is where the detailed interpretation and definitions section of your privacy policy would go. It would define key terms used throughout the policy.',
            ),
             SizedBox(height: 16),
            Text(
              'Collecting and Using Your Personal Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
             SizedBox(height: 8),
            Text(
              '[Placeholder] This section would detail what types of data are collected (e.g., email address, usage data) and how they are used.',
            ),
          ],
        ),
      ),
    );
  }
}
