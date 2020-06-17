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
        primaryColor: const Color(0xFF515585),
        accentColor: const Color(0xFF46b5d1),
        scaffoldBackgroundColor: const Color(0xFF080A28),
        canvasColor: const Color(0xFF5a6695),
        cardColor: const Color(0xFF32407b),
        bottomAppBarColor: const Color(0xFF13175B),
        // Base purplish
//        floatingActionButtonTheme: FloatingActionButtonThemeData(
//          backgroundColor: Colors.blueAccent,
//          foregroundColor: Colors.white,
//        ),
        textTheme: TextTheme().copyWith(
          headline4: TextStyle().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LibraryWidget(navKey: libraryNavKey),
        '/musicPlayer': (context) => PlayerScreen(navKey: libraryNavKey),
        '/settings': (context) => SettingsScreen(),
        '/search': (context) => SearchScreen(navKey: libraryNavKey),
      },
    );
  }
}
