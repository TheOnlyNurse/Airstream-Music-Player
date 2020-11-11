import 'dart:io';

import '../providers/moor_database.dart';
import '../repository/image_repository.dart';

class ImageAdapter {
  final Album _album;
  final Artist _artist;
  final Song _song;
  final bool _isHiDef;

  const ImageAdapter({
    Album album,
    Artist artist,
    Song song,
    bool isHiDef = false,
  })  : _album = album,
        _artist = artist,
        _song = song,
        _isHiDef = isHiDef;

  /// Tells Airstream Image whether to animate from loading widget.
  bool get shouldAnimate => _isHiDef;

  /// Returns a file for the given adapter inputs.
  Future<File> resolve(ImageRepository repository) {
    if (_album != null) {
      final id = _album.art;
      if (id == null) {
        // A future must be returned for a future builder, else connection state
        // is rendered as "none".
        return Future.delayed(const Duration(milliseconds: 100));
      }
      return _isHiDef ? repository.highDefinition(id) : repository.preview(id);
    }

    if (_artist != null) {
      return repository.fromArtist(_artist, fetch: _isHiDef);
    }

    if (_song != null) {
      final id = _song.art;
      return _isHiDef ? repository.highDefinition(id) : repository.preview(id);
    }

    throw UnimplementedError();
  }
}
