import 'provider_response.dart';

class AudioCacheResponse extends ProviderResponse {
  final bool _hasData;
  final String _error;
  final ProviderResponse _passOn;
  final List<int> idList;
  final String path;

  const AudioCacheResponse({
    bool hasData = false,
    String error,
    ProviderResponse passOn,
    this.idList,
    this.path,
  })

  /// If hasData defaults to false then passOn or error cannot equal both be null
  : _hasData = hasData,
        _error = error,
        _passOn = passOn,
        assert(
            !hasData ? passOn == null ? error != null : passOn != null : true);

  @override
	String get messageString => _passOn?.messageString ?? _error;

	@override
	String get source => _passOn?.source ?? 'Audio Cache';

	@override
	bool get hasData => _passOn?.hasData ?? _hasData;
}
