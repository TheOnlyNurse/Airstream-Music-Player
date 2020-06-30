import 'package:airstream/barrel/provider_basics.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/data_providers/repository/repository.dart';
import 'package:airstream/models/response/artist_response.dart';
import 'package:moor/moor.dart';
import 'package:xml/xml.dart' as xml;

part 'artists_dao.g.dart';

class Artists extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  IntColumn get albumCount => integer()();

  TextColumn get art => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseDao(tables: [Artists])
class ArtistsDao extends DatabaseAccessor<MoorDatabase> with _$ArtistsDaoMixin {
  /// So that the main database can create an instance of this dao
  ArtistsDao(MoorDatabase db) : super(db);

  /// Returns artists by alphabetically name
  Future<ArtistResponse> byAlphabet() async {
    final query = select(artists);
    query.orderBy([(a) => OrderingTerm(expression: a.name)]);
    final list = await query.get();
    if (list.isEmpty) {
      return ArtistResponse(error: 'Failed to find any artists.');
    } else {
      return _checkIfOnline(ArtistResponse(hasData: true, artists: list));
    }
  }

  /// Search for artist by name
  Future<ArtistResponse> search(String name) async {
    final query = select(artists);
    query.where((tbl) => tbl.name.contains(name));
    final list = await query.get();
    if (list.isEmpty) {
      return ArtistResponse(error: 'Failed to find query: $name.');
    } else {
      return ArtistResponse(hasData: true, artists: list);
    }
  }

  /// Deletes the current library and downloads the server version
  /// Returns an empty response on completion
  Future<ArtistResponse> updateLibrary() async {
    await delete(artists).go();
    return _download();
  }

  /// If in offline mode, returns only artists that have cached songs
  Future<ArtistResponse> _checkIfOnline(ArtistResponse input) async {
    if (Repository().settings.isOffline) {
      if (input.hasNoData) return input;
      final cachedList = <Artist>[];
      final response = await Repository().album.byAlphabet();
      if (response.hasNoData) return ArtistResponse(passOn: response);

      final idList = response.albums.map((item) => item.artistId).toList();
      for (var artist in input.artists) {
        if (idList.contains(artist.id)) cachedList.add(artist);
      }

      if (cachedList.isEmpty) {
        return ArtistResponse(error: 'No cached artists.');
      } else {
        return ArtistResponse(hasData: true, artists: cachedList);
      }
    } else {
      return input;
    }
  }

  /// Downloads the server artists, returns an empty response on completion
  Future<ArtistResponse> _download() async {
    final response = await ServerProvider().fetchXml('getArtists?');
    if (response.hasNoData) return ArtistResponse(passOn: response);
    final companions = _documentToCompanions(response.document);
    await batch((batch) => batch.insertAll(artists, companions));
    return ArtistResponse(hasData: true);
  }

  /// Converts an xml documents to artist companions for easy insertion
  List<ArtistsCompanion> _documentToCompanions(xml.XmlDocument document) {
    final elements = document.findAllElements('artist');
    return elements.map((e) => _elementToCompanion(e)).toList();
  }

  /// Converts an xml element to a companion
  ArtistsCompanion _elementToCompanion(xml.XmlElement element) {
    return ArtistsCompanion.insert(
      id: Value(int.parse(element.getAttribute('id'))),
      name: element.getAttribute('name'),
      albumCount: int.parse(element.getAttribute('albumCount')),
      art: element.getAttribute('coverArt'),
    );
  }
}