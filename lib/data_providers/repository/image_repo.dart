import 'package:airstream/barrel/repository_subdivision_tools.dart';
import 'package:airstream/data_providers/image_cache_provider.dart';
import 'package:airstream/data_providers/song_provider.dart';

class ImageRepository {
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