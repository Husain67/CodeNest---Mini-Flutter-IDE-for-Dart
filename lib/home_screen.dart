import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/models/chat_manager.dart';
import 'package:simple_app/screens/chat_screen.dart';
import 'package:simple_app/screens/create_file_screen.dart';
import 'package:simple_app/screens/file_list_view.dart';
import 'package:simple_app/screens/history_screen.dart';
import 'package:simple_app/screens/search_screen.dart';
import 'package:simple_app/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // The order of screens/widgets in this list directly matches the bottom nav bar.
  static const List<Widget> _widgetOptions = <Widget>[
    FileListView(),
    SearchScreen(),
    CreateFileScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  // The titles corresponding to the widgets above.
  static const List<String> _widgetTitles = <String>[
    'Files',
    'Search',
    'Create',
    'AI Chat',
    'Settings',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
              // Switch to the chat tab (index 3)
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
                  // Switch to settings tab (index 4)
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
        currentIndex: _selectedIndex, // The index is now direct and simple
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
