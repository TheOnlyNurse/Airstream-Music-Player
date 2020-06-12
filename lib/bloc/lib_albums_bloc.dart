import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/events/lib_albums_event.dart';
import 'package:airstream/states/lib_albums_state.dart';
import 'package:bloc/bloc.dart';

class LibraryAlbumsBloc extends Bloc<LibraryAlbumsEvent, LibraryAlbumsState> {
  final Repository _repository = Repository();

  @override
  LibraryAlbumsState get initialState => AlbumGridUninitialised();

  @override
  Stream<LibraryAlbumsState> mapEventToState(LibraryAlbumsEvent event) async* {
    try {
      if (event is Fetch) {
        final response = await _repository.getLibrary(Library.albums);
        switch (response.status) {
          case DataStatus.ok:
            yield AlbumGridLoaded(albums: response.data);
            break;
          case DataStatus.error:
            yield AlbumGridError();
            break;
        }
      }
    } catch (error, stacktrace) {
      print('lib_albums_state $error\n$stacktrace');
    }
  }
}
