import 'package:airstream/barrel/provider_basics.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as p;

class ImageFileProvider {
  const ImageFileProvider({@required Box<int> hive, @required String cacheFolder})
      : assert(hive != null),
        assert(cacheFolder != null),
        _hive = hive,
        _cacheFolder = cacheFolder;

  /// Hive box that is used as a db
  final Box<int> _hive;

  final String _cacheFolder;

  /// ========== QUERIES ==========

  /// Returns a file given an id and type.
  ///
  /// The file does not have to exist and therefore checks should be done prior.
  File getFile(String id, ImageType type) {
    return File(p.join(_cacheFolder, '$id.${type.index}'));
  }

  /// Given an id and type, returns the state of the file in question.
  ImageFileState getState(String id, ImageType type) {
    final cipher = _hive.get(id) ?? 0;
    final exists = _checkCipherForFile(cipher, type);
    if (exists) {
      return ImageFileState.exists;
    } else {
      final hasNull = _checkCipherForNull(cipher, type);
      return hasNull ? ImageFileState.nullFile : ImageFileState.none;
    }
  }

  /// ========== DB MANAGEMENT ==========

  /// Deletes cache folder and database entries
  Future<void> clear() async {
    // Nothing to delete if the folder doesn't exist.
    if (!(await Directory(_cacheFolder).exists())) return;
    Directory(_cacheFolder).deleteSync(recursive: true);
    return _hive.clear();
  }

  /// Converts bytes to a file and stores its existence in the database.
  Future<File> addBytes(Uint8List bytes, String id, ImageType type) async {
    final file = await getFile(id, type).create(recursive: true);
    final oldCipher = _hive.get(id) ?? 0;
    final newCipher = _addFileToCipher(oldCipher, type);
    _hive.put(id, newCipher);
    return file.writeAsBytes(bytes);
  }

  /// Indicates that an id and a type contain a null file.
  void setNull(String id, ImageType type) {
    final oldCipher = _hive.get(id) ?? 0;
    final newCipher = _addNullToCipher(oldCipher, type);
    _hive.put(id, newCipher);
    return;
  }

  /// Checks to make sure cache still adheres to the user set max size
  Future<void> checkSize() async {
    final maxSize = 1000;
    int cacheSize = _hive.length;
    while (cacheSize > maxSize) {
      await _deleteOldestFiles();
      cacheSize--;
    }
    return;
  }

  /// Deletes the first row and thus the oldest cached file
  /// • Index 1 is the first image path because index 0 holds cache size
  Future<void> _deleteOldestFiles() async {
    final id = _hive.keyAt(0);
    final crypticValue = _hive.getAt(0);
    for (var type in ImageType.values) {
      if (_checkCipherForFile(crypticValue, type)) {
        await getFile(id, type).delete();
      }
    }

    return _hive.deleteAt(0);
  }

  /// ========== HIVE BOX VALUE INTERPRETERS ==========
  ///
  /// ID => HiveBox => Bitwise encoded integer
  /// Each bit within the "encoded" integer is a makeshift boolean and
  /// corresponds with an image type

  /// Decodes an integer by shifting the bits to isolate the relevant bit
  ///
  /// For example, if we have the bits 111 and we want to isolate the middle bit:
  /// 111 => 110 => 001
  bool _checkCipherForFile(int cipher, ImageType type) {
    final relevantBit = 1 << type.index;
    final isolatedBit = cipher & relevantBit;
    return isolatedBit >> type.index == 1;
  }

  /// Sometimes a null file is required to indicate that the server shouldn't
  /// be asked to fetch new information
  ///
  /// We do this by shifting to range not used to hold "file existing" information
  bool _checkCipherForNull(int cipher, ImageType type) {
    final relevantBit = 1 << (type.index + ImageType.values.length);
    final isolatedBit = cipher & relevantBit;
    return isolatedBit >> (type.index + ImageType.values.length) == 1;
  }

  /// Adds a 1 to the relevant bit of a given value to indicate a file exists
  int _addFileToCipher(int cipher, ImageType type) {
    final relevantBit = 1 << type.index;
    return cipher | relevantBit;
  }

  /// Adds a 1 to the bit indicating that a "null" value exists for this query
  int _addNullToCipher(int cipher, ImageType type) {
    final relevantBit = 1 << type.index + ImageType.values.length;
    return cipher | relevantBit;
  }
}

enum ImageFileState { exists, nullFile, none }

enum ImageType { lowRes, highRes, artist }
