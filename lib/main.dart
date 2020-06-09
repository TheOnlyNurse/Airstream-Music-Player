import 'file:///D:/Home/Documents/FlutterProjects/airstream/lib/screens/library.dart';
import 'package:airstream/screens/player_screen.dart';
import 'package:airstream/screens/search_screen.dart';
import 'package:airstream/screens/settings_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> libraryNavKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airstream Music Player',
      theme: ThemeData.dark().copyWith(
          primaryColor: Colors.blue,
          accentColor: Colors.blueAccent,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          )),
      initialRoute: '/',
      routes: {
        '/': (context) => LibraryWidget(libraryNavKey: libraryNavKey),
        '/musicPlayer': (context) => PlayerScreen(),
        '/settings': (context) => SettingsScreen(),
        '/search': (context) => SearchScreen(navKey: libraryNavKey),
      },
    );
  }
}
