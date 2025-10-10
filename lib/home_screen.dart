import 'package:flutter/material.dart';
import 'package:simple_app/screens/coming_soon_screen.dart';
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
  ];

  void _onItemTapped(int index) {
    // A map to associate bottom bar index with the screen index in _widgetOptions
    const Map<int, int?> tabIndexMap = {
      0: 0, // Home -> FileListView
      1: 1, // Search -> SearchScreen
      2: 2, // Create -> CreateFileScreen
      4: 3, // Settings -> SettingsScreen
    };

    if (tabIndexMap.containsKey(index)) {
      setState(() {
        _selectedIndex = tabIndexMap[index]!;
      });
    } else if (index == 3) { // AI Chat
      _navigateToComingSoon('AI Chat');
    }
  }

  void _navigateToComingSoon(String featureName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ComingSoonScreen(featureName: featureName),
      ),
    );
  }

  // Map the screen index back to the correct BottomNavigationBar index
  int get _navBarIndex {
    const Map<int, int> screenIndexMap = {
      0: 0, // FileListView -> Home
      1: 1, // SearchScreen -> Search
      2: 2, // CreateFileScreen -> Create
      3: 4, // SettingsScreen -> Settings
    };
    return screenIndexMap[_selectedIndex] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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