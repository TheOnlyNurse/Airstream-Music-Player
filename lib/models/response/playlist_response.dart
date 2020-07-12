import 'package:airstream/models/playlist_model.dart';
import 'provider_response.dart';

class PlaylistResponse extends ProviderResponse {
  final bool _hasData;
  final String _error;
  final ProviderResponse _passOn;
  final List<Playlist> playlists;
  final Playlist playlist;

  const PlaylistResponse({
    bool hasData = false,
    String error,
    ProviderResponse passOn,
    this.playlists,
    this.playlist,
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
	String get source => _passOn?.source ?? 'Playlists';

	@override
	bool get hasData => _passOn?.hasData ?? _hasData;
}
