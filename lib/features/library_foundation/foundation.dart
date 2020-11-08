import 'package:airstream/common/models/playlist_model.dart';
import 'package:airstream/common/models/repository_response.dart';
import 'package:airstream/common/repository/playlist_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../common/providers/moor_database.dart';
import '../../common/repository/album_repository.dart';
import '../../common/repository/artist_repository.dart';
import '../../common/repository/song_repository.dart';
import '../../common/screens/album_list_screen.dart';
import '../album/bloc/album_cubit.dart';
import '../album/screen.dart';
import '../artist/artist_screen.dart';
import '../home/home_screen.dart';
import '../mini_player/bloc/mini_player_bloc.dart';
import '../mini_player/mini_player.dart';
import '../mini_player/mini_player_shade.dart';
import '../navigation_bar/bloc/navigation_bar_bloc.dart';
import '../navigation_bar/navigation_bar.dart';
import '../playlist/playlist_screen.dart';
import '../starred/starred_screen.dart';

/// Library
part 'widgets/pages.dart';
part 'widgets/route_transition.dart';
part 'widgets/routes.dart';

class LibraryFoundation extends StatelessWidget {
  const LibraryFoundation({Key key, this.navigatorKey}) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MiniPlayerBloc>(create: (_) => MiniPlayerBloc(
          screenHeight: MediaQuery.of(context).size.height,
          navigator: Navigator.of(context, rootNavigator: true),
        )),
        BlocProvider<NavigationBarBloc>(
          create: (context) => NavigationBarBloc(
            playerBloc: context.bloc<MiniPlayerBloc>(),
            navigatorKey: navigatorKey,
          ),
        ),
      ],
      child: WillPopScope(
        onWillPop: () async {
          final navigatorState = navigatorKey.currentState;
          if (navigatorState.canPop()) {
            navigatorState.pop();
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
                  key: navigatorKey,
                  initialRoute: 'library/',
                  onGenerateRoute: _routeTransition,
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
