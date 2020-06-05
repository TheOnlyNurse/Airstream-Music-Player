import 'package:airstream/models/artist_model.dart';

abstract class SingleArtistEvent {}

class FetchArtistInfo extends SingleArtistEvent {
  final Artist artist;

  FetchArtistInfo({this.artist});
}
