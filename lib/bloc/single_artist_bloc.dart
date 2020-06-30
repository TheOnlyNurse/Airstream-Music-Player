import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:flutter/material.dart';

class SingleArtistBloc extends Bloc<SingleArtistEvent, SingleArtistState> {
  @override
  SingleArtistState get initialState => SingleArtistInitial();

  @override
  Stream<SingleArtistState> mapEventToState(SingleArtistEvent event) async* {
    if (event is SingleArtistFetch) {
      final response = await Repository().album.fromArtist(event.artist);
      if (response.hasData) {
        yield SingleArtistSuccess(albums: response.albums);
      } else {
        yield SingleArtistFailure(response.message);
      }
    }
  }
}

abstract class SingleArtistEvent {}

class SingleArtistFetch extends SingleArtistEvent {
  final Artist artist;

  SingleArtistFetch({this.artist});
}

abstract class SingleArtistState {}

class SingleArtistInitial extends SingleArtistState {}

class SingleArtistSuccess extends SingleArtistState {
  final List<Album> albums;

  SingleArtistSuccess({this.albums});
}

class SingleArtistFailure extends SingleArtistState {
	final Widget error;

	SingleArtistFailure(this.error);
}
