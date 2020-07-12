part of repository_library;

class _ImageFilesRepository {
  final ImageFilesDao dao;

  _ImageFilesRepository({@required this.dao}) : assert(dao != null);

  int grabCount = 0;

  Future<Null> deleteAll() => dao.deleteAll();

  Future<File> thumbnail(String artId) {
    grabCount++;
    return dao.byType(ImageType.thumbnail, artId: artId);
  }

  Future<File> original(String artId) async {
    final response = await dao.byType(ImageType.original, artId: artId);
    return response != null ? response : thumbnail(artId);
  }

  Future<File> fromSong(int songId, {bool isThumbnail = false}) async {
    final response = await Repository().song.byId(songId);
    if (response.hasNoData) return null;
    final art = response.song.art;
    return isThumbnail ? thumbnail(art) : original(art);
  }

  Future<File> fromArtist(Artist artist) async {
    final response = await dao.byType(
      ImageType.artist,
      artId: artist.art,
      name: artist.name,
    );
    return response != null ? response : original(artist.art);
  }

  Future<List<File>> collage(List<int> songIds) async {
    final images = <File>[];
    for (var id in songIds) {
      final response = await fromSong(id, isThumbnail: true);
      if (response != null) images.add(response);
    }
    if (images.isEmpty) return null;
    return images;
  }
}
