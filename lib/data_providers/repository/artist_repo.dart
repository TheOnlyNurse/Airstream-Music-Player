part of repository_library;

class _ArtistRepository {
  final ArtistsDao dao;

  const _ArtistRepository({this.dao});

  Future<ArtistResponse> byAlphabet() => dao.byAlphabet();

  Future<ArtistResponse> search({String query}) => dao.search(query);

  Future<ArtistResponse> update() => dao.updateLibrary();
}