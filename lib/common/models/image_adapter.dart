import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../providers/moor_database.dart';
import '../repository/image_repository.dart';

abstract class ImageAdapter {
  final bool _isHiDef;

  const ImageAdapter({bool isHiDef = false}) : _isHiDef = isHiDef;

  /// Tells Airstream Image whether to animate from loading widget.
  bool get shouldAnimate => _isHiDef;

  /// Returns a file for the given adapter inputs.
  Future<Option<File>> resolve(ImageRepository repository);
}

class AlbumImageAdapter extends ImageAdapter {
  final Album _album;

  AlbumImageAdapter({@required Album album, bool isHiDef = false})
      : assert(album != null),
        _album = album,
        super(isHiDef: isHiDef);

  @override
  Future<Option<File>> resolve(ImageRepository repository) {
    final id = _album.art;
    if (id == null) {
      // A future must be returned for a future builder, else connection state
      // is rendered as "none".
      return Future.value(none());
    }
    return _isHiDef ? repository.highDefinition(id) : repository.preview(id);
  }
}

class ArtistImageAdapter extends ImageAdapter {
  final Artist _artist;

  ArtistImageAdapter({@required Artist artist, bool isHiDef = false})
      : assert(artist != null),
        _artist = artist,
        super(isHiDef: isHiDef);

  @override
  Future<Option<File>> resolve(ImageRepository repository) {
    return repository.fromArtist(_artist, fetch: _isHiDef);
  }
}

class SongImageAdapter extends ImageAdapter {
  final Song _song;

  SongImageAdapter({@required Song song, bool isHiDef = false})
      : assert(song != null),
        _song = song,
        super(isHiDef: isHiDef);


  @override
  Future<Option<File>> resolve(ImageRepository repository) {
    final id = _song.art;
    return _isHiDef ? repository.highDefinition(id) : repository.preview(id);
  }
}
