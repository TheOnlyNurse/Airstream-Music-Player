import 'package:equatable/equatable.dart';

import '../../../common/providers/moor_database.dart';

abstract class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object> get props => [];
}

class PlayerInitial extends PlayerState {}

class PlayerSuccess extends PlayerState {
  final Song song;
  final bool isFinished;

  const PlayerSuccess({this.song, this.isFinished = false});

  PlayerSuccess copyWith({Song song, bool isFinished}) => PlayerSuccess(
        song: this.song,
        isFinished: isFinished ?? false,
      );

  @override
  List<Object> get props => [song, isFinished];
}

class PlayerFailure extends PlayerState {}
