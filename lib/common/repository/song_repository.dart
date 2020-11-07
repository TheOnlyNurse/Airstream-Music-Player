import 'dart:math' as math;
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'package:mutex/mutex.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as Path;

/// Internal
import '../models/playlist_model.dart';
import '../models/repository_response.dart';
import '../providers/moor_database.dart';
import '../providers/songs_dao.dart';
import '../providers/audio_files_dao.dart';
import '../providers/repository/repository.dart';
import '../providers/server_provider.dart';
import '../static_assets.dart';

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
    var response = await ServerProvider().fetchXml(urlQuery);
    if (response.hasData) {
      var elements = response.data.findAllElements(elementName).toList();
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
    var song = await _database.id(id);
    return song != null ? SingleResponse<Song>(data: song) : null;
  }

  /// Get songs that match a given album.
  ///
  /// Fetches from the server if the number of songs retrieved doesn't match
  /// the songs expected in the album.
  Future<ListResponse<Song>> byAlbum(Album album) async {
    var songs = await _database.album(album.id);

    if (songs.length != album.songCount) {
      var downloaded = await _download('getAlbum?id=${album.id}');
      downloaded?.sort((a, b) => a.title.compareTo(b.title));
      return _removeEmptyLists(downloaded);
    } else {
      return ListResponse(data: songs);
    }
  }

  /// Convert playlist song id list to song details from database.
  Future<ListResponse<Song>> byPlaylist(Playlist playlist) async {
    var songs = await _database.idList(playlist.songIds);
    if (songs.length != playlist.songIds.length) {
      var downloaded = await _download(
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
    var songs = await _database.starred();
    if (songs.isEmpty || forceSync) {
      var downloaded = await _download('getStarred2?');
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
        merged = [...downloaded, ...albumSongs.data].toSet().toList();
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
    var byTitle = await _database.title(query);
    var byName = await _database.artistName(query);
    // Converting to set to remove duplicates
    var songs = [...byTitle, ...byName].toSet().toList();

    if (songs.length < 5) {
      var downloaded = await _download(
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
  Future<String> filePath(Song song) => _fileDatabase.filePath(song.id);

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
  Future<void> cacheFile({Song song, File file}) async {
    // Create a filename from song information.
    final path = Path.join(_cacheFolder, '${song.id}.${song.title.hashCode}');
    await _fileDatabase.insertCompanion(AudioFilesCompanion.insert(
      songId: Value(song.id),
      path: path,
      size: (await file.stat()).size,
      created: DateTime.now(),
    ));
    // After inserting the file record, ensure that the cache is still size compliant.
    _cacheSizeCheck();
    await File(path).create(recursive: true);
    return file.copy(path);
  }

  /// Deletes the cache folder and clears the file database.
  Future<void> clearCache() async {
    return Future.wait([
      Directory(_cacheFolder).delete(),
      _fileDatabase.clear(),
    ]);
  }

  void _cacheSizeCheck() async {
    await _cacheCheckLocker.protect(() async {
      final maxSize = Repository().settings.maxAudioCacheSize;
      var currentSize = await _fileDatabase.cacheSize();

      if (currentSize > maxSize) {
        var futures = <Future>[];
        var offset = 0;

        while (currentSize > maxSize) {
          final fileEntry = await _fileDatabase.oldestFile(offset);
          currentSize -= fileEntry.size;
          futures.addAll([
            _fileDatabase.deleteEntry(fileEntry.songId),
            File(fileEntry.path).delete(),
          ]);
          offset++;
        }

        await Future.wait(futures);
      }
    });
  }
}
