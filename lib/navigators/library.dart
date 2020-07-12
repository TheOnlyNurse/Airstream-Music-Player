import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airstream/bloc/mini_player_bloc.dart';
import 'package:airstream/bloc/nav_bar_bloc.dart';
import 'package:airstream/bloc/player_target_bloc.dart';

// Widgets
import 'package:airstream/widgets/player/mini_player.dart';
import 'package:airstream/widgets/screen_transitions.dart';
import 'package:airstream/widgets/nav_bar.dart';

// Screens that can be navigated from the library
import 'package:airstream/screens/album_list_screen.dart';
import 'package:airstream/screens/home_screen.dart';
import 'package:airstream/screens/single_playlist_screen.dart';
import 'package:airstream/screens/starred_screen.dart';
import 'package:airstream/screens/single_artist_screen.dart';
import 'package:airstream/screens/single_album_screen.dart';
import 'package:simple_animations/simple_animations.dart';

class LibraryNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;

  const LibraryNavigator({Key key, this.navKey}) : super(key: key);

  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<LibraryNavigator> {
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
          builder = (context) => SingleAlbumScreen(album: settings.arguments);
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
            navigatorKey: widget.navKey,
          ),
        ),
      ],
      child: WillPopScope(
        onWillPop: () async {
					if (widget.navKey.currentState.canPop()) {
						widget.navKey.currentState.pop();
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
					floatingActionButtonLocation:
					FloatingActionButtonLocation.centerDocked,
					bottomNavigationBar: NavigationBar(
						index: index,
						onTap: (newIndex) {
							if (widget.navKey.currentState.canPop()) {
								widget.navKey.currentState.popUntil((route) => route.isFirst);
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
				return HomeScreen();
				break;
			case 1:
				return StarredScreen();
				break;
			default:
				throw UnimplementedError('Page index: $index');
		}
	}
}
