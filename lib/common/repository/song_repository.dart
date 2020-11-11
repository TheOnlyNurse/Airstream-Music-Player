import 'dart:io';
import 'dart:math' as math;

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
import '../providers/server_provider.dart';
import '../providers/songs_dao.dart';
import 'repository.dart';

class SongRepository {
  SongRepository({
    @required SongsDao songsDao,
    @required AudioFilesDao audioFilesDao,
    @required String cacheFolder,
  })  : assert(songsDao != null),
        assert(audioFilesDao != null),
        _database = songsDao,
        _fileDatabase = audioFilesDao,
        _cacheFolder = cacheFolder;

  final SongsDao _database;
  final AudioFilesDao _fileDatabase;
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

  /// Downloads, inserts (into the local database) and returns songs from a given url query.
  ///
  /// If the element within the XmlDocument to be parsed as a song object is not
  /// 'song' then use [elementName] to assign the correct one.
  Future<List<Song>> _download(String urlQuery,
      {String elementName = 'song'}) async {
    final response = await ServerProvider().fetchXml(urlQuery);
    if (response.hasData) {
      final elements = response.data.findAllElements(elementName).toList();
      await _database.insertElements(elements);
      return _database.idList(elements.map((e) {
        return int.parse(e.getAttribute('id'));
      }).toList());
    } else {
      return [];
    }
  }
}

extension SimpleQueries on SongRepository {
  /// Returns a song by id.
  Future<SingleResponse<Song>> byId(int id) async {
    final song = await _database.id(id);
    return song != null ? SingleResponse<Song>(data: song) : null;
  }

  /// Get songs that match a given album.
  ///
  /// Fetches from the server if the number of songs retrieved doesn't match
  /// the songs expected in the album.
  Future<ListResponse<Song>> byAlbum(Album album) async {
    final songs = await _database.album(album.id);

    if (songs.length != album.songCount) {
      final downloaded = await _download('getAlbum?id=${album.id}');
      downloaded?.sort((a, b) => a.title.compareTo(b.title));
      return _removeEmptyLists(downloaded);
    } else {
      return ListResponse(data: songs);
    }
  }

  /// Convert playlist song id list to song details from database.
  Future<ListResponse<Song>> byPlaylist(Playlist playlist) async {
    final songs = await _database.idList(playlist.songIds);
    if (songs.length != playlist.songIds.length) {
      final downloaded = await _download(
        'getPlaylist?id=${playlist.id}',
        elementName: 'entry',
      );
      return _removeEmptyLists(downloaded);
    } else {
      return ListResponse<Song>(data: songs);
    }
  }

  /// Returns songs marked as starred, fetching from server if an empty list is received.
  Future<ListResponse<Song>> starred({bool forceSync = false}) async {
    final songs = await _database.starred();
    if (songs.isEmpty || forceSync) {
      final downloaded = await _download('getStarred2?');
      if (downloaded.isNotEmpty) {
        await _database.clearStarred();
        await _database.updateStarred(downloaded.map((e) => e.id).toList());
        return ListResponse<Song>(data: downloaded);
      } else {
        return _removeEmptyLists(songs);
      }
    } else {
      return ListResponse(data: songs);
    }
  }
}

extension ComplexQueries on SongRepository {
  /// Returns "top" songs of a given artist.
  Future<ListResponse<Song>> topSongs(
    Artist artist, {
    @required Album fallback,
  }) async {
    assert(fallback != null);

    final songs = await _database.topSongs(artist.name);
    if (songs.isEmpty) {
      final compactName = artist.name.replaceAll(' ', '+');
      final downloaded = await _download(
        'getTopSongs?artist=$compactName&count=5',
      );
      final albumSongs = await byAlbum(fallback);

      List<Song> merged;
      if (albumSongs.hasData) {
        merged = <Song>{...downloaded, ...albumSongs.data}.toList();
        merged = merged.sublist(0, math.min(merged.length, 5));
      } else {
        merged = downloaded;
      }

      assert(merged != null);
      if (merged.isNotEmpty) {
        await _database.markTopSongs(
          artist.name,
          merged.map((e) => e.id).toList(),
        );
      }

      return _removeEmptyLists(merged);
    } else {
      return ListResponse<Song>(data: songs);
    }
  }

  /// Searches both titles and artist names assigned to songs by a query string.
  Future<ListResponse<Song>> search(String query) async {
    final byTitle = await _database.title(query);
    final byName = await _database.artistName(query);
    // Converting to set to remove duplicates
    final songs = <Song>{...byTitle, ...byName}.toList();

    if (songs.length < 5) {
      final downloaded = await _download(
        'search3?query=$query&'
        'artistCount=0&'
        'albumCount=0&'
        'songCount=10',
      );
      return _removeEmptyLists(downloaded);
    } else {
      return ListResponse<Song>(data: songs);
    }
  }
}

extension AudioFileManagement on SongRepository {
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
    final filePath = path.join(
      _cacheFolder,
      '${song.id}.${song.title.hashCode}',
    );
    // After inserting the file record, ensure that the cache is still size compliant.
    _cacheSizeCheck();
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
      final maxSize = Repository().settings.maxAudioCacheSize;
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
}
