import 'package:airstream/data_providers/moor_database.dart';

abstract class SingleAlbumState {}

class AlbumScreenUninitialised extends SingleAlbumState {}

class AlbumScreenError extends SingleAlbumState {}

class AlbumInfoLoaded extends SingleAlbumState {
  final List<Song> songList;

  AlbumInfoLoaded({this.songList});
}
