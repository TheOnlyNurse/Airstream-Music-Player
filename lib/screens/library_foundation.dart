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
import '../complex_widgets/screen_transitions.dart';
import '../complex_widgets/nav_bar.dart';

// Screens that can be navigated from the library
import 'album_list_screen.dart';
import 'home_screen.dart';
import 'single_playlist_screen.dart';
import 'starred_screen.dart';
import 'single_artist_screen.dart';
import 'single_album_screen.dart';

class LibraryFoundation extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const LibraryFoundation({Key key, this.navigatorKey}) : super(key: key);

  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<LibraryFoundation> {
  int index = 0;

  MaterialPageRoute _generateRoute(RouteSettings settings) {
    {
      WidgetBuilder builder;
      switch (settings.name) {
        case 'library/':
          builder = (context) => _HomePages(index: index);
          break;
        case 'library/singleArtist':
          builder = (context) => SingleArtistScreen(artist: settings.arguments);
          break;
        case 'library/singleAlbum':
          builder = (context) => SingleAlbumScreen(
                album: settings.arguments,
                cubit: SingleAlbumCubit(),
              );
          break;
        case 'library/singlePlaylist':
          builder =
              (context) => SinglePlaylistScreen(playlist: settings.arguments);
          break;
        case 'library/albumList':
          builder = (context) => AlbumListScreen(future: settings.arguments);
          break;
        default:
          throw Exception('Unknown route ${settings.name}');
      }
      return ScaleScreenTransition(builder: builder, settings: settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MiniPlayerBloc>(create: (context) => MiniPlayerBloc()),
        BlocProvider<PlayerTargetBloc>(create: (context) => PlayerTargetBloc()),
        BlocProvider<NavigationBarBloc>(
          create: (context) => NavigationBarBloc(
            playerBloc: context.bloc<MiniPlayerBloc>(),
            navigatorKey: widget.navigatorKey,
          ),
        ),
      ],
      child: WillPopScope(
        onWillPop: () async {
          if (widget.navigatorKey.currentState.canPop()) {
            widget.navigatorKey.currentState.pop();
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
                  key: this.widget.navigatorKey,
                  initialRoute: 'library/',
                  onGenerateRoute: _generateRoute,
                ),
                PlayerButtonTarget(),
              ],
            ),
          ),
          floatingActionButton: PlayerActionButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: NavigationBar(
            index: index,
            onTap: (newIndex) {
              if (widget.navigatorKey.currentState.canPop()) {
                widget.navigatorKey.currentState.popUntil((route) => route.isFirst);
              } else {
                setState(() {
                  index = newIndex;
                });
              }
            },
          ),
        ),
      ),
    );
  }
}

class _HomePages extends StatelessWidget {
  final int index;

  const _HomePages({this.index});

  @override
  Widget build(BuildContext context) {
    switch (index) {
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
        throw UnimplementedError('Page index: $index');
    }
  }
}
