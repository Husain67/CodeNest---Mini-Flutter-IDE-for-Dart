import 'package:flutter/material.dart';
import 'package:simple_app/screens/coming_soon_screen.dart';
import 'package:simple_app/screens/create_file_screen.dart';
import 'package:simple_app/screens/file_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    FileListView(),
    CreateFileScreen(),
  ];

  void _onItemTapped(int index) {
    switch (index) {
      case 0: // Home
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 2: // Create
        setState(() {
          _selectedIndex = 1;
        });
        break;
      case 1: // Search
        _navigateToComingSoon('Search');
        break;
      case 3: // AI Chat
        _navigateToComingSoon('AI Chat');
        break;
      case 4: // Settings
        _navigateToComingSoon('Settings');
        break;
    }
  }

  void _navigateToComingSoon(String featureName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ComingSoonScreen(featureName: featureName),
      ),
    );
  }

  int get _navBarIndex {
    if (_selectedIndex == 0) return 0; // Home
    if (_selectedIndex == 1) return 2; // Create
    return 0;
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