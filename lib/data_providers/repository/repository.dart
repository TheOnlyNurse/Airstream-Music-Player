library repository_library;

//Providers
import 'dart:io';
import 'dart:isolate';

import 'package:airstream/data_providers/albums_dao.dart';
import 'package:airstream/data_providers/artists_dao.dart';
import 'package:airstream/data_providers/audio_files_dao.dart';
import 'package:airstream/data_providers/audio_provider.dart';
import 'package:airstream/data_providers/download_provider.dart';
import 'package:airstream/data_providers/image_files_dao.dart';
import 'package:airstream/data_providers/moor_cache.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/data_providers/playlist_provider.dart';
import 'package:airstream/data_providers/scheduler.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:airstream/data_providers/songs_dao.dart';

// Models
import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/models/response/album_response.dart';
import 'package:airstream/models/response/artist_response.dart';
import 'package:airstream/models/response/audio_cache_response.dart';
import 'package:airstream/models/response/playlist_response.dart';
import 'package:airstream/models/response/provider_response.dart';
import 'package:airstream/models/response/song_response.dart';
import 'package:airstream/barrel/communication.dart';
import 'package:airstream/models/percentage_model.dart';
import 'package:flutter/cupertino.dart';

// Flutter/Dart core
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:moor/isolate.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart' as p;

// Parts
part 'album_repo.dart';

part 'artist_repo.dart';

part 'audio_repo.dart';

part 'image_repo.dart';

part 'playlist_repo.dart';

part 'settings_repo.dart';

part 'song_repo.dart';

part 'download_repo.dart';

part 'moor_isolate.dart';

part 'audio_cache_repo.dart';

/// The Repository collects data from providers and formats it easy access and use
/// in UI and Bloc generation. This is the class used by the rest of the UI and bloc logic,
/// however there is little logic here. See the relevant sub-division for that.

class Repository {
  /// Moor database instance, this shouldn't need to be erased by user
  MoorDatabase _database;

  /// Moor cache instance, this can be removed by the user if necessary
  MoorCache _cache;

  /// Singular instances of relevant provider functionality
  Map<String, dynamic> _libInstances;

  /// Libraries
  _AudioRepository get audio => _libInstances['audio'];

  _AudioCacheRepository get audioCache => _libInstances['audioCache'];

  _SongRepository get song => _libInstances['song'];

  _PlaylistRepository get playlist => _libInstances['playlist'];

  _AlbumRepository get album => _libInstances['album'];

  _ArtistRepository get artist => _libInstances['artist'];

  _SettingsRepository get settings => _libInstances['settings'];

  _ImageFilesRepository get image => _libInstances['image'];

  _DownloadRepository get download => _libInstances['download'];

  /// Initialise the boxes required
  Future<Null> init() async {
		// Database directory path
		final dbDirectory = await getApplicationDocumentsDirectory();
		// Moor database, requires db path
		final dbIsolate = await _createMoorDatabase(dbDirectory.path);
		_database = MoorDatabase.connect(await dbIsolate.connect());
		// Moor cache, placed in temporary location automatically
		final cacheIsolate = await _createMoorCache();
		_cache = MoorCache.connect(await cacheIsolate.connect());
		// Hive database location
		Hive.init(dbDirectory.path);
		// Register hive type adapters
		Hive.registerAdapter(PlaylistAdapter());
		// Open required boxes
		await Hive.openBox('albums');
		await Hive.openBox<Playlist>('playlists');
		await Hive.openBox('settings');
		await Hive.openBox<String>('scheduler');
		// Create instances of library parts
		_libInstances = {
			'audioCache': _AudioCacheRepository(dao: _cache.audioFilesDao),
			'song': _SongRepository(dao: _database.songsDao),
			'album': _AlbumRepository(dao: _database.albumsDao),
			'artist': _ArtistRepository(dao: _database.artistsDao),
			'image': _ImageFilesRepository(dao: _cache.imageFilesDao),
			'audio': _AudioRepository(),
			'playlist': _PlaylistRepository(),
			'settings': _SettingsRepository(),
			'download': _DownloadRepository(),
		};
		return;
	}

	/// Singleton boilerplate code
	static final Repository _instance = Repository._internal();

	Repository._internal();

	factory Repository() => _instance;

}
