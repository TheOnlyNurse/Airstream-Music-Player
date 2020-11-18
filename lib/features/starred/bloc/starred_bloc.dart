import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../common/global_assets.dart';
import '../../../common/providers/moor_database.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/repository/settings_repository.dart';
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
    final onConnectivity = _settings.connectivityChanged;
    onNetworkChange = onConnectivity.listen((_) => add(StarredFetch()));
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

  @override
  Future<void> close() {
    onNetworkChange.cancel();
    return super.close();
  }
}
