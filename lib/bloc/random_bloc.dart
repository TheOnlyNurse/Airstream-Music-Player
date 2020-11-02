import 'dart:async';

/// External Packages
import 'package:airstream/providers/moor_database.dart';
import 'package:bloc/bloc.dart';

/// Internal links
import '../events/random_event.dart';
import '../repository/album_repository.dart';
import '../states/random_state.dart';
import 'dart:math' as math;

// Ease of use barrelling
export 'package:airstream/events/random_event.dart';
export 'package:airstream/states/random_state.dart';

class RandomBloc extends Bloc<RandomEvent, RandomState> {
  final AlbumRepository albumRepository;

  RandomBloc(this.albumRepository) : super(RandomInitial());

  List<Album> list;
  int nextEnd = 0;

  @override
  Stream<RandomState> mapEventToState(RandomEvent event) async* {
    if (event is RandomFetch) {
      final response = await albumRepository.random();
      if (response.hasData) {
        this.add(RandomNext());
      }
    }
    if (event is RandomNext) {
      nextEnd = math.min(list.length, nextEnd + 20);
			yield RandomSuccess(albums: list.sublist(0, nextEnd));
    }
  }
}
