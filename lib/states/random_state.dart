import 'package:airstream/providers/moor_database.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class RandomState extends Equatable {
  const RandomState();

  @override
  List<Object> get props => [];
}

class RandomInitial extends RandomState {}

class RandomFailure extends RandomState {
  final Widget message;

  const RandomFailure({this.message});
}

class RandomSuccess extends RandomState {
	final List<Album> albums;

  const RandomSuccess({this.albums});

  RandomSuccess copyWith({List<Album> albumList}) => RandomSuccess(
        albums: albumList ?? this.albums,
      );

  @override
  List<Object> get props => [albums];
}
