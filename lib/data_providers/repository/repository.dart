import 'album_repo.dart';
import 'artist_repo.dart';
import 'audio_repo.dart';
import 'image_repo.dart';
import 'playlist_repo.dart';
import 'settings_repo.dart';
import 'song_repo.dart';

/// The Repository collects data from providers and formats it for ease of access and use
/// in UI and Bloc generation. This is the class used by the rest of the UI and bloc logic,
/// however there is little logic here. See the relevant sub-division for that.

class Repository {
  /// Singular instances of relevant provider functionality
  final _instances = <String, dynamic>{
    'audio': AudioRepository(),
    'song': SongRepository(),
    'playlist': PlaylistRepository(),
    'album': AlbumRepository(),
    'artist': ArtistRepository(),
    'settings': SettingsRepository(),
    'image': ImageRepository(),
  };

  /// Global Variables
  AudioRepository get audio => _instances['audio'];

  SongRepository get song => _instances['song'];

  PlaylistRepository get playlist => _instances['playlist'];

  AlbumRepository get album => _instances['album'];

  ArtistRepository get artist => _instances['artist'];

  SettingsRepository get settings => _instances['settings'];

  ImageRepository get image => _instances['image'];

  /// Singleton boilerplate code
  static final Repository _instance = Repository._internal();

  Repository._internal();

  factory Repository() {
    return _instance;
  }
}

// Enums used as communication
enum SongChange { unstarred, starred }
enum PlaylistChange { songsRemoved, songsAdded, fetched }
enum SettingsChangedType { prefetch, isOffline, imageCache, musicCache }
