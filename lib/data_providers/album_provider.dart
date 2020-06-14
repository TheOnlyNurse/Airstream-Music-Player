import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;

import 'audio_cache_provider.dart';

class AlbumProvider extends DatabaseProvider {
  /// Global Functions
  Future<ProviderResponse> library() async {
    final db = await database;
    final response = await db.query(dbName, orderBy: 'title ASC');

    if (response.isEmpty) {
      return await _checkOnlineStatus(await _download());
    } else {
      final databaseList = response.map((a) => Album.fromSQL(a)).toList();

      return _checkOnlineStatus(ProviderResponse(
        status: DataStatus.ok,
        data: databaseList,
      ));
    }
  }

  Future<ProviderResponse> query({
    String title,
    int artistId,
    int id,
    @required int searchLimit,
  }) async {
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

    if (response.isNotEmpty) {
      final queryList = response.map((e) => Album.fromSQL(e)).toList();
      return _checkOnlineStatus(ProviderResponse(status: DataStatus.ok, data: queryList));
    }

    return ProviderResponse(
      status: DataStatus.error,
      source: ProviderSource.album,
      message: 'did not find query: ${queryArgs['whereArgs']}',
    );
  }

  /// Private Functions
  Future<ProviderResponse> _download() async {
    final size = 500;
    int offset = 0;
    bool hasChildren = true;
    final albumList = <Album>[];

    // Clear db in preparation for new entries
    await (await database).delete(dbName);

    do {
      final response = await ServerProvider().fetchRequest(
        'getAlbumList2?type=alphabeticalByName&size=$size&offset=$offset',
        FetchType.xmlDoc,
      );

      if (response.status == DataStatus.error) return response;
      assert(response.data is xml.XmlDocument);

      final elementList = response.data.findAllElements('album').toList();

      if (elementList.isEmpty) {
        hasChildren = false;
      } else {
        albumList.addAll(await _addXmlElements(elementList));
        offset += size;
      }
    } while (hasChildren);

    if (albumList.isEmpty) {
      return ProviderResponse(
        status: DataStatus.error,
        source: ProviderSource.album,
        message: 'found no albums on server',
      );
    } else {
      return ProviderResponse(status: DataStatus.ok, data: albumList);
    }
  }

  Future<ProviderResponse> _checkOnlineStatus(ProviderResponse response) async {
    if (response.status == DataStatus.error) return response;

    final albumList = response.data;

    if (await SettingsProvider().isOffline) {
      final cachedList = <Album>[];
      final response = await AudioCacheProvider().getCachedList(albums: true);

      if (response.status == DataStatus.error) return response;
      assert(response.data is List<int>);

      for (var album in albumList) {
        if (response.data.contains(album.id)) cachedList.add(album);
      }

      if (cachedList.isEmpty) {
        return ProviderResponse(
          status: DataStatus.error,
          source: ProviderSource.album,
          message: 'local albums database doesn\'t contain cached albums,'
              ' something went real wrong',
        );
      } else {
        return ProviderResponse(status: DataStatus.ok, data: cachedList);
      }
    }

    return ProviderResponse(status: DataStatus.ok, data: albumList);
  }

  Future<List<Album>> _addXmlElements(List<xml.XmlElement> elementList) async {
    final albumList = elementList.map((e) => Album.fromServer(e)).toList();

    final db = await database;
    for (var album in albumList)
      await db.insert(dbName, album.toSQL());

    return albumList;
  }

  /// Database Provider overrides
  @override
  String get dbName => 'albums';

  @override
  String get tableColumns => 'id INTEGER primary key NOT NULL,'
      'title TEXT NOT NULL,'
      'artist TEXT,'
      'artistId INTEGER,'
      'songCount INTEGER,'
      'art TEXT';

  /// Singleton boilerplate code
  AlbumProvider._internal();

  static final AlbumProvider _instance = AlbumProvider._internal();

  factory AlbumProvider() => _instance;
}
