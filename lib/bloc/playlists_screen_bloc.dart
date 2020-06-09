import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:bloc/bloc.dart';

enum PlaylistsScreenEvent { fetch }

abstract class PlaylistsScreenState {}

class PlaylistsLoaded extends PlaylistsScreenState {
  final List<Playlist> playlistArray;

  PlaylistsLoaded(this.playlistArray);
}

class PlaylistsUninitialised extends PlaylistsScreenState {}

class PlaylistsScreenError extends PlaylistsScreenState {
  final String message;

  PlaylistsScreenError(this.message);
}

class PlaylistsScreenBloc extends Bloc<PlaylistsScreenEvent, PlaylistsScreenState> {
  final _repository = Repository();

  @override
  PlaylistsScreenState get initialState => PlaylistsUninitialised();

  @override
  Stream<PlaylistsScreenState> mapEventToState(PlaylistsScreenEvent event) async* {
    switch (event) {
      case PlaylistsScreenEvent.fetch:
        final response = await _repository.getPlaylists();
        if (response.status == DataStatus.ok) yield PlaylistsLoaded(response.data);
        if (response.status == DataStatus.error)
          yield PlaylistsScreenError('couldn\'t fetch data');
    }
  }
}
