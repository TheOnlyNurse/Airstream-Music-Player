import 'package:airstream/barrel/provider_basics.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/models/response/server_response.dart';
import 'package:airstream/models/response/song_response.dart';
import 'package:moor/moor.dart';
import 'package:xml/xml.dart' as xml;

part 'songs_dao.g.dart';

class Songs extends Table {
  IntColumn get id => integer()();

  TextColumn get title => text()();

  TextColumn get album => text()();

  TextColumn get artist => text()();

  TextColumn get art => text()();

  IntColumn get albumId => integer()();

  BoolColumn get isStarred => boolean().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseDao(tables: [Songs])
class SongsDao extends DatabaseAccessor<MoorDatabase> with _$SongsDaoMixin {
  SongsDao(MoorDatabase db) : super(db);

  /// Searches for song list by search type and argument
  Future<SongResponse> search(SongSearch byType, {dynamic argument}) async {
    List<Song> result;
    switch (byType) {
      case SongSearch.byId:
        // Formatting single result to conform with other searches
        final singleResult = await _byId(argument);
        result = singleResult == null ? [] : [singleResult];
        break;
      case SongSearch.byStarred:
        result = await _byStarred();
        break;
      case SongSearch.byAlbum:
        result = await _byAlbum(argument);
        break;
      case SongSearch.byTitle:
        result = await _byTitle(argument);
        break;
      case SongSearch.byArtistName:
        result = await _byArtistName(argument);
        break;
      default:
        throw UnimplementedError(byType.toString());
    }

    if (result.isEmpty) {
      if (byType == SongSearch.byStarred) {
        return _checkIfOnline(await updateStarred());
      } else {
        return _checkIfOnline(await _download(byType, argument));
      }
    } else {
      return _checkIfOnline(SongResponse(hasData: true, songList: result));
    }
  }

  /// Updates songs as dictated by the server
  Future<SongResponse> updateStarred() async {
    final response = await ServerProvider().fetchXml('getStarred?');
    if (response.hasNoData) return SongResponse(passOn: response);
    final companions = _documentToCompanions(
      response.document,
      isStarred: true,
    );
    await _resetAllStarred();
    await _insertCompanions(companions, mode: InsertMode.replace);
    final songs = await _companionsToSongs(companions);
    if (songs.isEmpty) {
      return SongResponse(error: 'Failed to find any starred songs.');
    } else {
      return SongResponse(hasData: true, songList: songs);
    }
  }

  Future<Null> changeStar(int songId, bool newStar) async {
    final query = update(songs);
    query.where((tbl) => tbl.id.equals(songId));
    return query.write(SongsCompanion(isStarred: Value(newStar)));
  }

  /// Set all starred songs to false
  Future<int> _resetAllStarred() async {
    final query = update(songs);
    query.where((tbl) => tbl.isStarred.equals(true));
    return query.write(SongsCompanion(isStarred: Value(false)));
  }

  /// Search for song by id, fetching from server if necessary
  Future<Song> _byId(int id) async {
    final query = select(songs);
    query.where((tbl) => tbl.id.equals(id));
    return query.getSingle();
  }

  /// Returns a cached version of songs if device is in offline mode
  Future<SongResponse> _checkIfOnline(SongResponse input) async {
    if (Repository().settings.isOffline) {
      if (input.hasNoData) return input;
      final cachedList = <Song>[];
      final offlineList = await Repository().audioCache.cachedSongs();

      if (offlineList.hasNoData) return SongResponse(passOn: offlineList);

      for (var song in input.songList) {
        if (offlineList.idList.contains(song.id)) cachedList.add(song);
      }

      if (cachedList.isEmpty) {
        return SongResponse(error: 'No songs match cache');
      } else {
        print(cachedList.length);
        return SongResponse(hasData: true, songList: cachedList);
      }
    } else {
      return input;
    }
  }

  /// Returns songs that are starred
  Future<List<Song>> _byStarred() async {
    final query = select(songs);
    query.where((tbl) => tbl.isStarred.equals(true));
    return query.get();
  }

  /// Returns a song list by album id
  Future<List<Song>> _byAlbum(int albumId) {
    final query = select(songs);
    query.where((tbl) => tbl.albumId.equals(albumId));
    return query.get();
  }

  /// Returns a song list by a title query
  Future<List<Song>> _byTitle(String title) {
    final query = select(songs);
    query.where((tbl) => tbl.title.like(title));
    return query.get();
  }

  /// Returns a song list by artist name query
  Future<List<Song>> _byArtistName(String artist) {
    final query = select(songs);
    query.where((tbl) => tbl.artist.like(artist));
    return query.get();
  }

  /// Downloads a song or song list by search type and argument from the server
  Future<SongResponse> _download(SongSearch byType, dynamic argument) async {
    final response = await _requestByType(byType, argument);
    if (response.hasNoData) return SongResponse(passOn: response);
    final companions = _documentToCompanions(response.document);
    if (companions.isEmpty) {
      return SongResponse(error: 'Failed to find song/s on server.');
    }
    await _insertCompanions(companions);
    final songs = await _companionsToSongs(companions);

    return SongResponse(hasData: true, songList: songs);
  }

  /// Returns requests to the server split by type
  Future<ServerResponse> _requestByType(SongSearch byType, dynamic argument) {
    switch (byType) {
      case SongSearch.byId:
        return ServerProvider().fetchXml('getSong?id=$argument');
        break;
      case SongSearch.byAlbum:
        return ServerProvider().fetchXml('getAlbum?id=$argument');
        break;
      case SongSearch.byTitle:
        return _downloadSearch(argument);
        break;
      case SongSearch.byArtistName:
        return _downloadSearch(argument);
        break;
      default:
        throw UnimplementedError(byType.toString());
    }
  }

  /// Coverts a list of companions into songs
  Future<List<Song>> _companionsToSongs(List<SongsCompanion> companions) async {
    final songList = <Song>[];
    for (var companion in companions) {
      songList.add(await _companionToSong(companion));
    }
    return songList;
  }

  /// Converts a companion into a song by searching the database by id
  Future<Song> _companionToSong(SongsCompanion companion) async {
    final query = select(songs);
    query.where((tbl) => tbl.id.equals(companion.id.value));
    final result = query.getSingle();
    if (result == null) {
      throw Exception('Companion ${companion.title} has not been inserted '
          'prior to conversion to song.');
    } else {
      return result;
    }
  }

  /// Inserts a batch of companions into the database
  Future<Null> _insertCompanions(
    List<SongsCompanion> companions, {
    InsertMode mode = InsertMode.insertOrIgnore,
  }) async {
    await batch((batch) => batch.insertAll(songs, companions, mode: mode));
    return;
  }

  /// Parses an xml document in relevant song elements
  List<SongsCompanion> _documentToCompanions(
    xml.XmlDocument document, {
    bool isStarred = false,
  }) {
    final elements = document.findAllElements('song');
    final songs = <SongsCompanion>[];
    for (var element in elements) {
      songs.add(_elementToCompanion(element, isStarred));
    }
    return songs;
  }

  /// Parses an xml element into a companion for database insertion
  SongsCompanion _elementToCompanion(xml.XmlElement element, bool isStarred) {
    return SongsCompanion.insert(
      id: Value(_parseAsInt(element.getAttribute('id'))),
      title: element.getAttribute('title'),
      artist: element.getAttribute('artist'),
      album: element.getAttribute('album'),
      art: element.getAttribute('coverArt'),
      albumId: _parseAsInt(element.getAttribute('albumId')),
      isStarred: Value(isStarred),
    );
  }

  /// Either parses a string or returns null if the object is null
  int _parseAsInt(String attribute) {
    return attribute == null ? null : int.parse(attribute);
  }

  /// Request to get songs by searching a query
  Future<ServerResponse> _downloadSearch(String query) {
    return ServerProvider().fetchXml('search3?query=$query'
        '&songCount=10'
        '&artistCount=0'
        '&albumCount=0');
  }
}

enum SongSearch { byId, byAlbum, byTitle, byArtistName, byStarred }
