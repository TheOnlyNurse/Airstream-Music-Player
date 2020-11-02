part of repository_library;

class _StarredRepository {
  final _provider = StarredProvider();

  Future<StarredResponse> update() => _provider.update();

  Future<StarredResponse> query(String key) => _provider.query(key);
}
