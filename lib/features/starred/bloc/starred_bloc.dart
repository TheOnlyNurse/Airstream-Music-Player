import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../common/providers/moor_database.dart';
import '../../../common/providers/repository/repository.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/repository/communication.dart';
import '../../../common/repository/song_repository.dart';

part 'starred_event.dart';
part 'starred_state.dart';

class StarredBloc extends Bloc<StarredEvent, StarredState> {
  StarredBloc({
    @required this.albumRepository,
    @required this.songRepository,
  })  : assert(albumRepository != null),
        assert(songRepository != null),
        super(StarredInitial()) {
    onNetworkChange = Repository().settings.onChange.listen((type) {
      if (type == SettingType.isOffline) add(StarredFetch());
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
