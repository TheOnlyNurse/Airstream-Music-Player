import 'package:airstream/data_providers/moor_database.dart';
import 'provider_response.dart';

class StarredResponse extends ProviderResponse {
  final bool _hasData;
  final String _error;
  final ProviderResponse _passOn;
  final List<int> idList;

  const StarredResponse({
    bool hasData = false,
    String error,
    ProviderResponse passOn,
    this.idList,
  })

  /// If hasData defaults to false then passOn or error cannot equal both be null
  : _hasData = hasData,
        _error = error,
        _passOn = passOn,
        assert(
            !hasData ? passOn == null ? error != null : passOn != null : true);

  @override
  String get errorString => _passOn?.errorString ?? _error;

  @override
	String get source => _passOn?.source ?? 'Starred';

  @override
  bool get hasData => _passOn?.hasData ?? _hasData;
}
