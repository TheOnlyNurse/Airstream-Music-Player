import 'package:airstream/bloc/mini_player_bloc.dart';
import 'package:airstream/bloc/nav_bar_bloc.dart';
import 'package:airstream/bloc/player_target_bloc.dart';
import 'package:airstream/events/nav_bar_event.dart';
import 'package:airstream/screens/album_list_screen.dart';
import 'package:airstream/screens/home_screen.dart';
import 'package:airstream/screens/single_playlist_screen.dart';
import 'package:airstream/screens/starred_screen.dart';
import 'package:airstream/screens/single_artist_screen.dart';
import 'package:airstream/screens/single_album_screen.dart';
import 'package:airstream/widgets/player/mini_player.dart';
import 'package:airstream/widgets/screen_transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/nav_bar.dart';

class LibraryWidget extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;

  const LibraryWidget({Key key, this.navKey}) : super(key: key);

  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<LibraryWidget> {
  PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      keepPage: false,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

	MaterialPageRoute _generateRoute(RouteSettings settings) {
    {
      WidgetBuilder builder;
      switch (settings.name) {
        case 'library/':
          builder = (context) => _HomePages(pageController: pageController);
          break;
        case 'library/singleArtist':
          builder = (context) => SingleArtistScreen(artist: settings.arguments);
          break;
        case 'library/singleAlbum':
          builder = (context) => SingleAlbumScreen(album: settings.arguments);
          break;
        case 'library/singlePlaylist':
          builder = (context) => SinglePlaylistScreen(playlist: settings.arguments);
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
        BlocProvider<MinimisedPlayerBloc>(create: (context) => MinimisedPlayerBloc()),
        BlocProvider<PlayerTargetBloc>(create: (context) => PlayerTargetBloc()),
        BlocProvider<NavigationBarBloc>(
          create: (context) => NavigationBarBloc(
						playerBloc: context.bloc<MinimisedPlayerBloc>(),
            pageController: pageController,
            navigatorKey: widget.navKey,
          ),
        ),
      ],
      child: WillPopScope(
        onWillPop: () async {
          final libraryNavKey = this.widget.navKey;

          if (libraryNavKey.currentState.canPop()) {
            libraryNavKey.currentState.pop();
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
                  key: this.widget.navKey,
                  initialRoute: 'library/',
                  onGenerateRoute: _generateRoute,
                ),
                PlayerButtonTarget(),
              ],
            ),
          ),
          floatingActionButton: PlayerActionButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: NavigationBar(),
        ),
      ),
    );
  }
}

class _HomePages extends StatelessWidget {
  final PageController pageController;

  const _HomePages({this.pageController});

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      children: <Widget>[
        HomeScreen(),
        StarredScreen(),
      ],
      onPageChanged: (int index) {
        context.bloc<NavigationBarBloc>().add(NavigationBarUpdate(index));
      },
      physics: BouncingScrollPhysics(),
    );
  }
}
