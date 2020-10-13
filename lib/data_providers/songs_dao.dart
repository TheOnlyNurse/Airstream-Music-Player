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

  TextColumn get art => text().nullable()();

  IntColumn get albumId => integer()();

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
      return _checkIfOnline(await _download(byType, argument));
    } else {
      return _checkIfOnline(SongResponse(hasData: true, songs: result));
    }
  }

  /// Returns starred songs as dictated by starred provider
  /// Because _byIdList supplies cached songs if offline (through the main
  /// search function) there is no need to double up here
  Future<SongResponse> starred() async {
    final response = await Repository().starred.query('song');
    if (response.hasNoData) return SongResponse(passOn: response);
    final songs = await _byIdList(response.idList);
    if (songs.isEmpty) {
      return SongResponse(error: 'Failed to find starred song ids.');
    } else {
      return SongResponse(hasData: true, songs: songs);
    }
  }

  /// Fetches top songs of a given artist from either a hive box or the server
  Future<SongResponse> topSongsOf(Artist artist) async {
    final _hiveBox = Hive.box('topSongs');
    List<int> cachedIdList = _hiveBox.get(artist.id);
    if (cachedIdList == null) {
      final name = artist.name.replaceAll(' ', '+');
      final response = await ServerProvider().fetchXml(
        'getTopSongs?artist=$name&count=5',
      );
      if (response.hasData) {
        final elements = response.document.findAllElements('song');
        cachedIdList = elements.map((e) {
          return int.parse(e.getAttribute('id'));
        }).toList();
        _hiveBox.put(artist.id, cachedIdList);
      } else {
        cachedIdList = [];
      }
    }

    final songs = await _byIdList(cachedIdList);
    if (songs.isEmpty) {
      return SongResponse(error: 'Failed to find artist\'s top songs.');
    } else {
      return SongResponse(hasData: true, songs: songs);
    }
  }

  /// Returns a song list given a list of ids
  /// Since this goes through the search function of this dao, the ids can be
  /// assured to be updated if missing
  Future<List<Song>> _byIdList(List<int> idList) async {
    final songs = <Song>[];
    for (var id in idList) {
      final response = await search(SongSearch.byId, argument: id);
      if (response.hasData) songs.add(response.song);
    }
    return songs;
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

      for (var song in input.songs) {
        if (offlineList.idList.contains(song.id)) cachedList.add(song);
      }

      if (cachedList.isEmpty) {
        return SongResponse(error: 'No songs match cache');
      } else {
        return SongResponse(hasData: true, songs: cachedList);
      }
    } else {
      return input;
    }
  }

  /// Returns a song list by album id
  Future<List<Song>> _byAlbum(int albumId) {
    final query = select(songs);
    query.where((tbl) => tbl.albumId.equals(albumId));
    query.orderBy([(t) => OrderingTerm(expression: t.title)]);
    return query.get();
  }

  /// Returns a song list by a title query
  Future<List<Song>> _byTitle(String title) {
		final query = select(songs);
		query.where((tbl) => tbl.title.like('%$title%'));
		return query.get();
	}

  /// Returns a song list by artist name query
  Future<List<Song>> _byArtistName(String artist) {
		final query = select(songs);
		query.where((tbl) => tbl.artist.like('%$artist%'));
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
    // Sort if search type is albums
    if (byType == SongSearch.byAlbum) {
      songs.sort((a, b) => a.title.compareTo(b.title));
    }
    return SongResponse(hasData: true, songs: songs);
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
	List<SongsCompanion> _documentToCompanions(xml.XmlDocument document) {
		final elements = document.findAllElements('song');
		final songs = <SongsCompanion>[];
		for (var element in elements) {
			songs.add(_elementToCompanion(element));
		}
		return songs;
	}

	/// Parses an xml element into a companion for database insertion
	SongsCompanion _elementToCompanion(xml.XmlElement element) {
		return SongsCompanion.insert(
			id: Value(_parseAsInt(element.getAttribute('id'))),
			title: element.getAttribute('title'),
			artist: element.getAttribute('artist'),
			album: element.getAttribute('album'),
			art: Value(element.getAttribute('coverArt')),
			albumId: _parseAsInt(element.getAttribute('albumId')),
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
