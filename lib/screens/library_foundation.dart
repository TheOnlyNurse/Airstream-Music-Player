/// External Packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// Internal Links
// Repositories
import '../repository/album_repository.dart';
import '../repository/artist_repository.dart';

// Blocs
import '../bloc/mini_player_bloc.dart';
import '../bloc/nav_bar_bloc.dart';
import '../bloc/player_target_bloc.dart';
import '../cubit/single_album_cubit.dart';

// Widgets
import '../complex_widgets/player/mini_player.dart';
import '../complex_widgets/nav_bar.dart';

// Screens that can be navigated from the library
import 'album_list_screen.dart';
import 'home_screen.dart';
import 'single_playlist_screen.dart';
import 'starred_screen.dart';
import 'single_artist_screen.dart';
import 'single_album_screen.dart';

class LibraryFoundation extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const LibraryFoundation({Key key, this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MiniPlayerBloc>(create: (_) => MiniPlayerBloc()),
        BlocProvider<PlayerTargetBloc>(create: (_) => PlayerTargetBloc()),
        BlocProvider<NavigationBarBloc>(
          create: (context) => NavigationBarBloc(
            playerBloc: context.bloc<MiniPlayerBloc>(),
            navigatorKey: navigatorKey,
          ),
        ),
      ],
      child: WillPopScope(
        onWillPop: () async {
          var navigatorState = navigatorKey.currentState;
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
                  onGenerateRoute: _routeBuilder,
                ),
                PlayerButtonTarget(),
              ],
            ),
          ),
          floatingActionButton: PlayerActionButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: NavigationBar(),
        ),
      ),
    );
  }
}

class _Pages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBarBloc, NavigationBarState>(
      builder: (context, state) {
        switch (state.pageIndex) {
          case 0:
            return HomeScreen(
              albumRepository: GetIt.I.get<AlbumRepository>(),
              artistRepository: GetIt.I.get<ArtistRepository>(),
            );
            break;
          case 1:
            return StarredScreen();
            break;
          default:
            throw UnimplementedError('Page index: ${state.pageIndex}');
        }
      },
    );
  }
}

PageRouteBuilder _routeBuilder(RouteSettings settings) {
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

Widget _route(String route, dynamic arguments) {
  switch (route) {
    case 'library/':
      return _Pages();
    case 'library/singleArtist':
      return SingleArtistScreen(artist: arguments);
    case 'library/singleAlbum':
      return SingleAlbumScreen(
        cubit: SingleAlbumCubit()..fetchSongs(arguments),
      );
    case 'library/singlePlaylist':
      return SinglePlaylistScreen(playlist: arguments);
    case 'library/albumList':
      return AlbumListScreen(future: arguments);
    default:
      throw Exception('Unknown route $route');
  }
}
