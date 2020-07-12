import 'package:equatable/equatable.dart';

abstract class MiniPlayerState extends Equatable {
  const MiniPlayerState();

  @override
  List<Object> get props => [];
}

class MiniPlayerInitial extends MiniPlayerState {}

class MiniPlayerSuccess extends MiniPlayerState {
	final bool isPlaying;

	const MiniPlayerSuccess(this.isPlaying);

	@override
	List<Object> get props => [isPlaying];
}