import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/models/settings_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.grey[850],
      ),
      body: Consumer<SettingsManager>(
        builder: (context, settingsManager, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Theme Selector
              Card(
                color: Colors.grey[800],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Editor Theme',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        value: settingsManager.currentThemeName,
                        isExpanded: true,
                        items: settingsManager.availableThemeNames.map((String themeName) {
                          return DropdownMenuItem<String>(
                            value: themeName,
                            child: Text(themeName),
                          );
                        }).toList(),
                        onChanged: (String? newTheme) {
                          if (newTheme != null) {
                            settingsManager.setTheme(newTheme);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Font Size Adjuster
              Card(
                color: Colors.grey[800],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Font Size',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: settingsManager.decreaseFontSize,
                          ),
                          Text(
                            settingsManager.fontSize.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 20),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: settingsManager.increaseFontSize,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}