import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../common/repository/album_repository.dart';
import '../../../common/repository/artist_repository.dart';
import '../../../common/repository/playlist_repository.dart';
import '../../../common/repository/song_repository.dart';
import '../../home/home_screen.dart';
import '../../navigation_bar/bloc/navigation_bar_bloc.dart';
import '../../starred/bloc/starred_bloc.dart';
import '../../starred/starred_screen.dart';

class LibraryFoundationPages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBarBloc, NavigationBarState>(
      builder: (context, state) {
        switch (state.pageIndex) {
          case 0:
            return HomeScreen(
              albumRepository: GetIt.I.get<AlbumRepository>(),
              artistRepository: GetIt.I.get<ArtistRepository>(),
              playlistRepository: GetIt.I.get<PlaylistRepository>(),
            );
            break;
          case 1:
            return BlocProvider(
              create: (context) => StarredBloc(
                album: GetIt.I.get<AlbumRepository>(),
                song: GetIt.I.get<SongRepository>(),
              )..add(StarredFetch()),
              child: const StarredScreen(),
            );
            break;
          default:
            throw UnimplementedError('Page index: ${state.pageIndex}');
        }
      },
    );
  }
}
