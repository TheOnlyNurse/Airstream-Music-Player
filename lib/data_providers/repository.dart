import 'dart:async';
import 'dart:io';
import 'package:airstream/data_providers/album_provider.dart';
import 'package:airstream/data_providers/artist_provider.dart';
import 'package:airstream/data_providers/audio_provider.dart';
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
  final _server = ServerProvider();
  final _albumProvider = AlbumProvider();
  final _imageCache = ImageCacheProvider();

  /// 2. Global Functions

  /// Updates databases and servers data
  ///
  /// Calls a server fetch request and passes the XML Document to the database
  /// (see DatabaseProvider.updateWithDocList for more information). If the
  /// fetch is null, the database will also return null, at which point an error is sent
  /// by this function.
  /// If the request is an albums request it requires server calls. The responses are
  /// collected in a list and passed to the database (see DatabaseProvider.updateWithDocList).
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

				data = await database.updateWithJsonList(jsonList);
      } else {
				final response = await _server.fetchJson(request);
				if (response != null) data = await database.updateWithJson(response);
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

	Future<RepoResponse> queryByNameOrTitle(String query, DataProviders provider) async {
		List<dynamic> list = [];
		switch (provider) {
			case DataProviders.album:
			// TODO: Handle this case.
				break;
			case DataProviders.artist:
				list = await ArtistProvider().queryArtistByName(query);
				break;
			case DataProviders.song:
				list = await SongProvider().querySongsByTitle(query);
				break;
		}

		if (list.isEmpty)
			return RepoResponse(status: DataStatus.error);
		else
			return RepoResponse(status: DataStatus.ok, data: list);
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
			songList = await _songProvider.updateWithJson(json, isStarred: false);
			songList.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
		}
		if (songList == null)
			return RepoResponse(status: DataStatus.error);
		else
			return RepoResponse(status: DataStatus.ok, data: songList);
	}

	Future<RepoResponse> getSongsById(List<String> songIds) async {
		var songList = await _songProvider.getSongsByIds(songIds);
		if (songList.length != songIds.length) {
			final idsToFetch = songIds;
			for (var song in songList) {
				idsToFetch.remove(song.id);
			}
			for (var id in idsToFetch) {
				final json = await _server.fetchJson('getSong?id=$id&');
				songList.add(await _songProvider.addSongFromJson(json));
			}
		}
		if (songList.isEmpty)
			return RepoResponse(status: DataStatus.error);
		else
			return RepoResponse(status: DataStatus.ok, data: songList);
	}

	/// Playlist Repo

	final _playlistProvider = PlaylistProvider();

	Future<RepoResponse> getPlaylists() async {
		List<Playlist> playListArray = await _playlistProvider.getLibraryList();
		if (playListArray == null) {
			final json = await _server.fetchJson('getPlaylists?');
			if (json != null) {
				playListArray = [];
				final idList = json['playlist'].map((element) => element['id']);
				_playlistProvider.clearDbForUpdate();
				for (var id in idList) {
					final jsonResp = await _server.fetchJson('getPlaylist?id=$id&');
					playListArray.add(await _playlistProvider.updateWithJson(jsonResp));
				}
			}
		}
		if (playListArray == null)
			return RepoResponse(status: DataStatus.error);
		else
			return RepoResponse(status: DataStatus.ok, data: playListArray);
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

enum DataProviders {
	album,
	artist,
	song,
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