import 'package:airstream/bloc/song_list_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SongListEvent {}

class SongListFetch extends SongListEvent {
  final dynamic typeValue;
  final SongListType type;

  SongListFetch(this.type, this.typeValue);
}

class SongListSelection extends SongListEvent {
  final int index;

  SongListSelection(this.index);
}

class SongListClearSelection extends SongListEvent {}

class SongListStarSelection extends SongListEvent {}

class SongListPlaylistSelection extends SongListEvent {}

class SongListRemoveSelection extends SongListEvent {}