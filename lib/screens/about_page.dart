import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About AI Chatbot', style: GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'About This AI Chatbot',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This application is an advanced AI-powered chatbot designed to assist you with a wide range of tasks. Powered by cutting-edge language models, it can understand and generate human-like text, making interactions feel natural and intuitive.',
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),
            Text(
              'Key Features:',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Natural Language Conversation'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Context-aware responses'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Support for multiple languages'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Secure and private conversations'),
            ),
            const SizedBox(height: 24),
            Text(
              'Version',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('1.0.0'),
          ],
        ),
      ),
    );
  }
}
