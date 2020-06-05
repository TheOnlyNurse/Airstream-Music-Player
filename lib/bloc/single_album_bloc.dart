import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/events/single_album_event.dart';
import 'package:airstream/states/single_album_state.dart';
import 'package:bloc/bloc.dart';

class SingleAlbumBloc extends Bloc<SingleAlbumEvent, SingleAlbumState> {
  final Repository _repository = Repository();

  @override
  SingleAlbumState get initialState => AlbumScreenUninitialised();

  @override
  Stream<SingleAlbumState> mapEventToState(SingleAlbumEvent event) async* {
    if (event is FetchAlbumInfo) {
      final response = await _repository.getAlbumSongs(event.album);
      switch (response.status) {
        case DataStatus.ok:
          yield AlbumInfoLoaded(songList: response.data);
          break;
        case DataStatus.error:
          yield AlbumScreenError();
          break;
      }
    }
  }
}
