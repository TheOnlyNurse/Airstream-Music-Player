import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/models/album_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;

class AlbumProvider extends DatabaseProvider {
  @override
  String get dbName => 'albums';

  @override
  String get tableColumns => 'id INTEGER primary key NOT NULL,'
      'title TEXT NOT NULL,'
      'artist TEXT,'
      'artistId INTEGER,'
      'songCount INTEGER,'
      'art TEXT';

  AlbumProvider._internal();

  static final AlbumProvider _instance = AlbumProvider._internal();

  factory AlbumProvider() => _instance;

  final virtualCache = <Album>[];

  Future<List<Album>> getLibraryList() async {
    if (virtualCache.isNotEmpty) {
      return virtualCache;
    }

    final db = await database;
    final response = await db.query(dbName, orderBy: 'title ASC');

    if (response.isEmpty) {
      return _downloadAlbums();
    } else {
      virtualCache.addAll(response.map((a) => Album.fromSQL(a)).toList());
      return virtualCache;
    }
  }

  Future<List<Album>> _downloadAlbums() async {
		final size = 500;
		int offset = 0;
		bool hasChildren = true;
		final albumList = <Album>[];

		// Clear db in preparation for new entries
		virtualCache.clear();
		await (await database).delete(dbName);

		do {
			final response = await ServerProvider()
					.fetchXML('getAlbumList2?type=alphabeticalByName&size=$size&offset=$offset');
			if (response == null) break;
			final elementList = response.findAllElements('album').toList();
			if (elementList.isEmpty) {
				hasChildren = false;
			} else {
				albumList.addAll(await _addXmlElements(elementList));
				offset += size;
			}
		} while (hasChildren);

		virtualCache.addAll(albumList);
		return albumList;
	}

	Future<List<Album>> query({String title}) async {
		final db = await database;
		final response = await db.query(
			dbName,
			where: 'title LIKE ?',
			whereArgs: ['%$title%'],
			limit: 5,
		);

		if (response.isNotEmpty) {
			return response.map((e) => Album.fromSQL(e)).toList();
		}
		return null;
	}

	Future<List<Album>> _addXmlElements(List<xml.XmlElement> elementList) async {
		final albumList = elementList.map((e) => Album.fromServer(e)).toList();

		final db = await database;
		for (var album in albumList)
			await db.insert(dbName, album.toSQL());

		return albumList;
	}

  Future<int> getArtistId(int albumId) async {
    final db = await database;
    final response = await db.query(
      dbName,
      columns: ['artistId'],
      where: 'id = ?',
      whereArgs: [albumId],
    );
    return response.first['artistId'];
  }

  Future<List<Album>> getAlbumList({@required int artistId}) async {
    final db = await database;
    final response = await db.query(dbName, where: 'artistId = ?', whereArgs: [artistId]);
    return response.map((e) => Album.fromSQL(e)).toList();
  }
}
