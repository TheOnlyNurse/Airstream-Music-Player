part of repository_library;

class _AudioCacheRepository {
  const _AudioCacheRepository({@required this.dao}) : assert(dao != null);
  final AudioFilesDao dao;

  Future<AudioCacheResponse> cachedAlbums() => dao.cachedIds('albums');

  Future<AudioCacheResponse> cachedSongs() => dao.cachedIds('songs');

  Future<AudioCacheResponse> pathOf(Song song) => dao.pathOf(song.id);

  Future<Null> deleteSong(Song song) => dao.deleteSong(song.id);

  Future<AudioCacheResponse> cache(File audioFile, Song song) {
    return dao.cache(audioFile, song);
  }

  Future<Null> deleteAll() => dao.deleteAll();
}
