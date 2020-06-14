import 'dart:async';
import 'dart:io';
import 'package:airstream/data_providers/album_provider.dart';
import 'package:airstream/data_providers/artist_provider.dart';
import 'package:airstream/data_providers/audio_provider.dart';
import 'package:airstream/data_providers/image_cache_provider.dart';
import 'package:airstream/data_providers/playlist_provider.dart';
import 'package:airstream/data_providers/scheduler.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:airstream/data_providers/song_provider.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/models/percentage_model.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:airstream/models/song_model.dart';
import 'package:assets_audio_player/assets_audio_player.dart' as assets;
import 'package:flutter/material.dart';

/// The Repository collects data from providers and formats it for ease of access and use
/// in UI and Bloc generation.

class Repository {
  /// Global Variables
  _AudioRepo get audio => _AudioRepo();

  _SongRepo get song => _SongRepo();

  _PlaylistRepo get playlist => _PlaylistRepo();

  _AlbumRepo get album => _AlbumRepo();

  _ArtistRepo get artist => _ArtistRepo();

  _SettingsRepo get settings => _SettingsRepo();

  _ImageRepo get image => _ImageRepo();

  /// Singleton boilerplate code
  static final Repository _instance = Repository._internal();

  Repository._internal();

  factory Repository() {
    return _instance;
  }
}

class RepoSettingsContainer {
  final int prefetch;
  final bool isOffline;
  final int imageCacheSize;
  final int musicCacheSize;

  RepoSettingsContainer(
      {this.prefetch, this.isOffline, this.imageCacheSize, this.musicCacheSize});
}

class _AudioRepo {
  Stream<PercentageModel> get percentageStream => AudioProvider().percentageSC.stream;

  int get index => AudioProvider().currentSongIndex;

  Song get current => AudioProvider().currentSong;

  int get playlistLength => AudioProvider().songQueue.length;

  assets.AssetsAudioPlayer get audioPlayer => AudioProvider().audioPlayer;

  void skipToNext() => AudioProvider().skipTo(1);

  void skipToPrevious() => AudioProvider().skipTo(-1);

  void play({@required List<Song> playlist, int index = 0}) =>
      AudioProvider().createQueueAndPlay(playlist, index);
}

class _SongRepo {
  Future<ProviderResponse> starred() => SongProvider().getStarred();

  /// Get songs in a given album
  Future<ProviderResponse> listFromAlbum(Album album) => SongProvider().query(
        albumId: album.id,
        searchLimit: album.songCount,
      );

  Future<ProviderResponse> listFromPlaylist(Playlist playlist) async {
    final songList = <Song>[];
    ProviderResponse lastError;

    for (int id in playlist.songIds) {
      final list = await SongProvider().query(id: id, searchLimit: 1);
      if (list.status == DataStatus.ok) {
        assert(list.data is List<Song>);
        songList.add(list.data.first);
      } else {
        lastError = list;
      }
    }

    if (songList.isEmpty) {
      return lastError;
    } else {
      return ProviderResponse(status: DataStatus.ok, data: songList);
    }
  }

  Future<ProviderResponse> query({String query}) async {
    final songs = await SongProvider().query(title: query, searchLimit: 5);
    final artists = await SongProvider().query(artist: query, searchLimit: 5);

    switch (songs.status) {
      case DataStatus.ok:
        switch (artists.status) {
          case DataStatus.ok:
            songs.data.addAll(artists.data);
            return songs;
            break;
          case DataStatus.error:
            return songs;
            break;
        }
        break;
      case DataStatus.error:
        switch (artists.status) {
          case DataStatus.ok:
            return artists;
            break;
          case DataStatus.error:
            return artists;
            break;
        }
        break;
    }
  }

  void star({@required List<Song> songList, bool toStar = false}) {
    for (var song in songList) {
      SongProvider().changeStar(song, toStar);
    }
  }

  Stream<bool> get changed => SongProvider().songsChanged.stream;
}

class _PlaylistRepo {
  void removeSongs(Playlist playlist, List<int> indexList) async {
    for (int index in indexList) {
      Scheduler().schedule(
        'updatePlaylist?playlistId=${playlist.id}&songIndexToRemove=$index',
      );
      await PlaylistProvider().removeSong(playlist.id, index);
    }
  }

  Future<ProviderResponse> library() => PlaylistProvider().library();

  Stream<PlaylistDatabase> get changed => PlaylistProvider().onChangeController.stream;
}

class _AlbumRepo {
  Future<ProviderResponse> library() => AlbumProvider().library();

  Future<ProviderResponse> query({String query}) =>
      AlbumProvider().query(
        title: query,
        searchLimit: 5,
      );

  Future<ProviderResponse> fromArtist(Artist artist) =>
      AlbumProvider().query(
        artistId: artist.id,
        searchLimit: artist.albumCount,
      );

  Future<ProviderResponse> fromSong(Song song) =>
      AlbumProvider().query(
        id: song.albumId,
        searchLimit: 1,
      );
}

class _ArtistRepo {
  Future<ProviderResponse> library() => ArtistProvider().library();

  Future<ProviderResponse> query({String query}) => ArtistProvider().query(name: query);
}

class _SettingsRepo {
  Future<RepoSettingsContainer> get() async {
    final provider = SettingsProvider();
    return RepoSettingsContainer(
      prefetch: await provider.prefetchValue,
      isOffline: await provider.isOffline,
      imageCacheSize: await provider.imageCacheSize,
      musicCacheSize: await provider.musicCacheSize,
    );
  }

  void set(SettingsChangedType type, dynamic value) =>
      SettingsProvider().setSetting(type, value);

  Stream<bool> get changed => SettingsProvider().isOfflineChanged.stream;
}

class _ImageRepo {

  Future<ProviderResponse> fromArt(String artId, {isHiDef = false}) async {
    final imageResponse = await ImageCacheProvider().query(artId, isHiDef);
    if (imageResponse.status == DataStatus.error && isHiDef) {
      return fromArt(artId);
    } else {
      return imageResponse;
    }
  }

  Future<ProviderResponse> fromSongId(int songId) async {
    final songResponse = await SongProvider().query(id: songId, searchLimit: 1);
    if (songResponse.status == DataStatus.error) return songResponse;
    assert(songResponse.data is List<Song>);

    return fromArt(songResponse.data.first.art);
  }

  Future<ProviderResponse> collage(List<int> songIds) async {
    final imageList = <File>[];
    ProviderResponse lastError;

    for (int id in songIds) {
      final response = await fromSongId(id);
      if (response.status == DataStatus.ok) imageList.add(response.data);
      if (response.status == DataStatus.error) lastError = response;
    }

    if (imageList.isEmpty) {
      return lastError;
    } else {
      return ProviderResponse(status: DataStatus.ok, data: imageList);
    }
  }
}