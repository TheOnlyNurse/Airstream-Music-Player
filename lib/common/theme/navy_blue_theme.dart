import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';

mixin NavyBlueTheme implements ColorScheme {
  /// The overall brightness of this color scheme
  Brightness get brightness => Brightness.dark;

  /// A color that typically appears behind scrollable content
  Color get background => const Color(0xFF080A28);

  /// A color that's clearly legible when drawn on background
  Color get onBackground => const Color(0xFFFFFFFF).withOpacity(0.6);

  /// The background color for widgets like Card
  Color get surface => const Color(0xFF32407b);

  /// A color that's clearly legible when drawn on surface
  Color get onSurface => const Color(0xFFFFFFFF);

  /// The color displayed most frequently across your app’s screens and components
  Color get primary => const Color(0xFF515585);

  /// A darker version of the primary color
  Color get primaryVariant => const Color(0xFF252c58);

  /// A color that's clearly legible when drawn on primary
  Color get onPrimary => const Color(0xFFFFFFFF);

  /// An accent color that, when used sparingly, calls attention to parts of your app
  Color get secondary => const Color(0xFF46b5d1);

  /// A darker version of the secondary color
  Color get secondaryVariant => const Color(0xFF0085a0);

  /// A color that's clearly legible when drawn on secondary
  Color get onSecondary => const Color(0xFF000000);

  /// The color to use for input validation errors, e.g. for InputDecoration.errorText
  Color get error => const Color(0xFFD84315);

  /// A color that's clearly legible when drawn on error
  Color get onError => const Color(0xFF000000);

  @override
  ColorScheme copyWith({Color primary, Color primaryVariant, Color secondary, Color secondaryVariant, Color surface, Color background, Color error, Color onPrimary, Color onSecondary, Color onSurface, Color onBackground, Color onError, Brightness brightness}) {
    // TODO: implement copyWith
    throw UnimplementedError();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    // TODO: implement debugFillProperties
  }

  @override
  DiagnosticsNode toDiagnosticsNode({String name, DiagnosticsTreeStyle style}) {
    // TODO: implement toDiagnosticsNode
    throw UnimplementedError();
  }

  @override
  String toStringShort() {
    // TODO: implement toStringShort
    throw UnimplementedError();
  }
}
