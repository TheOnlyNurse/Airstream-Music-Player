import 'package:flutter/material.dart';

class ScaleScreenTransition<T> extends MaterialPageRoute<T> {
  ScaleScreenTransition({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          ),
        ),
        child: child,
      ),
    );
  }
}

class SizeScreenTransition<T> extends MaterialPageRoute<T> {
  SizeScreenTransition({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return Align(
      child: SizeTransition(
        sizeFactor: animation,
        child: child,
      ),
    );
  }
}
