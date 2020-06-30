part of repository_library;

class _ImageFilesRepository {
  final ImageFilesDao dao;

  const _ImageFilesRepository({@required this.dao}) : assert(dao != null);

  Future<Null> deleteAll() => dao.deleteAll();

  Future<File> lowDef(String artId) => dao.byType(artId, ImageType.lowDef);

  Future<File> highDef(String artId) => dao.byType(artId, ImageType.hiDef);

  Future<File> fromSongId(int songId, {bool isHiDef = false}) async {
    final response = await Repository().song.byId(songId);
    if (response.hasNoData) return null;
    final art = response.songList.first.art;
    return isHiDef ? highDef(art) : lowDef(art);
  }

  Future<List<File>> collage(List<int> songIds) async {
    final imageList = <File>[];
    for (var id in songIds) {
      final response = await fromSongId(id);
      if (response != null) imageList.add(response);
    }
    if (imageList.isEmpty) return null;
    return imageList;
  }
}
