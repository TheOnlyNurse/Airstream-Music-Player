part of repository_library;

class _AlbumRepository {
  const _AlbumRepository({@required this.dao}) : assert(dao != null);

  final AlbumsDao dao;

  Future<AlbumResponse> search({String request}) {
    return dao.library(AlbumLibrary.search, argument: request);
  }

  Future<AlbumResponse> update() => dao.updateLibrary();

  Future<AlbumResponse> fromArtist(Artist artist) {
    return dao.library(AlbumLibrary.byArtist, argument: artist.id);
  }

  Future<AlbumResponse> fromSong(Song song) => dao.byId(song.albumId);

  Future<AlbumResponse> random() => dao.library(AlbumLibrary.random);

  Future<AlbumResponse> newlyAdded() => dao.library(AlbumLibrary.newlyAdded);

  Future<AlbumResponse> byAlphabet() => dao.library(AlbumLibrary.byAlphabet);

  Future<AlbumResponse> allGenres() => dao.genres();

  Future<AlbumResponse> genre(String genre) async {
    return dao.library(AlbumLibrary.byGenre, argument: genre);
  }

  Future<AlbumResponse> decades() => dao.decades();

  Future<AlbumResponse> decade(int decade) {
    return dao.library(AlbumLibrary.byDecade, argument: decade);
  }

  Future<AlbumResponse> frequent() => dao.library(AlbumLibrary.frequent);

  Future<AlbumResponse> recent() async => dao.library(AlbumLibrary.recent);
}
