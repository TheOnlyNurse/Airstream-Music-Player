import 'package:equatable/equatable.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object> get props => [];
}

class PlayerFetch extends PlayerEvent {}

class PlayerFetchArt extends PlayerEvent {
  final String artId;

  const PlayerFetchArt(this.artId);

  @override
  List<Object> get props => [artId];
}

class PlayerStopped extends PlayerEvent {}
