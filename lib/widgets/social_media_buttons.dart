import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaButtons extends StatelessWidget {
  const SocialMediaButtons({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Can't launch URL, show an error
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.facebook), // Placeholder, ideally use a brand icon
          iconSize: 40,
          onPressed: () => _launchURL('https://www.facebook.com'),
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(Icons.camera_alt), // Placeholder for Instagram
          iconSize: 40,
          onPressed: () => _launchURL('https://www.instagram.com'),
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(Icons.chat_bubble), // Placeholder for Twitter/X
          iconSize: 40,
          onPressed: () => _launchURL('https://www.twitter.com'),
        ),
      ],
    );
  }
}
