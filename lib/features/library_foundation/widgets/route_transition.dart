part of '../foundation.dart';

PageRouteBuilder _routeTransition(RouteSettings settings) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, __) {
      return Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 12,
        child: _route(settings.name, settings.arguments),
      );
    },
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
          ),
          child: child,
        ),
      );
    },
  );
}