import 'package:airstream/models/album_model.dart';
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
  final List<Album> albumList;

  const RandomSuccess({this.albumList});

  RandomSuccess copyWith({List<Album> albumList}) => RandomSuccess(
        albumList: albumList ?? this.albumList,
      );

  @override
  List<Object> get props => [albumList];
}
