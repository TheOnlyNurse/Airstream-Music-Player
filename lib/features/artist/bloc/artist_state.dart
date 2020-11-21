import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../common/providers/moor_database.dart';

abstract class ArtistState extends Equatable {
  const ArtistState() : super();

  @override
  List<Object> get props => [];
}

class SingleArtistInitial extends ArtistState {}

class SingleArtistSuccess extends ArtistState {
  const SingleArtistSuccess(
    this.artist, {
    this.songs,
    this.albums,
    this.similarArtists,
    this.image,
  });

  final Artist artist;
  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> similarArtists;
  final File image;

  SingleArtistSuccess copyWith({
    List<Album> albums,
    List<Song> songs,
    List<Artist> similarArtists,
    File image,
  }) =>
      SingleArtistSuccess(
        artist,
        songs: songs ?? this.songs,
        albums: albums ?? this.albums,
        similarArtists: similarArtists ?? this.similarArtists,
        image: image ?? this.image,
      );

  @override
  List<Object> get props => [songs, albums, similarArtists, image];
}

class SingleArtistFailure extends ArtistState {
  const SingleArtistFailure(this.error);

  final String error;
}
