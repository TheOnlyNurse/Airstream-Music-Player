part of repository_library;

class _ArtistRepository {
  final ArtistsDao _dao;

  const _ArtistRepository({@required ArtistsDao dao})
      : _dao = dao,
        assert(dao != null);

  Future<ArtistResponse> byAlphabet() => _dao.byAlphabet();

  Future<ArtistResponse> search({String query}) => _dao.search(query);

  Future<ArtistResponse> update() => _dao.updateLibrary();

  Future<ArtistResponse> byId(int id) => _dao.byId(id);

  Future<ArtistResponse> similar(Artist artist) => _dao.similar(artist);
}
