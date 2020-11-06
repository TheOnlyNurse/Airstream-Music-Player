import 'package:equatable/equatable.dart';

/// Internal
import '../providers/moor_database.dart';

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
