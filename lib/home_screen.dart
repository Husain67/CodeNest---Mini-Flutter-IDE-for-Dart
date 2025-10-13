import 'package:flutter/material.dart';
import 'package:simple_app/screens/chat_screen.dart';
import 'package:simple_app/screens/create_file_screen.dart';
import 'package:simple_app/screens/file_list_view.dart';
import 'package:simple_app/screens/search_screen.dart';
import 'package:simple_app/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Add SearchScreen and SettingsScreen to the list of main widgets
  static const List<Widget> _widgetOptions = <Widget>[
    FileListView(),
    SearchScreen(),
    CreateFileScreen(),
    SettingsScreen(),
    ChatScreen(), // Added ChatScreen
  ];

  void _onItemTapped(int index) {
    // A map to associate bottom bar index with the screen index in _widgetOptions
    const Map<int, int?> tabIndexMap = {
      0: 0, // Home -> FileListView
      1: 1, // Search -> SearchScreen
      2: 2, // Create -> CreateFileScreen
      3: 4, // AI Chat -> ChatScreen
      4: 3, // Settings -> SettingsScreen
    };

    if (tabIndexMap.containsKey(index)) {
      setState(() {
        _selectedIndex = tabIndexMap[index]!;
      });
    }
  }

  // Map the screen index back to the correct BottomNavigationBar index
  int get _navBarIndex {
    const Map<int, int> screenIndexMap = {
      0: 0, // FileListView -> Home
      1: 1, // SearchScreen -> Search
      2: 2, // CreateFileScreen -> Create
      3: 4, // SettingsScreen -> Settings
      4: 3, // ChatScreen -> AI Chat
    };
    return screenIndexMap[_selectedIndex] ?? 0;
  }

import 'package.simple_app/screens/history_screen.dart';

  static const List<String> _widgetTitles = <String>[
    'Files',
    'Search',
    'Create',
    'Settings',
    'AI Chat',
  ];

  void _navigateToHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_widgetTitles.elementAt(_selectedIndex)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_box_outlined), // New Tab Icon
            tooltip: 'New Tab',
            onPressed: () {
              Provider.of<ChatManager>(context, listen: false).startNewSession();
              // Optionally, switch to the chat tab if not already there
              _onItemTapped(3);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              switch (result) {
                case 'History':
                  _navigateToHistory();
                  break;
                case 'Settings':
                  // Use the same function as the bottom bar to switch to settings
                  _onItemTapped(4);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'History',
                child: Text('History'),
              ),
              const PopupMenuItem<String>(
                value: 'Settings',
                child: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _navBarIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}