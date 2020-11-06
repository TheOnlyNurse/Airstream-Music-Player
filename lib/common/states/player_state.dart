import 'dart:io';

import 'package:equatable/equatable.dart';

/// Internal
import '../providers/moor_database.dart';

abstract class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object> get props => [];
}

class PlayerInitial extends PlayerState {
  final Song song;

  const PlayerInitial(this.song);

  @override
  List<Object> get props => [song];
}

class PlayerSuccess extends PlayerState {
  final Song song;
  final Album album;
  final File image;
  final bool isFinished;

  const PlayerSuccess(
      {this.song, this.image, this.album, this.isFinished = false});

  PlayerSuccess copyWith({Album album, File image, bool isFinished}) =>
      PlayerSuccess(
        song: this.song,
        album: album ?? this.album,
        image: image ?? this.image,
        isFinished: isFinished ?? false,
      );

  @override
  List<Object> get props => [song, album, image, isFinished];
}

class PlayerFailure extends PlayerState {}
