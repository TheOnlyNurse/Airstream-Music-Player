library repository_library;

//Providers
import 'dart:io';
import 'dart:isolate';

import 'package:airstream/data_providers/audio_files_dao.dart';
import 'package:airstream/data_providers/audio_provider.dart';
import 'package:airstream/data_providers/download_provider.dart';
import 'package:airstream/data_providers/moor_cache.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/data_providers/playlist_provider.dart';
import 'package:airstream/data_providers/scheduler.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:airstream/data_providers/songs_dao.dart';
import 'package:airstream/data_providers/starred_provider.dart';

// Models
import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/models/response/audio_cache_response.dart';
import 'package:airstream/models/response/playlist_response.dart';
import 'package:airstream/models/response/provider_response.dart';
import 'package:airstream/models/response/song_response.dart';
import 'package:airstream/barrel/communication.dart';
import 'package:airstream/models/percentage_model.dart';
import 'package:airstream/models/response/starred_response.dart';

// Flutter/Dart core
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:moor/isolate.dart';
import 'package:moor/moor.dart';
import 'package:moor/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart' as p;

// Parts
part 'audio_repo.dart';

part 'playlist_repo.dart';

part 'settings_repo.dart';

part 'song_repo.dart';

part 'download_repo.dart';

part 'moor_isolate.dart';

part 'audio_cache_repo.dart';

part 'starred_repo.dart';

/// The Repository collects data from providers and formats it easy access and use
/// in UI and Bloc generation. This is the class used by the rest of the UI and bloc logic,
/// however there is little logic here. See the relevant sub-division for that.

class Repository {
  /// Singular instances of relevant provider functionality
  Map<String, dynamic> _libInstances;

  /// Libraries
  _AudioRepository get audio => _libInstances['audio'];

  _AudioCacheRepository get audioCache => _libInstances['audioCache'];

  _SongRepository get song => _libInstances['song'];

  _PlaylistRepository get playlist => _libInstances['playlist'];

	_SettingsRepository get settings => _libInstances['settings'];

	_DownloadRepository get download => _libInstances['download'];

	_StarredRepository get starred => _libInstances['starred'];

	/// Initialise the boxes required
	Future<Null> init(String dbPath) async {
			// Moor database, requires db path
			final dbIsolate = await _createMoorDatabase(dbPath);
			final database = MoorDatabase.connect(await dbIsolate.connect());
			GetIt.I.registerSingleton<MoorDatabase>(database);
			// Moor cache, placed in temporary location automatically
			final cacheIsolate = await _createMoorCache();
			final cache = MoorCache.connect(await cacheIsolate.connect());
			GetIt.I.registerSingleton<MoorCache>(cache);

    // Create instances of library parts
    _libInstances = {
      'audioCache': _AudioCacheRepository(dao: cache.audioFilesDao),
      'song': _SongRepository(dao: database.songsDao),
      'audio': _AudioRepository(),
      'playlist': _PlaylistRepository(),
      'settings': _SettingsRepository(),
      'download': _DownloadRepository(),
			'starred': _StarredRepository(),
		};
		return;
	}

	/// Singleton boilerplate code
	static final Repository _instance = Repository._internal();

	Repository._internal();

	factory Repository() => _instance;

}
