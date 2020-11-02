/// External Packages
import 'package:airstream/providers/moor_database.dart';
import 'package:equatable/equatable.dart';

abstract class SingleArtistEvent extends Equatable {
  const SingleArtistEvent();

  @override
  List<Object> get props => [];
}

class SingleArtistAlbums extends SingleArtistEvent {
  final Artist artist;

  const SingleArtistAlbums({this.artist});
}

class SingleArtistInfo extends SingleArtistEvent {}
