import 'dart:async';

/// External Packages
import 'package:bloc/bloc.dart';

/// Internal links
import '../repository/communication.dart';
import '../data_providers/repository/repository.dart';
import '../events/starred_event.dart';
import '../repository/album_repository.dart';
import '../states/starred_state.dart';

// Barrel for ease of importing
export '../events/starred_event.dart';
export '../states/starred_state.dart';

class StarredBloc extends Bloc<StarredEvent, StarredState> {
  final _repository = Repository();
  StreamSubscription onNetworkChange;

  StarredBloc(this.albumRepository) : super(StarredInitial()) {
    onNetworkChange = _repository.settings.onChange.listen((type) {
      if (type == SettingType.isOffline) this.add(StarredFetch());
    });
  }

  final AlbumRepository albumRepository;

  @override
  Stream<StarredState> mapEventToState(StarredEvent event) async* {

    if (event is StarredFetch) {
      final albumResponse = await albumRepository.starred();
      final songResponse = await _repository.song.starred();
      if (albumResponse.hasError && songResponse.hasNoData) {
        yield StarredFailure(songResponse.error);
      } else {
        yield StarredSuccess(
          albums: albumResponse.data ?? [],
          songs: songResponse.songs ?? [],
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
