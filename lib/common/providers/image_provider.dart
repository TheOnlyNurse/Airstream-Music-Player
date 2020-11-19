import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as p;
import 'package:hive/hive.dart';

enum ImageType { lowRes, highRes, artist }

class ImageFileProvider {
  const ImageFileProvider({
    @required Box<int> hive,
    @required String cacheFolder,
  })  : assert(hive != null),
        assert(cacheFolder != null),
        _hive = hive,
        _cacheFolder = cacheFolder;

  /// Hive box that is used as a db
  final Box<int> _hive;

  /// Folder used to store images.
  final String _cacheFolder;

  /// ========== QUERIES ==========

  /// Returns a file given an id and type.
  ///
  /// The file does not have to exist and therefore checks should be done prior.
  File resolveFile(String id, ImageType type) {
    return File(p.join(_cacheFolder, '$id.${type.index}'));
  }

  /// Given an id and type, returns the state of the file in question.
  Option<bool> state(String id, ImageType type) {
    return (_hive.get(id) ?? 0).fileCheck(type);
  }

  /// ========== DB MANAGEMENT ==========

  /// Deletes cache folder and database entries
  Future<void> clear() async {
    // Nothing to delete if the folder doesn't exist.
    if (!(await Directory(_cacheFolder).exists())) return;
    await Directory(_cacheFolder).delete(recursive: true);
    return _hive.clear();
  }

  /// Converts bytes to a file and stores its existence in the database.
  Future<File> addBytes(Uint8List bytes, String id, ImageType type) async {
    final file = await resolveFile(id, type).create(recursive: true);
    final newCipher = (_hive.get(id) ?? 0).addFile(type);
    await _hive.put(id, newCipher);
    return file.writeAsBytes(bytes);
  }

  /// Indicates that an id and a type contain a null file.
  Future<void> addNull(String id, ImageType type) {
    final newCipher = (_hive.get(id) ?? 0).addNull(type);
    return _hive.put(id, newCipher);
  }

  /// Checks to make sure cache still adheres to [maxSize].
  Future<void> checkSize() async {
    const maxSize = 1000;
    int cacheSize = _hive.length;
    while (cacheSize > maxSize) {
      await _deleteOldestFiles();
      cacheSize--;
    }
  }

  /// Deletes the first index (the oldest cached file).
  Future<void> _deleteOldestFiles() async {
    final id = _hive.keyAt(0) as String;
    final cipher = _hive.get(id);
    // Since one cipher can hold multiple images, we need to iterate over
    // each image type and delete it if it exists.
    final futures = ImageType.values.map((type) => cipher.fileCheck(type).fold(
          () => null,
          (exists) => exists ? resolveFile(id, type).delete() : null,
        ));
    return Future.wait([_hive.delete(id), ...futures]);
  }
}

/// Transform integers into functional objects.
extension _FunctionalInt on int {
  Option<bool> fileCheck(ImageType type) {
    return _BitWise.check(this, type)
        // File exists.
        ? some(true)
        // Check whether a null (no value) is expected.
        : _BitWise.nullCheck(this, type)
            ? none()
            : some(false);
  }

  int addFile(ImageType type) => _BitWise.add(this, type);

  int addNull(ImageType type) => _BitWise.addNull(this, type);
}

/// Methods to interpret values stored in the image database (Hive).
///
/// ID => HiveBox => Bitwise encoded integer
/// Each bit within the "encoded" integer is a makeshift boolean and
/// corresponds with an image type
class _BitWise {
  /// This class shouldn't be instantiated.
  _BitWise._();

  /// Checks for a file given the stored [cipher] and a image [type].
  ///
  /// Decodes an integer by shifting the bits to isolate the relevant bit.
  /// For example, if we have the bits 111 and we want to isolate the middle bit:
  /// 111 => 110 => 001
  static bool check(int cipher, ImageType type) {
    final relevantBit = 1 << type.index;
    return cipher & relevantBit != 0;
  }

  /// Adds a 1 to the relevant bit of a given value to indicate a file exists
  static int add(int cipher, ImageType type) {
    final relevantBit = 1 << type.index;
    return cipher | relevantBit;
  }

  /// Sometimes a null file is required to indicate that the server shouldn't
  /// be asked to fetch new information
  ///
  /// We do this by shifting to range not used to hold "file existing" information
  static bool nullCheck(int cipher, ImageType type) {
    final relevantBit = 1 << (type.index + ImageType.values.length);
    return cipher & relevantBit != 0;
  }

  /// Adds a 1 to the bit indicating that a "null" value exists for this query
  static int addNull(int cipher, ImageType type) {
    final relevantBit = 1 << type.index + ImageType.values.length;
    return cipher | relevantBit;
  }
}
