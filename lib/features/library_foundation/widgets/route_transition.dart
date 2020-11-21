import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../common/models/playlist_model.dart';
import '../../../common/providers/moor_database.dart';
import '../../album/album_screen.dart';
import '../../album/bloc/album_cubit.dart';
import '../../artist/artist_screen.dart';
import '../../collections/screens/album_list_screen.dart';
import '../../playlist/playlist_screen.dart';
import 'pages.dart';

PageRouteBuilder libraryRouteTransitions(RouteSettings settings) {
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
      return LibraryFoundationPages();
    case 'library/singleArtist':
      return SingleArtistScreen(artist: arguments as Artist);
    case 'library/singleAlbum':
      return AlbumScreen(
        cubit: SingleAlbumCubit()..fetchSongs(arguments as Album),
      );
    case 'library/singlePlaylist':
      return SinglePlaylistScreen(playlist: arguments as Playlist);
    case 'library/albumList':
      return AlbumListScreen(
        future: arguments[0] as Future<Either<String, List<Album>>> Function(),
        title: arguments[1] as String,
      );
    default:
      throw Exception('Unknown route $route');
  }
}
