import 'package:airstream/models/album_model.dart';

abstract class SingleAlbumEvent {}

class FetchAlbumInfo extends SingleAlbumEvent {
  final Album album;

  FetchAlbumInfo({this.album});
}
