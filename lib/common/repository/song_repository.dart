import 'dart:io';
import 'dart:math' as math;

import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'package:mutex/mutex.dart';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';

import '../global_assets.dart';
import '../models/playlist_model.dart';
import '../models/repository_response.dart';
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

  /// Returns an error message with possible solutions instead of an empty list.
  ListResponse<Song> _removeEmptyLists(List<Song> songs) {
    if (songs.isEmpty) {
      return const ListResponse<Song>(
          error: "No songs found in database.",
          solutions: [
            ErrorSolutions.network,
          ]);
    } else {
      return ListResponse<Song>(data: songs);
    }
  }

  /// Returns a song by id.
  Future<SingleResponse<Song>> byId(int id) async {
    final song = await _database.id(id);
    return song != null ? SingleResponse<Song>(data: song) : null;
  }

  /// Get songs that match a given [album].
  ///
  /// Fetches from the server if the number of songs retrieved doesn't match
  /// the songs expected in the album.
  Future<ListResponse<Song>> byAlbum(Album album) async {
    final songs = await _database.album(album.id);
    if (songs.length == album.songCount) return ListResponse<Song>(data: songs);

    return (await _server.albumSongs(album.id)).fold(
      (error) => ListResponse<Song>(error: error),
      (elements) async {
        final songs = await _process(elements);
        songs.sort((a, b) => a.title.compareTo(b.title));
        return _removeEmptyLists(songs);
      },
    );
  }

  /// Convert playlist song id list to song details from database.
  Future<ListResponse<Song>> byPlaylist(Playlist playlist) async {
    final songs = await _database.idList(playlist.songIds);
    if (songs.length == playlist.songIds.length) {
      return ListResponse<Song>(data: songs);
    }

    return (await _server.playlistSongs(playlist.id)).fold(
      (error) => ListResponse<Song>(error: error),
      (elements) async => _removeEmptyLists(await _process(elements)),
    );
  }

  /// Returns songs marked as starred, fetching from server if an empty list is received.
  Future<ListResponse<Song>> starred({bool forceSync = false}) async {
    final songs = await _database.starred();
    if (songs.isNotEmpty || forceSync) return ListResponse<Song>(data: songs);

    return (await _server.starred('song')).fold(
      (error) => _removeEmptyLists(songs),
      (elements) async {
        await _database.clearStarred();
        final processed = await _process(elements);
        await _database.updateStarred(processed.map((e) => e.id).toList());
        return ListResponse<Song>(data: processed);
      },
    );
  }

  /// Returns "top" songs of a given [artist].
  ///
  /// Falls back to the songs within a [fallback] album.
  /// TODO: A lot of repeated code. Needs cleaning up.
  Future<ListResponse<Song>> topSongs(
    Artist artist, {
    @required Album fallback,
  }) async {
    assert(fallback != null);

    final markedSongs = await _database.topSongs(artist.name);
    if (markedSongs.isNotEmpty) return ListResponse<Song>(data: markedSongs);

    final compactName = artist.name.replaceAll(' ', '+');
    return (await _server.topSongs(compactName)).fold(
      (error) async {
        final fromAlbum = await byAlbum(fallback);
        if (fromAlbum.hasError) throw UnimplementedError(fromAlbum.error);
        final songs =
            fromAlbum.data.sublist(0, math.min(fromAlbum.data.length, 5));
        await _database.markTopSongs(
          artist.name,
          songs.map((e) => e.id).toList(),
        );
        return _removeEmptyLists(songs);
      },
      (elements) async {
        final songs = await _process(elements);
        if (songs.isNotEmpty) {
          await _database.markTopSongs(
            artist.name,
            songs.map((e) => e.id).toList(),
          );
        }
        return _removeEmptyLists(songs);
      },
    );
  }

  /// Searches both titles and artist names assigned to songs by a query string.
  Future<ListResponse<Song>> search(String query) async {
    final byTitle = await _database.title(query);
    final byName = await _database.artistName(query);

    // Converting to set to remove duplicates
    final songs = <Song>{...byTitle, ...byName}.toList();
    if (songs.length > 4) return ListResponse<Song>(data: songs);

    return (await _server.search(query)).fold(
      (error) => ListResponse<Song>(error: error),
      (elements) async => _removeEmptyLists(await _process(elements)),
    );
  }

  /// Returns the file (is it exists) associated with a song id.
  Future<File> file(Song song) async {
    final path = await _fileDatabase.filePath(song.id);
    return path != null ? File(path) : null;
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
