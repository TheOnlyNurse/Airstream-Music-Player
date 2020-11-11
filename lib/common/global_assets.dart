import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ErrorSolutions {
  // This class is not meant to be instantiated or extended.
  // ignore: unused_element
  ErrorSolutions._();

  static const network =
      'Network status could be offline. Check if this app has network access.';
  static const database =
      'The local database could be out-of-date. Try refreshing it.';
  static const report =
      "This is an unusual error. Please contact the developer.";
}

class WidgetProperties {
  // This class is not meant to be instantiated or extended.
  // ignore: unused_element
  WidgetProperties._();

  static const albumsDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 250,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 1 / 1.25,
  );

  static const scrollPhysics = BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );
}

class AirstreamTheme {
  // This class is not meant to be instantiated or extended.
  // ignore: unused_element
  AirstreamTheme._();

  static const navyBlue = ColorScheme(
    primary: Color(0xFF515585),
    primaryVariant: Color(0xFF252c58),
    secondary: Color(0xFF46b5d1),
    secondaryVariant: Color(0xFF0085a0),
    surface: Color(0xFF252c58),
    background: Color(0xFF080A28),
    error: Color(0xFFD84315),
    onPrimary: Color(0xFF515585),
    onSecondary: Color(0xFF000000),
    onSurface: Color(0xFFFFFFFF),
    onBackground: Color.fromRGBO(255, 255, 255, 0.6),
    onError: Color(0xFF000000),
    brightness: Brightness.dark,
  );
}

final rootNavigator = GlobalKey<NavigatorState>();
final libraryNavigator = GlobalKey<NavigatorState>();

/// Returns the singleton stored in get it if the value is null.
T getIt<T>(T value) => value ?? GetIt.I.get<T>();