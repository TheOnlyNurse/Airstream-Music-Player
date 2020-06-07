import 'dart:async';
import 'dart:io';
import 'package:airstream/data_providers/album_provider.dart';
import 'package:airstream/data_providers/audio_cache_provider.dart';
import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/data_providers/image_cache_provider.dart';
import 'package:airstream/data_providers/playlist_provider.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/data_providers/song_provider.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/models/percentage_model.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/models/song_model.dart';
import 'package:assets_audio_player/assets_audio_player.dart' as assets;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Naming Conventions
/// SS => StreamSubscription
/// SC => StreamController

enum DataStatus {
  ok,
  error,
}

class RepoResponse {
  final DataStatus status;
  final data;

  const RepoResponse({@required this.status, this.data});
}

class Repository {
  // To ensure that only one instance of repository and subsequent classes are used
  static final Repository _instance = Repository._internal();

  Repository._internal() {
    print("Repository initialised.");
  }

  factory Repository() {
    return _instance;
  }

  /// 1. Global Variables
  final _server = ServerProvider(httpClient: http.Client());
  final _albumProvider = AlbumProvider();
  final _imageCache = ImageCacheProvider();

  /// 2. Global Functions

  /// Updates databases and servers data
  ///
  /// Calls a server fetch request and passes the XML Document to the database
  /// (see DatabaseProvider.updateWithDocList for more information). If the
  /// fetch is null, the database will also return null, at which point an error is sent
  /// by this function.
  /// If the request requires multiple server calls. The responses are collected in a
  /// list and passed to the database (see DatabaseProvider.updateWithDocList).
  Future<RepoResponse> fetchCategory({
    @required String request,
    @required DatabaseProvider database,
    bool isAlbumRequest = false,
  }) async {
    List<dynamic> data = await database.getLibraryList();

    if (data.isEmpty) {
      if (isAlbumRequest) {
        final size = 500;
        int offset = 0;
        bool hasChildren = true;
        List<Map<String, dynamic>> jsonList = [];

        do {
          final response = await _server.fetchJson('$request&size=$size&offset=$offset&');
          if (response == null) break;
          if (response.isEmpty) {
            hasChildren = false;
          } else {
            jsonList.add(response);
            offset += size;
          }
        } while (hasChildren);

        data = await database.updateWithDocList(jsonList);
      } else {
        final response = await _server.fetchJson(request);
        if (response != null) data = await database.updateWithDoc(response);
      }
    }

    if (data == null) {
      return RepoResponse(status: DataStatus.error);
    } else {
      return RepoResponse(
        status: DataStatus.ok,
        data: data,
      );
    }
  }

  /// Image Repo

  /// Check cache for image and download if absent.
  ///
  /// The max image resolution has been chosen to be 512 pixels because of cache size
  /// constraints and little appreciable benefit of higher resolutions.
  Future<RepoResponse> getImage(artId, {hiDef = false}) async {
    // Check for cached image
    String imageLocation = await _imageCache.getCoverArt(artId);

    if (imageLocation == null) {
      String url =
          hiDef ? 'getCoverArt?id=$artId&size=512&' : 'getCoverArt?id=$artId&size=256&';
      final response = await _server.downloadFile(url);
      // If the server has timed out it will return null which shouldn't be added to DB
      if (response != null) {
        imageLocation = await _imageCache.cacheImage(url, response.bodyBytes);
      } else {
        return RepoResponse(
          status: DataStatus.error,
        );
      }
    }

    return RepoResponse(status: DataStatus.ok, data: File(imageLocation));
  }

  /// Album Repo

  Future<RepoResponse> getArtistAlbums(Artist artist) async {
    List<Album> albumList = await _albumProvider.getAlbumFromArtistId(artist.id);
    if (albumList == null) {
      return RepoResponse(
        status: DataStatus.error,
      );
    } else {
      return RepoResponse(status: DataStatus.ok, data: albumList);
    }
  }

  /// Song Repo

  final _songProvider = SongProvider();

  /// Get songs in a given album
  ///
  /// The songlist retrieved is checked for missing tracks against the album song count,
  /// fetching from the server when deficient.
  Future<RepoResponse> getAlbumSongs(Album album) async {
    List<Song> songList = await _songProvider.getSongsFromAlbumId(album.id);
    if (songList.length != album.songCount) {
      final json = await _server.fetchJson('getAlbum?id=${album.id}&');
      songList = await _songProvider.updateWithDoc(json, isStarred: false);
      songList.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    if (songList == null)
      return RepoResponse(status: DataStatus.error);
    else
      return RepoResponse(status: DataStatus.ok, data: songList);
  }

  /// Playlist Repo

  final _playlistProvider = PlaylistProvider();

  Future<RepoResponse> getPlaylists() async {
    List<Playlist> list = await _playlistProvider.getLibraryList();
    if (list == null) {

    }
    if (list == null)
      return RepoResponse(status: DataStatus.error);
    else
      return RepoResponse(status: DataStatus.ok, data: list);
  }

  /// Audio Repo

  StreamSubscription _downloadSS;
  IOSink _tempSongSink;
  final StreamController<PercentageModel> _percentageSC = StreamController();
  final _assetsAudioPlayer = assets.AssetsAudioPlayer.withId('airstream');
  final _audioCacheProvider = AudioCacheProvider();

  Stream<PercentageModel> get percentageStream => _percentageSC.stream;
  final List<Song> songQueue = <Song>[];
  int currentSongIndex = 0;

  Song get currentSong => songQueue[currentSongIndex];

  /// Download Song, place into cache and prompt play
  ///
  ///
  void downloadSong({@required Song song, bool isNotPrefetch = true}) async {
    final tempFile = File(p.join((await getTemporaryDirectory()).path, 'song_file'));
    if (tempFile.existsSync()) tempFile.deleteSync();
    _tempSongSink = tempFile.openWrite(mode: FileMode.append);

    final StreamController<List<int>> fileBytesSC = StreamController();
    final totalFileSize = await _server.streamFile('stream?id=${song.id}&', fileBytesSC);
    int currentFileSize = 0;

    _downloadSS = fileBytesSC.stream.listen((bytes) {
      _tempSongSink.add(bytes);
      if (isNotPrefetch) {
        currentFileSize += bytes.length;
        _percentageSC.add(PercentageModel(
          current: currentFileSize,
          total: totalFileSize,
        ));
      }
    });
    _downloadSS.onDone(() async {
      _tempSongSink.close();
      _downloadSS.cancel();
      _downloadSS = null;
      await _audioCacheProvider.cacheFile(
        tempFile,
        songId: song.id,
        artistName: song.artist,
        albumId: song.albumId,
      );
      this.playSong();
    });
  }

  createQueueAndPlay({@required List<Song> playlist, int index = 0}) {
    this.songQueue.clear();
    this.songQueue.addAll(playlist);
    currentSongIndex = index;
    this.playSong();
  }

  Future<void> playSong() async {
    // Cancel any existing downloads in favour of the new song
    if (_downloadSS != null) _downloadSS.cancel();

    final song = this.currentSong;
    final songPath = await _audioCacheProvider.getSongLocation(song.id);
    if (songPath != null) {
      final audio = assets.Audio.file(songPath, metas: song.toMetas());
      try {
        await _assetsAudioPlayer.open(
          audio,
          showNotification: true,
        );
        final artResp = await this.getImage(song.coverArt);
        audio.updateMetas(
          player: _assetsAudioPlayer,
          image:
          artResp.status == DataStatus.ok
              ? assets.MetasImage.file(artResp.data.path)
              : null,
        );
      } catch (_) {
        File(songPath).deleteSync();
        downloadSong(song: song);
      }
    } else {
      _assetsAudioPlayer.pause();
      downloadSong(song: song);
    }
  }
}
