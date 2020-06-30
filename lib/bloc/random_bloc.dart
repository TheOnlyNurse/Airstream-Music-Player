import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/events/random_event.dart';
import 'package:airstream/states/random_state.dart';
import 'dart:math' as math;

// Ease of use barrelling
export 'package:airstream/events/random_event.dart';
export 'package:airstream/states/random_state.dart';

class RandomBloc extends Bloc<RandomEvent, RandomState> {
  List<Album> list;
  int nextEnd = 0;

  @override
  RandomState get initialState => RandomInitial();

  @override
  Stream<RandomState> mapEventToState(RandomEvent event) async* {
    if (event is RandomFetch) {
      final response = await Repository().album.random();
      if (response.hasData) {
        list = response.albums;
        this.add(RandomNext());
      } else {
        yield RandomFailure(message: response.message);
      }
    }
    if (event is RandomNext) {
      nextEnd = math.min(list.length, nextEnd + 20);
			yield RandomSuccess(albums: list.sublist(0, nextEnd));
    }
  }
}
