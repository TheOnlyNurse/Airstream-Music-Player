import 'dart:async';
import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:airstream/models/song_model.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class StarredBloc extends Bloc<StarredEvent, StarredState> {
  StreamSubscription settingSS;
  StreamSubscription starredChangedSS;

  StarredBloc() {
    settingSS = Repository().settings.changed.listen((hasChanged) {
      if (hasChanged) this.add(StarredEvent.fetch);
    });

    starredChangedSS = Repository().song.changed.listen((event) {
      if (event == SongChange.starred) this.add(StarredEvent.fetch);
    });
  }

  @override
  StarredState get initialState => StarredInitial();

  @override
  Stream<StarredState> mapEventToState(StarredEvent event) async* {
		switch (event) {
			case StarredEvent.fetch:
				yield StarredInitial();
				final response = await Repository().song.starred();

				if (response.status == DataStatus.ok) {
					yield StarredSuccess(response.data);
				} else {
					yield StarredFailure(response.message);
				}
				break;
			case StarredEvent.refresh:
				yield StarredInitial();
				final response = await Repository().song.starred(force: true);

				if (response.status == DataStatus.ok) {
					yield StarredSuccess(response.data);
				} else {
					yield StarredFailure(response.message);
				}
				break;
		}
  }

  @override
  Future<void> close() {
    settingSS.cancel();
    starredChangedSS.cancel();
    return super.close();
  }
}

enum StarredEvent { fetch, refresh }

abstract class StarredState {}

class StarredInitial extends StarredState {}

class StarredFailure extends StarredState {
  final Widget error;

  StarredFailure(this.error);
}

class StarredSuccess extends StarredState {
  final List<Song> songList;

  StarredSuccess(this.songList);
}