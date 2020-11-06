part of 'loading_splash_cubit.dart';

abstract class SplashScreenState {
  const SplashScreenState();
}

class SplashScreenLoading extends SplashScreenState {}

class SplashScreenSuccess extends SplashScreenState {
  const SplashScreenSuccess({this.shouldReplace = false});

  final bool shouldReplace;
}
