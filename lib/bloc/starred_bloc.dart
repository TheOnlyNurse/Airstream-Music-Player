import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:flutter/material.dart';

class StarredBloc extends Bloc<StarredEvent, StarredState> {
  final _repository = Repository();
  StreamSubscription onNetworkChange;
  StreamSubscription onStarredChange;

  StarredBloc() {
    onNetworkChange = _repository.settings.onChange.listen((type) {
      if (type == SettingType.isOffline) this.add(StarredEvent.fetch);
    });

    onStarredChange = _repository.song.changed.listen((event) {
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
        final response = await _repository.song.starred();

        if (response.hasData) {
          yield StarredSuccess(response.songList);
        } else {
					yield StarredFailure(response.message);
        }
        break;
      case StarredEvent.refresh:
				yield StarredInitial();
        final response = await _repository.song.updateStarred();

        if (response.hasData) {
          yield StarredSuccess(response.songList);
        } else {
          yield StarredFailure(response.message);
          // Yield the old starred list after showing error
          await Future.delayed(Duration(seconds: 5), () {
            this.add(StarredEvent.fetch);
          });
        }
        break;
		}
  }

  @override
  Future<void> close() {
		onNetworkChange.cancel();
		onStarredChange.cancel();
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