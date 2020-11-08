import 'package:airstream/common/static_assets.dart';
import 'package:flutter/material.dart';

import 'features/library_foundation/foundation.dart';
import 'features/loading_splash/splash_screen.dart';
import 'features/player/player_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_foundation.dart';

void main() => runApp(_Foundation(rootNavigator: GlobalKey()));

class _Foundation extends StatelessWidget {
  const _Foundation({Key key, @required this.rootNavigator})
      : super(key: key);

  final GlobalKey<NavigatorState> rootNavigator;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airstream Music Player',
      theme: ThemeData.from(
        colorScheme: AirstreamTheme.navyBlue,
        textTheme: const TextTheme().copyWith(
          headline4: const TextStyle().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ).copyWith(
        sliderTheme: const SliderThemeData().copyWith(
          tickMarkShape: SliderTickMarkShape.noTickMark,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        ),
      ),
      routes: <String, WidgetBuilder>{
        '/musicPlayer': (context) => PlayerScreen(navKey: rootNavigator),
        '/settings': (context) => SettingsScreen(),
        '/search': (context) => SearchScreen(navKey: rootNavigator),
        '/library': (context) => LibraryFoundation(navigatorKey: rootNavigator),
      },
      home: SplashScreen(),
    );
  }
}
