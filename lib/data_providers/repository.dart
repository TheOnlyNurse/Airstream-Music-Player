import 'dart:async';
import 'dart:io';
import 'package:airstream/data_providers/album_provider.dart';
import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/data_providers/image_cache_provider.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/data_providers/song_provider.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/models/percentage_model.dart';
import 'package:airstream/models/song_model.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as XML;
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
    bool isMultiRequest = false,
  }) async {
    List<dynamic> data = await database.getLibraryList();

    if (data.isEmpty) {
      if (isMultiRequest) {
        final size = 500;
        int offset = 0;
        bool hasChildren;
        List<XML.XmlDocument> docList = [];

        do {
          final response =
              await _server.fetchRequest('$request&size=$size&offset=$offset&');
          if (response == null) break;
          docList.add(response);
          hasChildren = response.firstChild.children.length > 0 ? true : false;
          offset += size;
        } while (hasChildren);

        data = await database.updateWithDocList(docList);
      } else {
        final response = await _server.fetchRequest(request);
        data = await database.updateWithDoc(response);
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

  Future<RepoResponse> getImage(artId, {hiDef = false}) async {
    // Construct URLs based on input constraints.
    String url = hiDef
        ? _server.constructUrl('getCoverArt?id=$artId&size=512&')
        : _server.constructUrl('getCoverArt?id=$artId&size=256&');
    // Check for cached image
    String cachedImage = await _imageCache.urlQuery(url);

    if (cachedImage.isEmpty) {
      final response = await _server.downloadFile(url);
      // If the server has timed out it will return null which shouldn't be added to DB
      if (response != null) {
        cachedImage = await _imageCache.cacheUrl(url, response.bodyBytes);
      } else {
        return RepoResponse(
          status: DataStatus.error,
        );
      }
    }

    return RepoResponse(status: DataStatus.ok, data: File(cachedImage));
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

  final SongProvider _songProvider = SongProvider();

  /// Get songs in a given album
  ///
  /// To ensure that an alphabetically sorted list is sent, the online document is processed
  /// put into the database then queried from the database in alphabetical order.
  Future<RepoResponse> getAlbumSongs(Album album) async {
    List<Song> songList = await _songProvider.getSongsFromAlbumId(album.id);
    if (songList != null) {
      if (songList.length != album.songCount) {
        final xmlDoc = await _server.fetchRequest('getAlbum?id=${album.id}&');
        await _songProvider.updateWithDoc(xmlDoc, isStarred: false);
        songList = await _songProvider.getSongsFromAlbumId(album.id);
      }
    }
    if (songList == null) {
      return RepoResponse(
        status: DataStatus.error,
      );
    } else {
      return RepoResponse(status: DataStatus.ok, data: songList);
    }
  }

  /// Audio Repo

  StreamSubscription _downloadSS;
  IOSink _tempSongSink;
  final StreamController<PercentageModel> _percentageSC = StreamController();
  final _assetsAudioPlayer = AssetsAudioPlayer.withId('airstream');

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
      await _songProvider.cacheSong(song, tempFile.path);
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
		final songPath = await _songProvider.getSongLocation(song);
		if (songPath != null) {
			final audio = Audio.file(songPath, metas: song.toMetas());
			try {
				await _assetsAudioPlayer.open(
					audio,
					showNotification: true,
				);
				final artResp = await this.getImage(song.coverArt);
				audio.updateMetas(
					player: _assetsAudioPlayer,
					image:
					artResp.status == DataStatus.ok ? MetasImage.file(artResp.data.path) : null,
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
