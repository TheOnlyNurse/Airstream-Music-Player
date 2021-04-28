import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:moor/moor.dart';
import 'package:dartz/dartz.dart';
import 'package:xml/xml.dart';
import 'package:airstream/common/extensions/functional_http.dart';

/// Name used to identify the app to the server.
const clientName = 'Airstream';

class SubsonicProvider {
  SubsonicProvider({
    @required String user,
    @required String server,
    @required String token,
    @required String salt,
    @required http.Client httpClient,
  })  : _user = user,
        _server = server,
        _token = token,
        _salt = salt,
        _httpClient = httpClient;

  final String _user;
  final String _server;
  final String _token;
  final String _salt;
  final http.Client _httpClient;

  /// Fetches a given subsonic request.
  ///
  /// Returns null when an invalid response is received.
  Future<Either<String, XmlDocument>> fetch(String request) async {
    final url = Uri.parse(_constructUrl(request));
    final response = _httpClient.get(url).timeout(const Duration(seconds: 2));
    try {
      return (await response).resolveStatus().flatMap(_extractError);
    } catch (error) {
      return left(error.toString());
    }
  }

  /// Fetches an image.
  ///
  /// Returns null when an invalid response is received.
  Future<Either<String, Uint8List>> image(String request) async {
    final url = Uri.parse(_constructUrl(request));
    final response = _httpClient.get(url).timeout(const Duration(seconds: 2));
    try {
      final result = await response;
      return result.statusCode != 200
          ? left('Status Code: ${result.statusCode}')
          : right(result.bodyBytes);
    } catch (error) {
      return left(error.toString());
    }
  }

  /// Streams bytes from a file download.
  ///
  /// Pipes a given request in the [controller].
  /// Returns the file size.
  Future<Either<String, int>> stream(
    String request,
    StreamController<List<int>> controller,
  ) async {
    try {
      final uri = Uri.parse(_constructUrl(request));
      final response = await _httpClient.send(http.Request('GET', uri));
      response.stream.pipe(controller);
      return right(response.contentLength);
    } catch (e) {
      return left(e.toString());
    }
  }

  /// Constructs the url required for a fetch request
  String _constructUrl(String request) {
    final urlStart = 'https://$_server/rest/';
    final urlEnd = '&u=$_user&t=$_token&s=$_salt&v=1.15.0&c=$clientName';
    return urlStart + request + urlEnd;
  }
}

/// Returns the error code within a subsonic xml response or null.
Either<String, XmlDocument> _extractError(http.Response response) {
  print('Extracting response: ${response.statusCode}');
  final document = XmlDocument.parse(response.body);
  print('Response: ${document.children}');
  final status = document
      .findAllElements('subsonic-response')
      .first
      .getAttribute('status');
  if (status != 'ok') {
    final error = document.findAllElements('error');
    return left(error.first.getAttribute('message'));
  } else {
    return right(document);
  }
}

