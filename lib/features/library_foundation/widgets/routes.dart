part of '../foundation.dart';

Widget _route(String route, dynamic arguments) {
  switch (route) {
    case 'library/':
      return _Pages();
    case 'library/singleArtist':
      return SingleArtistScreen(artist: arguments as Artist);
    case 'library/singleAlbum':
      return AlbumScreen(
        cubit: SingleAlbumCubit(
          albumRepository: GetIt.I.get<AlbumRepository>(),
          songRepository: GetIt.I.get<SongRepository>(),
        )..fetchSongs(arguments as Album),
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
