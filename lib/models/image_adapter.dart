import 'dart:io';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/repository/image_repository.dart';

class ImageAdapter {
  final Album _album;
  final Artist _artist;
  final bool _isHiDef;

  const ImageAdapter({
    Album album,
    Artist artist,
    bool isHiDef = false,
  })  : assert(
          !(album != null && artist != null),
          'Must pass either [album] or [artist] but not both.',
        ),
        _album = album,
        _artist = artist,
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
        return Future.delayed(Duration(milliseconds: 100), null);
      }
      return _isHiDef ? repository.highDefinition(id) : repository.preview(id);
    }

    if (_artist != null) {
      return repository.fromArtist(_artist, fetch: _isHiDef);
    }

    throw UnimplementedError();
  }
}
