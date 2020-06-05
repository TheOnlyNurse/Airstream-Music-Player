import 'package:airstream/bloc/player_button_bloc.dart';
import 'package:airstream/bloc/nav_bar_bloc.dart';
import 'package:airstream/bloc/player_target_bloc.dart';
import 'package:airstream/events/nav_bar_event.dart';
import 'package:airstream/events/player_button_event.dart';
import 'package:airstream/screens/albums_route.dart';
import 'package:airstream/screens/artists_route.dart';
import 'package:airstream/screens/playlists.dart';
import 'package:airstream/screens/starred_screen.dart';
import 'package:airstream/screens/single_artist_screen.dart';
import 'package:airstream/screens/single_album_screen.dart';
import 'package:airstream/states/nav_bar_state.dart';
import 'package:airstream/widgets/player_button.dart';
import 'package:airstream/widgets/screen_transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/nav_bar.dart';

class LibraryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBarBloc>(
          create: (context) => NavigationBarBloc(),
        ),
        BlocProvider<PlayerButtonBloc>(
          create: (context) => PlayerButtonBloc(),
        ),
        BlocProvider<PlayerTargetBloc>(
          create: (context) => PlayerTargetBloc(),
        ),
      ],
      child: _LibraryPage(),
    );
  }
}

class _LibraryPage extends StatefulWidget {
  State<_LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<_LibraryPage> {
  PageController _pageController;
  final GlobalKey<NavigatorState> libraryNavKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      keepPage: false,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBarBloc, NavigationBarState>(
      listener: (context, state) {
        if (state is HomePage && state.shouldNavigate) {
          if (libraryNavKey.currentState.canPop()) {
            libraryNavKey.currentState.popUntil((route) => route.isFirst);
          }
          _pageController.animateToPage(
            state.index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          if (libraryNavKey.currentState.canPop()) {
            libraryNavKey.currentState.pop();
            return false;
          }
          return true;
        },
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                Navigator(
                  key: libraryNavKey,
                  initialRoute: 'library/',
                  onGenerateRoute: (settings) {
                    WidgetBuilder builder;
                    switch (settings.name) {
                      case 'library/':
                        builder = (context) => HomePages(pageController: _pageController);
                        break;
                      case 'library/singleArtist':
                        builder =
                            (context) => SingleArtistScreen(artist: settings.arguments);
                        break;
                      case 'library/singleAlbum':
                        builder =
                            (context) => SingleAlbumScreen(album: settings.arguments);
                        break;
                      default:
                        throw Exception('Unknown route ${settings.name}');
                    }
                    return ScaleScreenTransition(builder: builder, settings: settings);
                  },
                ),
                PlayerButtonTarget(),
              ],
            ),
          ),
          floatingActionButton: PlayerButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: AirstreamNavBar(),
        ),
      ),
    );
  }
}

class HomePages extends StatelessWidget {
  final PageController pageController;

  HomePages({this.pageController});

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      children: <Widget>[
        PlaylistsRoute(),
        ArtistsRoute(),
        AlbumsRoute(),
        StarredScreen(),
      ],
      onPageChanged: (index) =>
          context.bloc<NavigationBarBloc>().add(UpdateNavBar(index: index)),
      physics: BouncingScrollPhysics(),
    );
  }
}
