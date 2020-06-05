import 'package:airstream/models/song_model.dart';

abstract class SingleAlbumState {}

class AlbumScreenUninitialised extends SingleAlbumState {}

class AlbumScreenError extends SingleAlbumState {}

class AlbumInfoLoaded extends SingleAlbumState {
  final List<Song> songList;

  AlbumInfoLoaded({this.songList});
}
