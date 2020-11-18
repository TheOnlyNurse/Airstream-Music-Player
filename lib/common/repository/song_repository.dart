import 'dart:io';
import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'package:mutex/mutex.dart';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';
import '../extensions/functional_lists.dart';

import '../global_assets.dart';
import '../models/playlist_model.dart';
import '../providers/audio_files_dao.dart';
import '../providers/moor_database.dart';
import '../providers/songs_dao.dart';
import 'server_repository.dart';
import 'settings_repository.dart';

class SongRepository {
  SongRepository({
    SongsDao songsDao,
    AudioFilesDao audioFilesDao,
    String cacheFolder,
    SettingsRepository settings,
    ServerRepository server,
  })  : _database = songsDao ?? SongsDao(GetIt.I.get<MoorDatabase>()),
        _fileDatabase =
            audioFilesDao ?? AudioFilesDao(GetIt.I.get<MoorDatabase>()),
        _server = getIt<ServerRepository>(server),
        _settings = getIt<SettingsRepository>(settings),
        _cacheFolder = cacheFolder ?? _folderConstructor();

  final SongsDao _database;
  final ServerRepository _server;
  final AudioFilesDao _fileDatabase;
  final SettingsRepository _settings;
  final String _cacheFolder;
  final _cacheCheckLocker = Mutex();

  /// Returns a song by id.
  Future<Either<String, Song>> byId(int id) async {
    final song = await _database.id(id);
    return song == null ? left(_Error.noSong) : right(song);
  }

  /// Get songs that match a given [album].
  ///
  /// Fetches from the server if the number of songs retrieved doesn't match
  /// the songs expected in the album.
  Future<Either<String, List<Song>>> byAlbum(Album album) async {
    final songs = await _database.album(album.id);
    if (songs.length == album.songCount) return right(songs);

    return (await _server.albumSongs(album.id)).fold(
      (error) => left(error),
      (elements) async {
        final songs = await _process(elements);
        songs.sort((a, b) => a.title.compareTo(b.title));
        return songs.removeEmpty(_Error.songsEmpty);
      },
    );
  }

  /// Convert playlist song id list to song details from database.
  Future<Either<String, List<Song>>> byPlaylist(Playlist playlist) async {
    final songs = await _database.idList(playlist.songIds);
    if (songs.length == playlist.songIds.length) return right(songs);

    return (await _server.playlistSongs(playlist.id)).fold(
      (error) => left(error),
      (elements) async =>
          (await _process(elements)).removeEmpty(_Error.songsEmpty),
    );
  }

  /// Returns songs marked as starred, fetching from server if an empty list is received.
  Future<Either<String, List<Song>>> starred({bool forceSync = false}) async {
    final songs = await _database.starred();
    if (songs.isNotEmpty || forceSync) return right(songs);

    return (await _server.starred('song')).fold(
      (error) => left(error),
      (elements) async {
        await _database.clearStarred();
        final processed = await _process(elements);
        await _database.updateStarred(processed.map((e) => e.id).toList());
        return right(processed);
      },
    );
  }

  /// Returns "top" songs of a given [artist].
  ///
  /// If the fetched list is empty, falls back to 5 songs within the [fallback] album.
  Future<Either<String, List<Song>>> topSongs(
    Artist artist, {
    @required Album fallback,
  }) async {
    assert(fallback != null);

    final markedSongs = await _database.topSongs(artist.name);
    if (markedSongs.isNotEmpty) return right(markedSongs);

    return (await _server.topSongs(artist.name)).fold(
      // Fallback on an empty list.
      (_) async => (await byAlbum(fallback))
          .map((songs) => songs.sublist(0, math.min(songs.length, 5)))
          .fold(
            (error) => left(error),
            (songs) async => right(await _markTopSongs(artist, songs)),
          ),
      // Register fetched songs.
      (elements) async =>
          (await _process(elements)).removeEmpty(_Error.songsEmpty).fold(
                (error) => left(error),
                (songs) async => right(await _markTopSongs(artist, songs)),
              ),
    );
  }

  /// Marks a list of [songs] as an [artist]'s "top songs".
  Future<List<Song>> _markTopSongs(Artist artist, List<Song> songs) async {
    // Checks for empty song lists should be done before this call.
    assert(songs.isNotEmpty);
    final ids = songs.map((e) => e.id).toList();
    await _database.markTopSongs(artist.name, ids);
    return songs;
  }

  /// Searches both titles and artist names assigned to songs by a query string.
  Future<Either<String, List<Song>>> search(String query) async {
    final byTitle = await _database.title(query);
    final byName = await _database.artistName(query);

    final songs = <Song>[...byTitle, ...byName].removeDuplicates;
    if (songs.length > 4) return right(songs);

    return (await _server.search(query)).fold(
      (error) => left(error),
      (elements) async =>
          (await _process(elements)).removeEmpty(_Error.songsEmpty),
    );
  }

  /// Returns the file (is it exists) associated with a song id.
  Future<Either<String, File>> file(Song song) async {
    final path = await _fileDatabase.filePath(song.id);
    return path != null ? right(File(path)) : left(_Error.noFile);
  }

  /// Deletes the file associated with a song.
  Future<void> deleteFile(Song song) async {
    final audioFile = await _fileDatabase.query(song.id);
    assert(audioFile != null);

    return Future.wait([
      _fileDatabase.deleteEntry(song.id),
      File(audioFile.path).delete(),
    ]);
  }

  /// Moves a given file into the cache folder and inserts it's existence into the database.
  ///
  /// Returns the file path recorded in the database.
  Future<File> cacheFile({Song song, File file}) async {
    // Create a filename from song information.
    final fileName = '${song.id}.${song.title.hashCode}';
    final filePath = path.join(_cacheFolder, fileName);
    final databaseFile = await File(filePath).create(recursive: true);
    await Future.wait([
      // Insert into the database.
      _fileDatabase.insertCompanion(AudioFilesCompanion.insert(
        songId: Value(song.id),
        path: filePath,
        size: (await file.stat()).size,
        created: DateTime.now(),
      )),
      // Copy from the temporary path to the database one.
      file.copy(filePath),
    ]);
    // After inserting the file record, ensure that the cache is still size compliant.
    _cacheSizeCheck();
    return databaseFile;
  }

  /// Deletes the cache folder and clears the file database.
  Future<void> clearCache() async {
    return Future.wait([
      Directory(_cacheFolder).delete(),
      _fileDatabase.clear(),
    ]);
  }

  Future<void> _cacheSizeCheck() async {
    await _cacheCheckLocker.protect(() async {
      final maxSize = _settings.audioCache;
      var currentSize = await _fileDatabase.cacheSize();

      if (currentSize > maxSize) {
        final futures = <Future>[];
        var offset = 0;

        do {
          final fileEntry = await _fileDatabase.oldestFile(offset);
          currentSize -= fileEntry.size;
          futures.addAll([
            _fileDatabase.deleteEntry(fileEntry.songId),
            File(fileEntry.path).delete(),
          ]);
          offset++;
          // ignore: invariant_booleans
        } while (currentSize > maxSize);

        await Future.wait(futures);
      }
    });
  }

  /// Converts XmlElements into a list of [Song].
  ///
  /// Awaits the [elements], inserts into the database and then searches
  /// the database for those insert objects.
  Future<List<Song>> _process(List<XmlElement> elements) async {
    int extractId(XmlElement e) => int.parse(e.getAttribute('id'));
    await _database.insertElements(elements);
    return _database.idList(elements.map(extractId).toList());
  }
}

String _folderConstructor() {
  return path.join(GetIt.I.get<String>(instanceName: 'cachePath'), 'audio/');
}

class _Error {
  _Error._();

  static const noSong = 'Failed to find song.';

  static const songsEmpty = 'Failed to find songs.';

  static const noFile = 'Failed to find audio file in database.';
}
