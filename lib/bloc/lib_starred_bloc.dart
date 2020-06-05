import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/data_providers/song_provider.dart';
import 'package:airstream/events/lib_starred_event.dart';
import 'package:airstream/states/lib_starred_state.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LibraryStarredBloc extends Bloc<LibraryStarredEvent, LibraryStarredState> {
  final Repository _repository = Repository();

  @override
  LibraryStarredState get initialState => Uninitialised();

  @override
  Stream<LibraryStarredState> mapEventToState(LibraryStarredEvent event) async* {
    if (event is FetchStarred) {
      try {
        final response = await _repository.fetchCategory(
          request: 'getStarred2?',
          database: SongProvider(),
        );
        switch (response.status) {
          case DataStatus.ok:
            yield Loaded(songs: response.data);
            break;
          case DataStatus.error:
            yield Error();
            break;
        }
      } catch (error, stacktrace) {
        print('lib_starred_bloc $error\n$stacktrace');
      }
    }
  }
}
