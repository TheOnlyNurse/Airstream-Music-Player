import 'package:airstream/providers/moor_database.dart';
import 'package:airstream/models/playlist_model.dart';

abstract class SongListDelegate {
  const SongListDelegate();
}

class PlaylistSongList extends SongListDelegate {
  final Playlist playlist;

  const PlaylistSongList({this.playlist});
}

class SimpleSongList extends SongListDelegate {
  final List<Song> initialSongs;
  final bool canRemoveStar;

  const SimpleSongList({this.initialSongs, this.canRemoveStar = false});
}

class AlbumSongList extends SongListDelegate {
  final Album album;

  const AlbumSongList({this.album});
}
