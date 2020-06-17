import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart' as xml;
import 'audio_cache_provider.dart';

class AlbumProvider extends DatabaseProvider {
  /// Global Functions
  Future<ProviderResponse> library() async {
    final db = await database;
    final response = await db.query(dbName);

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
    @required String where,
    @required List<dynamic> args,
    int searchLimit,
  }) async {
    assert(where != null);
    assert(args != null);

    final db = await database;

    final response = await db.query(
      dbName,
      where: where,
      whereArgs: args,
      limit: searchLimit,
    );

    if (response.isNotEmpty) {
      final queryList = response.map((e) => Album.fromSQL(e)).toList();
      return _checkOnlineStatus(ProviderResponse(status: DataStatus.ok, data: queryList));
    }

    return ProviderResponse(
      status: DataStatus.error,
      source: ProviderSource.album,
      message: 'did not find query: $args',
    );
  }

  Future<ProviderResponse> played(String type) async {
    final serverResponse = await ServerProvider().fetchRequest(
      'getAlbumList2?type=$type&size=50',
      FetchType.xmlDoc,
    );

    final lastSavedFile = File(p.join(await getDatabasesPath(), type));
    final idList = <int>[];
    if (serverResponse.status == DataStatus.ok) {
      final xml.XmlDocument xmlDoc = serverResponse.data;
      idList.addAll(xmlDoc
          .findAllElements('album')
          .map((e) => int.parse(e.getAttribute('id')))
          .toList());

      lastSavedFile.writeAsStringSync(jsonEncode(idList));
    } else {
      idList.addAll(jsonDecode(lastSavedFile.readAsStringSync()).cast<int>());
    }

    final albumList = <Album>[];
    for (int id in idList) {
      final response = await query(where: 'id = ?', args: [id], searchLimit: 1);
      if (response.status == DataStatus.ok) albumList.add(response.data.first);
    }

    if (albumList.isEmpty) {
      return ProviderResponse(
        status: DataStatus.error,
        source: ProviderSource.album,
        message: 'could not contact server to get $type',
      );
    } else {
      return ProviderResponse(status: DataStatus.ok, data: albumList);
    }
  }

  Future<ProviderResponse> collection(
    CollectionType type, {
    int limit,
    dynamic arguments,
  }) async {
    final response = await library();
    if (response.status == DataStatus.error) return response;
    final List<Album> albumList = response.data;

    switch (type) {
      case CollectionType.random:
        albumList.shuffle();
        break;
      case CollectionType.recent:
        albumList.sort((a, b) => b.date.compareTo(a.date));
        break;
      case CollectionType.allDecades:
        final decadesList = albumList.map((album) {
          if (album.year == null) return null;
          return (album.year / 10).floor() * 10;
        }).toList();
        decadesList.removeWhere((e) => e == null);
        decadesList.sort((a, b) => b.compareTo(a));
        final condensedDecades = LinkedHashSet<int>.from(decadesList).toList();
        return ProviderResponse(status: DataStatus.ok, data: condensedDecades);
        break;
      case CollectionType.allGenres:
        final genreList = albumList.map((e) => e.genre).toList();
        genreList.removeWhere((e) => e == null);
        genreList.sort((a, b) => a.compareTo(b));
        final condensedGenres = LinkedHashSet<String>.from(genreList).toList();
        return ProviderResponse(status: DataStatus.ok, data: condensedGenres);
        break;
      case CollectionType.alphabet:
        albumList.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    if (limit == null || limit > albumList.length) limit = albumList.length;
    return ProviderResponse(status: DataStatus.ok, data: albumList.sublist(0, limit));
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
    for (var album in albumList) await db.insert(dbName, album.toSQL());

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
      'art TEXT,'
      'date TEXT,'
      'genre TEXT,'
      'year INTEGER,'
      'mostPlayed INTEGER';

  /// Singleton boilerplate code
  AlbumProvider._internal();

  static final AlbumProvider _instance = AlbumProvider._internal();

  factory AlbumProvider() => _instance;
}

enum CollectionType { random, recent, allDecades, allGenres, alphabet }
