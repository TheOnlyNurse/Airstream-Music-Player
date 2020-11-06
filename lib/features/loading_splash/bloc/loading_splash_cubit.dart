import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;

/// Internal links
import '../../../common/providers/moor_database.dart';
import '../../../common/repository/artist_repository.dart';
import '../../../common/providers/repository/repository.dart';
import '../../../common/providers/albums_dao.dart';
import '../../../common/providers/image_provider.dart';
import '../../../common/models/playlist_model.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/repository/image_repository.dart';
import '../../../common/providers/artists_dao.dart';
import '../../../common/providers/songs_dao.dart';
import '../../../common/repository/song_repository.dart';
import '../../../common/providers/audio_files_dao.dart';

part 'loading_splash_state.dart';

class SplashScreenCubit extends Cubit<SplashScreenState> {
  SplashScreenCubit() : super(SplashScreenLoading());

  void loadDatabases() async {
    emit(SplashScreenLoading());
    final databasePath = (await getApplicationDocumentsDirectory()).path;
    final cachePath = (await getTemporaryDirectory()).path;
    await Future.wait([
      _initHive(databasePath),
      _initMoor(databasePath),
    ]);
    _initGetIt(cachePath);
    emit(SplashScreenSuccess());
  }

  void animationEnded() => emit(SplashScreenSuccess(shouldReplace: true));
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
  // Assistant function to ease lazy singleton registration.
  void lazy<T>(T repo) => GetIt.I.registerLazySingleton<T>(() => repo);
  // Many providers require access to the Moor Database isolate.
  final moorDb = GetIt.I.get<MoorDatabase>();

  // Registering repositories for use.
  lazy<ImageRepository>(ImageRepository(ImageFileProvider(
    hive: Hive.box<int>('images'),
    cacheFolder: Path.join(cachePath, 'image/'),
  )));
  lazy<AlbumRepository>(AlbumRepository(albumsDao: AlbumsDao(moorDb)));
  lazy<ArtistRepository>(ArtistRepository(artistsDao: ArtistsDao(moorDb)));
  lazy<SongRepository>(SongRepository(
    songsDao: SongsDao(moorDb),
    audioFilesDao: AudioFilesDao(moorDb),
    cacheFolder: Path.join(cachePath, 'audio/'),
  ));
}
