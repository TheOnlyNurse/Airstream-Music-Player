import 'package:airstream/barrel/repository_subdivision_tools.dart';
import 'package:airstream/data_providers/album_provider.dart';

class AlbumRepository {
  final _provider = AlbumProvider();

  Future<ProviderResponse> library({bool force = false}) async {
    final response = await _provider.library(force);
    return response;
  }

  Future<ProviderResponse> search({String query}) => _provider.query(
        where: 'title LIKE ?',
        args: ['%$query%'],
        searchLimit: 5,
      );

  Future<ProviderResponse> fromArtist(Artist artist) => _provider.query(
        where: 'artistId = ?',
        args: [artist.id],
        searchLimit: artist.albumCount,
      );

  Future<ProviderResponse> fromSong(Song song) => _provider.query(
        where: 'id = ?',
        args: [song.albumId],
        searchLimit: 1,
      );

  Future<ProviderResponse> random(int limit) => _provider.collection(
        CollectionType.random,
        limit: limit ?? 100,
      );

  Future<ProviderResponse> recent(int limit) => _provider.collection(
        CollectionType.recent,
        limit: limit ?? 100,
      );

  Future<ProviderResponse> byAlphabet() => _provider.collection(CollectionType.alphabet);

  Future<ProviderResponse> allGenres() => _provider.collection(CollectionType.allGenres);

  Future<ProviderResponse> genre(String genre) => _provider.query(
        where: 'genre = ?',
        args: [genre],
      );

  Future<ProviderResponse> decadesList() => _provider.collection(
        CollectionType.allDecades,
      );

  Future<ProviderResponse> decade(int decade) async {
		final albums = <Album>[];

		for (int year = 0; year < 10; year++) {
			final ProviderResponse results = await _provider.query(
				where: 'year = ?',
				args: [decade + year],
			);
			if (results.status == DataStatus.ok) albums.addAll(results.data);
		}

		return ProviderResponse(status: DataStatus.ok, data: albums);
	}

	Future<ProviderResponse> mostPlayed() async => _provider.played('frequent');

	Future<ProviderResponse> recentlyPlayed() async => _provider.played('recent');
}