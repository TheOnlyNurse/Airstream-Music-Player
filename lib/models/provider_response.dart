import 'package:flutter/material.dart';

enum DataStatus { ok, error }

enum ProviderSource {
  artist,
  album,
  audioCache,
  audio,
  imageCache,
  playlist,
  server,
  song,
}

class ProviderResponse {
  final DataStatus status;
  final ProviderSource source;
  final String _message;
  final dynamic data;

  const ProviderResponse({@required this.status, this.source, String message, this.data})
      : _message = message ?? '',
        assert(status == DataStatus.error ? (source != null) && (message != null) : true),
        assert((status == DataStatus.ok) ? (data != null) : true);

  Widget get message => _messageWidget();

  Widget _messageWidget() {
    return SizedBox(
      height: 100,
      child: Column(
        children: <Widget>[
          Text('Error!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          Text('Source: $source'),
          Text('Issue: $_message'),
        ],
      ),
    );
  }

  String get messageString => _message;
}
