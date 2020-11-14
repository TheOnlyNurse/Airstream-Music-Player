import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:airstream/common/global_assets.dart';
import 'package:airstream/common/providers/discogs_provider.dart';
import 'package:airstream/common/repository/settings_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:airstream/common/providers/subsonic_provider.dart';
import 'package:airstream/temp_password_holder.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:mutex/mutex.dart';
import 'package:xml/xml.dart';
import 'package:meta/meta.dart';

class ServerRepository {
  ServerRepository({
    SubsonicProvider provider,
    DiscogsProvider discogs,
    SettingsRepository settings,
  })  : _provider = provider ?? _initProvider(),
        _discogs = discogs ?? _initDiscogs(),
        _settings = getIt<SettingsRepository>(settings);

  final SubsonicProvider _provider;
  final DiscogsProvider _discogs;
  //ignore: unused_field
  final SettingsRepository _settings;

  /// Returns true if the upload request was accepted by the server.
  Future<bool> upload(String request) async {
    final either = await _provider.fetch(request);
    // Errors mean the server didn't receive the request.
    return either.fold((_) => false, (_) => true);
  }

  /// Returns a list of XmlElements found in a subsonic starred fetch.
  ///
  /// [element] dictates the XmlElements returned.
  Future<Either<String, List<XmlElement>>> starred(String element) async {
    return (await _provider.fetch('getStarred2?')).map(_extract(element));
  }

  /// Returns a list of album XmlElements given a album list [type].
  ///
  /// [specifics] can be used to add extra Subsonic API modifiers. Go to
  /// [SubsonicAPI](http://www.subsonic.org/pages/api.jsp#getAlbumList2) for
  /// possible specifics.
  Future<Either<String, List<XmlElement>>> albumList({
    @required String type,
    String specifics,
  }) async {
    final buffer = StringBuffer('getAlbumList2?type=$type');
    if (specifics != null) buffer.write('&$specifics');
    return (await _provider.fetch(buffer.toString())).map(_extract('album'));
  }

  /// Returns all artist XmlElements.
  Future<Either<String, List<XmlElement>>> artistList() async {
    return (await _provider.fetch('getArtists?')).map(_extract('artist'));
  }

  /// Returns [count] artists similar to a given artist [id].
  Future<Either<String, List<XmlElement>>> similarArtists(
    int id, {
    int count = 10,
  }) async {
    return (await _provider.fetch('getArtistInfo2?id=$id&count=$count'))
        .map(_extract('similarArtist'));
  }

  /// Returns all playlists as XmlElements.
  Future<Either<String, List<XmlElement>>> allPlaylists() async {
    return (await _provider.fetch('getPlaylists')).map(_extract('playlist'));
  }

  /// Returns a playlist as a XmlDocument.
  ///
  /// This is due to how playlist songs are stored as 'entry' elements.
  Future<Either<String, XmlDocument>> playlist(int id) {
    return _provider.fetch('getPlaylist?id=$id');
  }

  /// Returns songs within a playlist as XmlElements.
  Future<Either<String, List<XmlElement>>> playlistSongs(int id) async {
    return (await _provider.fetch('getPlaylist?id=$id')).map(_extract('entry'));
  }

  /// Returns song XmlElements within a given album [id].
  Future<Either<String, List<XmlElement>>> albumSongs(int id) async {
    return (await _provider.fetch('getAlbum?id=$id')).map(_extract('song'));
  }

  /// Returns [count] song XmlElements given an [artistName].
  ///
  /// The [artistName] shouldn't contain any spaces and be formatted to be
  /// url friendly.
  Future<Either<String, List<XmlElement>>> topSongs(
    String artistName, {
    int count = 5,
  }) async {
    return (await _provider
            .fetch('getTopSongs?artist=$artistName&count=$count'))
        .map(_extract('song'));
  }

  /// Return [count] song XmlElements given a search [query].
  Future<Either<String, List<XmlElement>>> search(
    String query, {
    int count = 10,
  }) async {
    return (await _provider.fetch(
      'search3?query=$query&'
      'artistCount=0&'
      'albumCount=0&'
      'songCount=$count',
    ))
        .map(_extract('song'));
  }

  /// Streams bytes from a file download.
  ///
  /// Pipes a given request in the [controller].
  /// Returns the file size.
  Future<Either<String, int>> stream(
    String request,
    StreamController<List<int>> controller,
  ) =>
      _provider.stream(request, controller);

  /// Returns an image from the subsonic API as a list of bytes.
  Future<Either<String, Uint8List>> image(String id, int resolution) {
    return _provider.image('getCoverArt?id=$id&size=$resolution');
  }

  /// Returns an image from discogs given an [artistName].
  Future<Either<String, Uint8List>> discogsImage(String artistName) {
    return _discogs.image(artistName);
  }
}

/// Initialises a [SubsonicProvider] instance with required parameters.
SubsonicProvider _initProvider() {
  final salt = _randomString();
  final bytes = utf8.encode(TempPasswordHolder.password + salt);
  final token = md5.convert(bytes).toString();
  return SubsonicProvider(
    httpClient: http.Client(),
    user: TempPasswordHolder.user,
    server: TempPasswordHolder.server,
    token: token,
    salt: salt,
  );
}

DiscogsProvider _initDiscogs() {
  return DiscogsProvider(locker: Mutex(), client: http.Client());
}

/// Generates random string.
///
/// Currently used to generate the 'salt' parameter in the construction of an url.
String _randomString({int length = 6}) {
  const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  final buffer = StringBuffer();
  for (var i = 0; i < length; i++) {
    buffer.write([random.nextInt(characters.length)]);
  }
  return buffer.toString();
}

/// Extracts the given [element] from a [document].
List<XmlElement> Function(XmlDocument) _extract(String element) =>
    (XmlDocument document) => document.findAllElements(element).toList();
