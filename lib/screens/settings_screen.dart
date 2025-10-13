import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/models/settings_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _modelNameController;
  bool _isDarkMode = true; // Assuming default is dark mode based on theme

  @override
  void initState() {
    super.initState();
    final settingsManager = Provider.of<SettingsManager>(context, listen: false);
    _apiKeyController = TextEditingController(text: settingsManager.openRouterApiKey);
    _modelNameController = TextEditingController(text: settingsManager.openRouterModelName);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              const SizedBox(height: 20),

              // OpenRouter Settings
              Card(
                color: Colors.grey[800],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OpenRouter Settings',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _apiKeyController,
                        decoration: const InputDecoration(
                          labelText: 'API Key',
                          hintText: 'Enter your OpenRouter API Key',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          settingsManager.setOpenRouterApiKey(value);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _modelNameController,
                        decoration: const InputDecoration(
                          labelText: 'Model Name',
                          hintText: 'e.g., alibaba/tongyi-deepresearch-30b-a3b:free',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          settingsManager.setOpenRouterModelName(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Appearance Settings
              Card(
                color: Colors.grey[800],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dark Mode',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: settingsManager.isDarkMode,
                        onChanged: (value) {
                          settingsManager.toggleDarkMode();
                        },
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
