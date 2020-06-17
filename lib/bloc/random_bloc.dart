import 'dart:collection';

import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/events/random_event.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:airstream/states/random_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RandomBloc extends Bloc<RandomEvent, RandomState> {
  @override
  RandomState get initialState => RandomInitial();

  @override
  Stream<RandomState> mapEventToState(RandomEvent event) async* {
    final currentState = state;
    if (event is RandomFetch) {
      if (currentState is RandomInitial) {
        final response = await Repository().album.random(20);
        if (response.status == DataStatus.ok)
          yield RandomSuccess(albumList: response.data);
        else
          yield RandomFailure(message: response.message);
      }
      if (currentState is RandomSuccess) {
        final response = await Repository().album.random(100);
        if (response.status == DataStatus.ok) {
          final combinedData =
              LinkedHashSet<Album>.from(currentState.albumList + response.data).toList();
          yield currentState.copyWith(albumList: combinedData);
        }
      }
    }
  }
}
