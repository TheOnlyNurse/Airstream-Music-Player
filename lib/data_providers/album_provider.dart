import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:airstream/models/album_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;

import 'audio_cache_provider.dart';

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

  Future<List<Album>> getLibraryList() async {
    final db = await database;
    final response = await db.query(dbName, orderBy: 'title ASC');

    if (response.isEmpty)
      return _checkOnlineStatus(await _downloadAlbums());
    else
      return _checkOnlineStatus(response.map((a) => Album.fromSQL(a)).toList());
  }

  Future<List<Album>> _downloadAlbums() async {
    final size = 500;
    int offset = 0;
    bool hasChildren = true;
    final albumList = <Album>[];

    // Clear db in preparation for new entries
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

    return albumList;
  }

  Future<List<Album>> query(
      {String title, int artistId, int id, @required int searchLimit}) async {
    assert(searchLimit != null);

    final db = await database;
    final queryArgs = <String, dynamic>{};

    if (title != null) {
      queryArgs['where'] = 'title LIKE ?';
      queryArgs['whereArgs'] = ['%$title%'];
    }
    if (artistId != null) {
      queryArgs['where'] = 'artistId = ?';
      queryArgs['whereArgs'] = [artistId];
    }
    if (id != null) {
      queryArgs['where'] = 'id = ?';
      queryArgs['whereArgs'] = [id];
    }

    final response = await db.query(
      dbName,
      where: queryArgs['where'],
      whereArgs: queryArgs['whereArgs'],
      limit: 5,
    );

    if (response.isNotEmpty)
      return _checkOnlineStatus(response.map((e) => Album.fromSQL(e)).toList());

    return null;
  }

  Future<List<Album>> _checkOnlineStatus(List<Album> albumList) async {
    if (albumList.isEmpty || albumList == null) return null;

    if (await SettingsProvider().isOffline) {
      final cachedList = <Album>[];
      final offlineList = await AudioCacheProvider().getCachedList(albums: true);

      if (offlineList == null) return null;

      for (var album in albumList) {
        if (offlineList.contains(album.id)) cachedList.add(album);
      }

      if (cachedList.isEmpty) return null;
      return cachedList;
    }

    return albumList;
  }

  Future<List<Album>> _addXmlElements(List<xml.XmlElement> elementList) async {
    final albumList = elementList.map((e) => Album.fromServer(e)).toList();

    final db = await database;
    for (var album in albumList) await db.insert(dbName, album.toSQL());

    return albumList;
  }
}
