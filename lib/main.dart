import 'package:airstream/screens/library_foundation.dart';
import 'package:airstream/screens/player_screen.dart';
import 'package:airstream/screens/search_screen.dart';
import 'package:airstream/screens/settings_screen.dart';
import 'package:airstream/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(_Foundation(libraryNavigator: GlobalKey()));

class _Foundation extends StatelessWidget {
  const _Foundation({Key key, @required this.libraryNavigator})
      : super(key: key);

  final GlobalKey<NavigatorState> libraryNavigator;

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
        dialogBackgroundColor: const Color(0xFF32407b),
        textTheme: TextTheme().copyWith(
          headline4: TextStyle().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        sliderTheme: SliderThemeData().copyWith(
          tickMarkShape: SliderTickMarkShape.noTickMark,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
        ),
      ),
      routes: <String, WidgetBuilder>{
        '/musicPlayer': (context) => PlayerScreen(navKey: libraryNavigator),
        '/settings': (context) => SettingsScreen(),
        '/search': (context) => SearchScreen(navKey: libraryNavigator),
        '/library': (context) => LibraryFoundation(navKey: libraryNavigator),
      },
      home: SplashScreen(),
    );
  }
}
