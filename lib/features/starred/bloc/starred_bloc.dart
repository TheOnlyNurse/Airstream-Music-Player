import 'dart:async';

import 'package:airstream/common/global_assets.dart';
import 'package:airstream/common/repository/settings_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../common/providers/moor_database.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/repository/song_repository.dart';

part 'starred_event.dart';

part 'starred_state.dart';

class StarredBloc extends Bloc<StarredEvent, StarredState> {
  StarredBloc({
    AlbumRepository album,
    SongRepository song,
    SettingsRepository settings,
  })  : _album = getIt<AlbumRepository>(album),
        _song = getIt<SongRepository>(song),
        _settings = getIt<SettingsRepository>(settings),
        super(StarredInitial()) {
    onNetworkChange = _settings.connectivityChanged.listen((isOnline) {
      if (isOnline) add(StarredFetch());
    });
  }

  final AlbumRepository _album;
  final SongRepository _song;
  final SettingsRepository _settings;
  StreamSubscription onNetworkChange;

  @override
  Stream<StarredState> mapEventToState(StarredEvent event) async* {
    if (event is StarredFetch) {
      final albumResponse = await _album.starred();
      final songResponse = await _song.starred();
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
