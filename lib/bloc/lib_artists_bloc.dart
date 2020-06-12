import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/events/lib_artists_event.dart';
import 'package:airstream/states/lib_artists_state.dart';

// Core
import 'package:bloc/bloc.dart';

class LibraryArtistsBloc extends Bloc<LibraryAlbumsEvent, LibraryAlbumsState> {
  final Repository _repository = Repository();

  @override
  LibraryAlbumsState get initialState => Uninitialised();

  @override
  Stream<LibraryAlbumsState> mapEventToState(LibraryAlbumsEvent event) async* {
    if (event is Fetch) {
      try {
        final response = await _repository.getLibrary(Library.artists);
        switch (response.status) {
          case DataStatus.ok:
            yield Loaded(artists: response.data);
            break;
          case DataStatus.error:
            yield Error();
            break;
        }
      } catch (error, stacktrace) {
        print('lib_artists_bloc $error\n$stacktrace');
      }
    }
  }
}
