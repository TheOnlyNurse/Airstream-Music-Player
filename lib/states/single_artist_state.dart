import 'dart:io';

import 'package:airstream/providers/moor_database.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SingleArtistState extends Equatable {
  const SingleArtistState() : super();

  @override
  List<Object> get props => [];
}

class SingleArtistInitial extends SingleArtistState {}

class SingleArtistSuccess extends SingleArtistState {
  final Artist artist;
  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> similarArtists;
  final File image;

  const SingleArtistSuccess(
    this.artist, {
    this.songs,
    this.albums,
    this.similarArtists,
    this.image,
  });

  SingleArtistSuccess copyWith({
    List<Album> albums,
    List<Song> songs,
    List<Artist> similarArtists,
    File image,
  }) {
    return SingleArtistSuccess(
      this.artist,
      songs: songs ?? this.songs,
      albums: albums ?? this.albums,
      similarArtists: similarArtists ?? this.similarArtists,
      image: image ?? this.image,
    );
  }

  @override
  List<Object> get props => [songs, albums, similarArtists, image];
}

class SingleArtistFailure extends SingleArtistState {
  final Widget error;

  const SingleArtistFailure(this.error);
}
