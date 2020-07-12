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

PageRouteBuilder fadeInSlideRoute(Widget page) {
  assert(page != null);

  return PageRouteBuilder(
    opaque: false,
    pageBuilder: (BuildContext context, _, __) {
      return page;
    },
    transitionsBuilder: (___, Animation<double> animation, ____, Widget child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
  );
}