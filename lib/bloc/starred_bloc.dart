import 'dart:async';

import 'package:airstream/repository/song_repository.dart';

/// External Packages
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// Internal links
import '../repository/communication.dart';
import '../providers/repository/repository.dart';
import '../events/starred_event.dart';
import '../repository/album_repository.dart';
import '../states/starred_state.dart';

// Barrel for ease of importing
export '../events/starred_event.dart';
export '../states/starred_state.dart';

class StarredBloc extends Bloc<StarredEvent, StarredState> {
  StarredBloc({
    @required this.albumRepository,
    @required this.songRepository,
  })  : assert(albumRepository != null),
        assert(songRepository != null),
        super(StarredInitial()) {
    onNetworkChange = Repository().settings.onChange.listen((type) {
      if (type == SettingType.isOffline) this.add(StarredFetch());
    });
  }

  final AlbumRepository albumRepository;
  final SongRepository songRepository;
  StreamSubscription onNetworkChange;

  @override
  Stream<StarredState> mapEventToState(StarredEvent event) async* {
    if (event is StarredFetch) {
      final albumResponse = await albumRepository.starred();
      final songResponse = await songRepository.starred();
      if (albumResponse.hasError && songResponse.hasError) {
        yield StarredFailure(songResponse.error);
      } else {
        yield StarredSuccess(
          albums: albumResponse.data ?? [],
          songs: songResponse.data ?? [],
        );
      }
    }
  }

  @override
  Future<void> close() {
    onNetworkChange.cancel();
    return super.close();
  }
}
