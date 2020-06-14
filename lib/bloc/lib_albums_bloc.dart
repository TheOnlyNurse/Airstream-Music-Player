import 'dart:async';
import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class LibraryAlbumsBloc extends Bloc<LibraryAlbumsEvent, LibraryAlbumsState> {
  StreamSubscription settingSS;

  LibraryAlbumsBloc() {
    settingSS = Repository().settings.changed.listen((hasChanged) {
      if (hasChanged) this.add(Fetch());
    });
  }

  @override
  LibraryAlbumsState get initialState => AlbumGridUninitialised();

  @override
  Stream<LibraryAlbumsState> mapEventToState(LibraryAlbumsEvent event) async* {
    try {
      if (event is Fetch) {
				final response = await Repository().album.library();
				switch (response.status) {
					case DataStatus.ok:
            yield AlbumGridLoaded(albums: response.data);
            break;
          case DataStatus.error:
            yield AlbumGridError(response.message);
            break;
        }
      }
    } catch (error, stacktrace) {
      print('lib_albums_state $error\n$stacktrace');
		}
	}

	@override
	Future<void> close() {
		settingSS.cancel();
		return super.close();
	}
}

abstract class LibraryAlbumsEvent {}

class Fetch extends LibraryAlbumsEvent {}

abstract class LibraryAlbumsState {
	const LibraryAlbumsState();
}

class AlbumGridUninitialised extends LibraryAlbumsState {}

class AlbumGridError extends LibraryAlbumsState {
	final Widget error;

	const AlbumGridError(this.error);
}

class AlbumGridLoaded extends LibraryAlbumsState {
	final List<Album> albums;

	const AlbumGridLoaded({this.albums});
}
