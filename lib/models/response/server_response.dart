import 'dart:typed_data';
import 'package:xml/xml.dart' as xml;
import 'provider_response.dart';

class ServerResponse extends ProviderResponse {
  final bool _hasData;
  final String _error;
  final ProviderResponse _passOn;
  final xml.XmlDocument document;
  final Uint8List bytes;
  final int contentSize;

  const ServerResponse({
    bool hasData = false,
    String error,
    ProviderResponse passOn,
    this.document,
    this.bytes,
    this.contentSize,
  })

  /// If hasData defaults to false then passOn or error cannot equal both be null
  : _hasData = hasData,
        _error = error,
        _passOn = passOn,
        assert(
          !hasData ? passOn == null ? error != null : passOn != null : true,
        );

  @override
  String get errorString => _passOn?.errorString ?? _error;

  @override
	String get source => _passOn?.source ?? 'Network';

	@override
	bool get hasData => _passOn?.hasData ?? _hasData;
}
