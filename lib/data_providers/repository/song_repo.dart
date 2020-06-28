import 'dart:collection';
import 'package:airstream/barrel/repository_subdivision_tools.dart';
import 'package:airstream/data_providers/song_provider.dart';

class SongRepository {
  /// Private
  final StreamController<SongChange> _onChange = StreamController.broadcast();
  final _provider = SongProvider();

  /// Global Variables
  Stream<SongChange> get changed => _onChange.stream;

  /// Functions
  Future<ProviderResponse> starred({bool force = false}) async {
    if (force)
      return _provider.forceUpdateStarred();
    else
      return _provider.getStarred();
  }

  /// Get songs in a given album
  Future<ProviderResponse> listFromAlbum(Album album) => _provider.query(
        albumId: album.id,
        searchLimit: album.songCount,
      );

  Future<ProviderResponse> listFromPlaylist(Playlist playlist) async {
    final songList = <Song>[];
    ProviderResponse lastError;

    for (int id in playlist.songIds) {
      final list = await _provider.query(id: id, searchLimit: 1);
      if (list.status == DataStatus.ok) {
        assert(list.data is List<Song>);
        songList.add(list.data.first);
      } else {
        lastError = list;
      }
    }

    if (songList.isNotEmpty) {
			return ProviderResponse(status: DataStatus.ok, data: songList);
		} else if (lastError != null) {
			return lastError;
		} else {
			return ProviderResponse(
				status: DataStatus.error,
				source: ProviderSource.repository,
				message: 'no songs found in playlist',
			);
		}
	}

	Future<ProviderResponse> query({String query}) async {
		final songs = await _provider.query(title: query, searchLimit: 5);

		switch (songs.status) {
			case DataStatus.ok:
				if (songs.data.length < 5) {
					final artists = await _provider.query(artist: query, searchLimit: 5);

					switch (artists.status) {
						case DataStatus.ok:
							songs.data.addAll(artists.data);
							// Remove any duplicate data points & keep list order
							final combinedData = LinkedHashSet<Song>.from(songs.data).toList();
							return ProviderResponse(status: DataStatus.ok, data: combinedData);
							break;
						case DataStatus.error:
							return songs;
							break;
					}
				} else {
					return songs;
				}
				break;
			case DataStatus.error:
				final artists = await _provider.query(artist: query, searchLimit: 5);
				return artists;
				break;
		}

		throw UnimplementedError();
	}

	void star({@required List<Song> songList, bool toStar = false}) async {
		await _provider.changeStars(songList, toStar);
		if (toStar)
			_onChange.add(SongChange.starred);
		else
			_onChange.add(SongChange.unstarred);
	}
}