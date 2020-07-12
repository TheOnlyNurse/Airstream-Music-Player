import 'package:airstream/data_providers/moor_database.dart';
import 'provider_response.dart';

class AlbumResponse extends ProviderResponse {
	final bool _hasData;
  final String _error;
  final ProviderResponse _passOn;
  final List<Album> albums;
  final List<String> genres;
  final List<int> decades;

  const AlbumResponse({
    bool hasData = false,
    String error,
    ProviderResponse passOn,
    this.albums,
    this.genres,
    this.decades,
  })

  /// If hasData defaults to false then passOn or error cannot equal both be null
  : _hasData = hasData,
        _error = error,
        _passOn = passOn,
        assert(
            !hasData ? passOn == null ? error != null : passOn != null : true);

  Album get album => albums.first;

  @override
  String get errorString => _passOn?.errorString ?? _error;

  @override
  String get source => _passOn?.source ?? 'Albums';

  @override
  bool get hasData => _passOn?.hasData ?? _hasData;
}
