import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/events/starred_event.dart';
import 'package:airstream/states/starred_state.dart';

// Barrel for ease of importing
export 'package:airstream/events/starred_event.dart';
export 'package:airstream/states/starred_state.dart';

class StarredBloc extends Bloc<StarredEvent, StarredState> {
  final _repository = Repository();
  StreamSubscription onNetworkChange;

  StarredBloc() {
    onNetworkChange = _repository.settings.onChange.listen((type) {
      if (type == SettingType.isOffline) this.add(StarredFetch());
    });
  }

  @override
  StarredState get initialState => StarredInitial();

  @override
  Stream<StarredState> mapEventToState(StarredEvent event) async* {
    final currentState = state;

    if (event is StarredFetch) {
      final albumResponse = await _repository.album.starred();
      final songResponse = await _repository.song.starred();
      if (albumResponse.hasNoData && songResponse.hasNoData) {
        yield StarredFailure(songResponse.error);
      } else {
        yield StarredSuccess(
          albums: albumResponse.albums ?? [],
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
