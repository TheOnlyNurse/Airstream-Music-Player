import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../common/repository/album_repository.dart';
import '../../../common/repository/settings_repository.dart';
import '../../../common/repository/song_repository.dart';
import '../../../global_assets.dart';

import 'starred_event.dart';
import 'starred_state.dart';
export 'starred_event.dart';
export 'starred_state.dart';

class StarredBloc extends Bloc<StarredEvent, StarredState> {
  StarredBloc({
    AlbumRepository album,
    SongRepository song,
    SettingsRepository settings,
  })  : _album = album ?? getIt.get<AlbumRepository>(),
        _song = song ?? getIt.get<SongRepository>(),
        _settings = settings ?? getIt.get<SettingsRepository>(),
        super(StarredInitial()) {
    _init();
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
      if (albumResponse.isLeft() && songResponse.isLeft()) {
        yield StarredFailure(
          'Album Error: '
          '${albumResponse.fold((l) => l, (_) => "Folded right, but shouldn't have.")}\n'
          'Song Error: '
          '${albumResponse.fold((l) => l, (_) => "Folded right, but shouldn't have.")}',
        );
      } else {
        yield StarredSuccess(
          albums: albumResponse.fold((l) => [], (r) => r),
          songs: songResponse.fold((l) => [], (r) => r),
        );
      }
    }
  }

  void _init() {
    onNetworkChange = _settings.connectivityChanged.listen((_) {
      add(StarredFetch());
    });
  }

  @override
  Future<void> close() {
    onNetworkChange.cancel();
    return super.close();
  }
}
