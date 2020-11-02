import 'package:airstream/providers/moor_database.dart';
import 'provider_response.dart';

class ArtistResponse extends ProviderResponse {
	final bool _hasData;
  final String _error;
  final ProviderResponse _passOn;
  final List<Artist> artists;

  const ArtistResponse({
    hasData = false,
    passOn,
    error,
    this.artists,
  })

  /// If hasData defaults to false then passOn or error cannot equal both be null
  : _hasData = hasData,
        _error = error,
        _passOn = passOn,
        assert(
            !hasData ? passOn == null ? error != null : passOn != null : true);

  Artist get artist => artists.first;

  @override
  String get errorString => _passOn?.errorString ?? _error;

  @override
  String get source => _passOn?.source ?? 'Artists';

  @override
  bool get hasData => _passOn?.hasData ?? _hasData;
}
