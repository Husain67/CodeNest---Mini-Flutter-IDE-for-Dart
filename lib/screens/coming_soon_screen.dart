import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  final String featureName;

  const ComingSoonScreen({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(featureName),
        backgroundColor: Colors.grey[850],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'The "$featureName" feature is under development.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}