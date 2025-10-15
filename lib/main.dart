import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/home_screen.dart';
import 'package:simple_app/models/file_manager.dart';
import 'package:simple_app/models/settings_manager.dart';
import 'package:simple_app/models/chat_manager.dart';
import 'package:simple_app/screens/error_screen.dart';

import 'package:easy_localization/easy_localization.dart';

// Global key to access the navigator from anywhere.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runZonedGuarded<Future<void>>(() async {
    // This will catch all errors during rendering and show our custom screen.
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return ErrorScreen(
        error: details.exception,
        stackTrace: details.stack ?? StackTrace.current,
      );
    };

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('hi'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => FileManager()),
            ChangeNotifierProvider(create: (context) => SettingsManager()),
            ChangeNotifierProvider(create: (context) => ChatManager()),
          ],
          child: const MyApp(),
        ),
      ),
    );
  }, (error, stack) {
    // This will catch all other unhandled errors and navigate to our error screen.
    debugPrint('Caught unhandled error: $error');
    debugPrint(stack.toString());
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(MaterialPageRoute(
        builder: (context) => ErrorScreen(error: error, stackTrace: stack),
      ));
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsManager>(
      builder: (context, settingsManager, child) {
        return MaterialApp(
          navigatorKey: navigatorKey, // Assign the global key
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          title: 'Dart Edit Runner',
          theme: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey[600],
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.grey[900],
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey[400],
            ),
          ),
          themeMode: settingsManager.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}