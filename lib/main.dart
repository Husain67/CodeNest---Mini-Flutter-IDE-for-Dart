import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/home_screen.dart';
import 'package:simple_app/models/file_manager.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FileManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart Edit Runner',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[900],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[400],
        ),
      ),
      home: const HomeScreen(),
    );
  }
}