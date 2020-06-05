import 'package:airstream/models/album_model.dart';

abstract class SingleArtistState {}

class ArtistScreenUninitialised extends SingleArtistState {}

class ArtistScreenLoaded extends SingleArtistState {
  final List<Album> albums;

  ArtistScreenLoaded({this.albums});
}

class ArtistScreenError extends SingleArtistState {}
