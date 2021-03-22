import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Internal
import 'bloc/loading_splash_cubit.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashScreenCubit cubit;

  @override
  void initState() {
    cubit = SplashScreenCubit()..loadDatabases();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF32407b),
      child: BlocConsumer(
        bloc: cubit,
        listener: (context, state) {
          if (state is SplashScreenSuccess && state.shouldReplace) {
            Navigator.pushReplacementNamed(context, '/library');
          }
        },
        builder: (context, state) {
          if (state is SplashScreenLoading) {
            return _Splash(onComplete: () => cubit.animationEnded());
          }

          if (state is SplashScreenSuccess) {
            return const _Splash(isLoading: false);
          }

          return Center(
            child: Text(
              'Could not read state: $state',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({Key key, this.isLoading = true, this.onComplete})
      : super(key: key);

  final bool isLoading;
  final Function onComplete;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 250,
        child: FlareActor(
          "lib/common/graphics/splash-screen.flr",
          animation: isLoading ? 'loading' : 'done',
          callback: (_) {
            if (onComplete != null) onComplete();
          },
        ),
      ),
    );
  }
}
