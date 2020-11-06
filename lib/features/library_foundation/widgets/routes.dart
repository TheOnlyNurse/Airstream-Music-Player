part of '../foundation.dart';

Widget _route(String route, dynamic arguments) {
  switch (route) {
    case 'library/':
      return _Pages();
    case 'library/singleArtist':
      return SingleArtistScreen(artist: arguments);
    case 'library/singleAlbum':
      return SingleAlbumScreen(
        cubit: SingleAlbumCubit(
          albumRepository: GetIt.I.get<AlbumRepository>(),
          songRepository: GetIt.I.get<SongRepository>(),
        )..fetchSongs(arguments),
      );
    case 'library/singlePlaylist':
      return SinglePlaylistScreen(playlist: arguments);
    case 'library/albumList':
      return AlbumListScreen(future: arguments);
    default:
      throw Exception('Unknown route $route');
  }
}
