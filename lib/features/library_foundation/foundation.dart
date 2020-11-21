import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../common/repository/audio_repository.dart';
import '../../global_assets.dart';
import '../mini_player/bloc/mini_player_bloc.dart';
import '../mini_player/mini_player.dart';
import '../mini_player/mini_player_shade.dart';
import '../navigation_bar/bloc/navigation_bar_bloc.dart';
import '../navigation_bar/navigation_bar.dart';
import 'widgets/route_transition.dart';

class LibraryFoundation extends StatelessWidget {
  const LibraryFoundation({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MiniPlayerBloc>(create: (_) => MiniPlayerBloc(
          screenHeight: MediaQuery.of(context).size.height,
          navigator: Navigator.of(context, rootNavigator: true),
          audioRepository: GetIt.I.get<AudioRepository>(),
        )),
        BlocProvider<NavigationBarBloc>(
          create: (context) => NavigationBarBloc(
            playerBloc: context.read<MiniPlayerBloc>(),
          ),
        ),
      ],
      child: WillPopScope(
        onWillPop: () async {
          if (libraryNavigator.currentState.canPop()) {
            libraryNavigator.currentState.pop();
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                Navigator(
                  key: libraryNavigator,
                  initialRoute: 'library/',
                  onGenerateRoute: libraryRouteTransitions,
                ),
                MiniPlayerShade(),
              ],
            ),
          ),
          floatingActionButton: MiniPlayerButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: NavigationBar(),
        ),
      ),
    );
  }
}
