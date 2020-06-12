import 'dart:async';
import 'dart:io';
import 'package:airstream/data_providers/album_provider.dart';
import 'package:airstream/data_providers/artist_provider.dart';
import 'package:airstream/data_providers/audio_provider.dart';
import 'package:airstream/data_providers/image_cache_provider.dart';
import 'package:airstream/data_providers/playlist_provider.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/data_providers/song_provider.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/models/percentage_model.dart';
import 'package:airstream/models/song_model.dart';
import 'package:assets_audio_player/assets_audio_player.dart' as assets;
import 'package:flutter/material.dart';

/// The Repository collects data from providers and formats it for ease of access and use
/// in UI and Bloc generation.

class Repository {
  static final Repository _instance = Repository._internal();

  Repository._internal() {
    print("Repository initialised.");
  }

  factory Repository() {
    return _instance;
  }

  /// 1. Global Variables

  /// 2. Global Functions

  /// Retrieve a library list given a particular database
  ///
  /// Downloading and updating databases is handled by each provider in question.
  Future<RepoResponse> getLibrary(Library libraryType) async {
    List<dynamic> data;

    switch (libraryType) {
      case Library.playlists:
        data = await PlaylistProvider().getLibraryList();
        break;
      case Library.artists:
        data = await ArtistProvider().getLibraryList();
        break;
      case Library.albums:
        data = await AlbumProvider().getLibraryList();
        break;
      case Library.songs:
        data = await PlaylistProvider().getStarred(StarredType.songs);
        break;
      default:
        throw Exception('Invalid database to get library for: $libraryType');
    }

    if (data == null)
      return RepoResponse(status: DataStatus.error);
    else
      return RepoResponse(status: DataStatus.ok, data: data);
  }

  /// Image Repo

  Future<RepoResponse> getImage({String artId, int songId, hiDef = false}) async {
    if (songId != null) {
      final song = (await SongProvider().querySongs(id: songId, searchLimit: 1)).first;
      artId = song.art;
    }
    final imageLocation = await ImageCacheProvider().getCoverArt(artId, hiDef);

    if (imageLocation == null) return RepoResponse(status: DataStatus.error);

    return RepoResponse(status: DataStatus.ok, data: File(imageLocation));
  }

  Future<RepoResponse> search(String query, Library libraryType) async {
    List<dynamic> list = [];
    switch (libraryType) {
      case Library.artists:
        list = await ArtistProvider().queryArtist(name: query);
        break;
      case Library.songs:
        list = await SongProvider().querySongs(title: query, artist: query);
        break;
      default:
        throw UnimplementedError();
    }

    if (list.isEmpty)
      return RepoResponse(status: DataStatus.error);
    else
      return RepoResponse(status: DataStatus.ok, data: list);
  }

  /// Album Repo

  Future<RepoResponse> getArtistAlbums(Artist artist) async {
    List<Album> albumList = await AlbumProvider().getAlbumList(artistId: artist.id);
    if (albumList == null) {
      return RepoResponse(
        status: DataStatus.error,
      );
    } else {
      return RepoResponse(status: DataStatus.ok, data: albumList);
    }
  }

  /// Song Repo

  /// Get songs in a given album
  ///
  /// The songlist retrieved is checked for missing tracks against the album song count,
  /// fetching from the server when deficient.
  Future<RepoResponse> getAlbumSongs(Album album) async {
    List<Song> songList = await SongProvider().querySongs(albumId: album.id);
    if (songList.length != album.songCount) {
      final xmlDoc = await ServerProvider().fetchXML('getAlbum?id=${album.id}&');
      songList = await SongProvider().updateWithXml(xmlDoc);
      songList.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    if (songList == null)
      return RepoResponse(status: DataStatus.error);
    else
      return RepoResponse(status: DataStatus.ok, data: songList);
  }

  Future<RepoResponse> getSongsById(List<int> songIds) async {
    var songList = <Song>[];
    for (var id in songIds) {
      final list = await SongProvider().querySongs(id: id, searchLimit: 1);
      if (list.isNotEmpty) songList.add(list.first);
    }
    if (songList.length != songIds.length) {
      final idsToFetch = songIds;
      for (var song in songList) {
        idsToFetch.remove(song.id);
      }
      for (var id in idsToFetch) {
        final xmlDoc = await ServerProvider().fetchXML('getSong?id=$id&');
        if (xmlDoc != null) {
          final list = await SongProvider().updateWithXml(xmlDoc);
          songList.add(list.first);
        }
      }
    }
    if (songList.isEmpty)
      return RepoResponse(status: DataStatus.error);
    else
      return RepoResponse(status: DataStatus.ok, data: songList);
  }

  /// Audio Repo

  Stream<PercentageModel> get percentageStream => AudioProvider().percentageSC.stream;

  List<Song> get songQueue => AudioProvider().songQueue;

  int get currentIndex => AudioProvider().currentSongIndex;

  Song get currentSong => AudioProvider().currentSong;

  int get playlistLength => AudioProvider().songQueue.length;

  assets.AssetsAudioPlayer get audioPlayer => AudioProvider().audioPlayer;

  void skipToNext() => AudioProvider().skipTo(1);

  void skipToPrevious() => AudioProvider().skipTo(-1);

  void playPlaylist(List<Song> playlist, {int index = 0}) =>
      AudioProvider().createQueueAndPlay(
        playlist,
        index,
      );
}

enum Library {
	playlists,
	artists,
	albums,
	songs,
}

enum DataStatus {
	ok,
	error,
}

class RepoResponse {
	final DataStatus status;
	final data;

	const RepoResponse({@required this.status, this.data});
}
