import 'package:flutter/material.dart';

import 'common/global_assets.dart';
import 'features/library_foundation/foundation.dart';
import 'features/loading_splash/splash_screen.dart';
import 'features/player/player_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_foundation.dart';

void main() => runApp(_Foundation());

class _Foundation extends StatelessWidget {

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
      navigatorKey: rootNavigator,
      routes: <String, WidgetBuilder>{
        '/musicPlayer': (context) => const PlayerScreen(),
        '/settings': (context) => SettingsScreen(),
        '/search': (context) => SearchScreen(),
        '/library': (context) => const LibraryFoundation(),
      },
      home: SplashScreen(),
    );
  }
}
