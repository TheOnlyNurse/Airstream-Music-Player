import 'package:airstream/providers/moor_database.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class StarredState extends Equatable {
  const StarredState();

  @override
  List<Object> get props => [];
}

class StarredInitial extends StarredState {}

class StarredFailure extends StarredState {
  final Widget error;

  StarredFailure(this.error);
}

class StarredSuccess extends StarredState {
  final List<Album> albums;
  final List<Song> songs;

  StarredSuccess({this.albums, this.songs});

  StarredSuccess copyWith({
    List<Album> albums,
    List<Song> songs,
  }) {
    return StarredSuccess(
      albums: albums ?? this.albums,
      songs: songs ?? this.songs,
    );
  }

  @override
  List<Object> get props => [albums, songs];
}
