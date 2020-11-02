import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Internal links
import '../providers/moor_database.dart';
import '../repository/artist_repository.dart';
import '../providers/repository/repository.dart';
import '../providers/albums_dao.dart';
import '../providers/image_provider.dart';
import '../models/playlist_model.dart';
import '../repository/album_repository.dart';
import '../repository/image_repository.dart';
import '../providers/artists_dao.dart';
import '../providers/songs_dao.dart';
import '../repository/song_repository.dart';

class SplashScreenCubit extends Cubit<SplashScreenState> {
  SplashScreenCubit() : super(SplashScreenLoading());

  void loadDatabases() async {
    emit(SplashScreenLoading());
    final dbDirectory = await getApplicationDocumentsDirectory();
    final cacheDirectory = await getTemporaryDirectory();
    await _initHive(dbDirectory.path);
    await Repository().init(dbDirectory.path);
    _initGetIt(cacheDirectory.path);
    emit(SplashScreenSuccess());
  }

  void animationEnded() => emit(SplashScreenSuccess(shouldReplace: true));

  Future<void> _initHive(String dbPath) async {
    // Hive database location
    Hive.init(dbPath);

    // Register adapters
    Hive.registerAdapter(PlaylistAdapter());

    // Open required boxes
    await Hive.openBox<Playlist>('playlists');
    await Hive.openBox('settings');
    await Hive.openBox<String>('scheduler');
    await Hive.openBox('topSongs');
    await Hive.openBox('similarArtists');
    await Hive.openBox('cache');
    await Hive.openBox<int>('images');

    return;
  }

  void _initGetIt(String cachePath) {
    final getIt = GetIt.I;
    final moorDb = GetIt.I.get<MoorDatabase>();

    // Providers for repositories.
    final imageFiles = ImageFileProvider(
      hive: Hive.box<int>('images'),
      cacheFolder: p.join(cachePath, 'image/'),
    );

    // Registering repositories for use.
    getIt.registerSingleton<ImageRepository>(ImageRepository(imageFiles));
    getIt.registerLazySingleton<AlbumRepository>(() {
      return AlbumRepository(albumsDao: AlbumsDao(moorDb));
    });
    getIt.registerLazySingleton<ArtistRepository>(() {
      return ArtistRepository(artistsDao: ArtistsDao(moorDb));
    });

    getIt.registerLazySingleton<SongRepository>(() {
      return SongRepository(
        songsDao: SongsDao(moorDb),
        artistRepository: getIt.get<ArtistRepository>(),
      );
    });
  }
}

abstract class SplashScreenState {
  const SplashScreenState();
}

class SplashScreenLoading extends SplashScreenState {}

class SplashScreenSuccess extends SplashScreenState {
  const SplashScreenSuccess({this.shouldReplace = false});

  final bool shouldReplace;
}
