import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../../common/models/playlist_model.dart';
import '../../../common/providers/moor_database.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/repository/artist_repository.dart';
import '../../../common/repository/audio_repository.dart';
import '../../../common/repository/download_repository.dart';
import '../../../common/repository/image_repository.dart';
import '../../../common/repository/moor_isolate.dart';
import '../../../common/repository/playlist_repository.dart';
import '../../../common/repository/scheduler.dart';
import '../../../common/repository/server_repository.dart';
import '../../../common/repository/settings_repository.dart';
import '../../../common/repository/song_repository.dart';

import 'loading_splash_state.dart';
export 'loading_splash_state.dart';

class SplashScreenCubit extends Cubit<SplashScreenState> {
  SplashScreenCubit() : super(SplashScreenLoading());

  Future<void> loadDatabases() async {
    emit(SplashScreenLoading());
    final databasePath = (await getApplicationDocumentsDirectory()).path;
    final cachePath = (await getTemporaryDirectory()).path;
    await Future.wait([
      _initHive(databasePath),
      _initMoor(databasePath),
    ]);
    _initGetIt(cachePath);
    emit(const SplashScreenSuccess());
  }

  void animationEnded() => emit(const SplashScreenSuccess(shouldReplace: true));
}

Future<void> _initMoor(String databasePath) async {
  final dbIsolate = await createMoorDatabase(databasePath);
  final database = MoorDatabase.connect(await dbIsolate.connect());
  GetIt.I.registerSingleton<MoorDatabase>(database);
}

Future<void> _initHive(String databasePath) async {
  // Hive database location
  Hive.init(databasePath);

  // Register adapters
  Hive.registerAdapter(PlaylistAdapter());

  // Open required boxes
  return Future.wait([
    Hive.openBox<Playlist>('playlists'),
    Hive.openBox('settings'),
    Hive.openBox<String>('scheduler'),
    Hive.openBox('topSongs'),
    Hive.openBox('similarArtists'),
    Hive.openBox('cache'),
    Hive.openBox<int>('images'),
  ]);
}

void _initGetIt(String cachePath) {
  // Assistant function to simplify lazy singleton registration.
  void lazy<T>(T repo) => GetIt.I.registerLazySingleton<T>(() => repo);

  // Register database and cache paths.
  GetIt.I.registerSingleton<String>(cachePath, instanceName: 'cachePath');

  // Registering repositories for use.
  // The order of registration is important due to how they depend on each other.
  // Have a look at their constructors to see how this is done through GetIt.
  lazy<SettingsRepository>(SettingsRepository()); // No requirements
  lazy<ServerRepository>(ServerRepository()); // Requires settings
  lazy<Scheduler>(Scheduler()); // Requires settings and server
  lazy<ImageRepository>(ImageRepository()); // Requires server
  lazy<ArtistRepository>(ArtistRepository()); // Requires server
  lazy<SongRepository>(SongRepository()); // Requires server & settings
  lazy<PlaylistRepository>(PlaylistRepository()); // Requires server & scheduler
  lazy<AlbumRepository>(AlbumRepository()); // Requires server & scheduler
  lazy<DownloadRepository>(DownloadRepository()); // Requires song repo
  lazy<AudioRepository>(AudioRepository()); // Requires song, download & image repos
}
