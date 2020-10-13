import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/events/starred_event.dart';
import 'package:airstream/repository/album_repository.dart';
import 'package:airstream/states/starred_state.dart';

// Barrel for ease of importing
export 'package:airstream/events/starred_event.dart';
export 'package:airstream/states/starred_state.dart';

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
      if (albumResponse.hasNoData && songResponse.hasNoData) {
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
