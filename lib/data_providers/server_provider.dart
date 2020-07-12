import 'dart:convert';
import 'dart:math';
import 'package:airstream/barrel/provider_basics.dart';
import 'package:airstream/data_providers/repository/repository.dart';
import 'package:airstream/models/response/server_response.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:airstream/temp_password_holder.dart';

class ServerProvider {
  /// Private Variables
  final http.Client _httpClient = http.Client();
  final _streamLocker = Mutex();
  final _fetchLocker = Mutex();
  final _discogsLocker = Mutex();
  String _serverToken;
  String _serverSalt;

  /// Global Functions
  ///
  /// Pipes a given request in a StreamController
  /// Returns the file size.
  /// Multiple requests whilst a stream is already active will result in null responses until
  /// that particular stream has completed/been cancelled.
  Future<ServerResponse> streamFile(
    String request,
    StreamController<List<int>> controller,
  ) async {
    if (Repository().settings.isOffline) {
      return ServerResponse(error: 'App is offline');
    }

    await _streamLocker.acquire();
    final url = _constructUrl(request);
    try {
      final response =
          await _httpClient.send(http.Request('GET', Uri.parse(url)));
      response.stream.pipe(controller);
      return ServerResponse(hasData: true, contentSize: response.contentLength);
    } catch (e) {
      print('streaming error: $e');
      return ServerResponse(error: 'Failed to reach server');
    } finally {
      _streamLocker.release();
    }
  }

  /// Fetches by a given request from the Airsonic server
  /// Different fetch types confer different amounts of processing.
  /// XmlDocs which aren't greeted with an 'ok' status are returned as null.
  /// Awaits until all push (upload) requests are finished before issuing a pull.
  Future<ServerResponse> fetchXml(String request) async {
    // Wait for any scheduled jobs to complete first before fetching anything
    // If jobs still exist, don't fetch anything
    if (await Scheduler().hasJobs) {
      return ServerResponse(error: 'Scheduler has jobs, unable to fetch.');
    }

    final response = await _fetch(_constructUrl(request));

    if (response != null) {
      final xmlDoc = xml.parse(response.body);
      final status = xmlDoc
          .findAllElements('subsonic-response')
          .first
          .getAttribute('status');
      if (status != 'ok') {
        final error = xmlDoc.findAllElements('error').first;
        print('Server Provider. Url: ${response.request.url}\n'
            'Code: ${error.getAttribute('code')}\n'
            'Message: ${error.getAttribute('message')}');
        return ServerResponse(error: error.getAttribute('message'));
      }
      return ServerResponse(hasData: true, document: xmlDoc);
    }

    return ServerResponse(error: 'Failed to fetch request: $request');
  }

  /// Fetches an image from the airsonic server
  Future<ServerResponse> fetchImage(String request) async {
    final response = await _fetch(_constructUrl(request));
    if (response == null) return ServerResponse(error: 'Failed to fetch');
    return ServerResponse(hasData: true, bytes: response.bodyBytes);
  }

  /// Fetches a custom artist image from the discogs api
  Future<ServerResponse> fetchArtistImage(String name) async {
    final query = name.toLowerCase().replaceAll(' ', '+');
    final response = await _fetchDiscogs(query);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final imageUrl = json['results'].first['cover_image'];
      final discogsImage = await _httpClient.get(imageUrl);
      if (discogsImage.statusCode == 200) {
        return ServerResponse(hasData: true, bytes: discogsImage.bodyBytes);
      } else {
        return ServerResponse(error: ('Failed to fetch image'));
      }
    } else {
      print(response.body);
      return ServerResponse(error: ('Failed to fetch artist information'));
    }
  }

  /// Sends an push request to server
  /// An 'ok' response is treated as completion.
  /// Specific error codes can also be treated as completion.
  Future<bool> upload(String request) async {
    final response = await _fetch(_constructUrl(request));
    if (response != null) {
      final xmlDoc = xml.parse(response.body);
      final status = xmlDoc
          .findAllElements('subsonic-response')
          .first
          .getAttribute('status');
      if (status == 'ok') {
        return true;
      } else {
        final errorCode = int.parse(
            xmlDoc.findAllElements('error').first.getAttribute('code'));
        // "The requested data was not found."
        if (errorCode == 70) return true;
        // "User is not authorized for the given operation."
        if (errorCode == 50) return true;
        return false;
      }
    } else {
      return false;
    }
  }

  /// Private Functions
  ///
  /// Constructs the url required for a fetch request
  String _constructUrl(String request) {
    final String user = TempPasswordHolder.user;
    final String password = TempPasswordHolder.password;
    final String client = TempPasswordHolder.client;
    final String server = TempPasswordHolder.server;

    if (_serverToken == null) {
      _serverSalt = _randomString(6);
      _serverToken =
          md5.convert(utf8.encode(password + _serverSalt)).toString();
    }
    final String urlStart = 'https://$server/rest/';
    final String urlEnd =
        '&u=$user&t=$_serverToken&s=$_serverSalt&v=1.15.0&c=$client';
    return urlStart + request + urlEnd;
  }

  /// Low level fetch
  /// Returns null when an invalid response is received.
  /// Denies all requests (with null) when the user setting 'isOffline' is true.
  Future<http.Response> _fetch(String url) async {
    if (Repository().settings.isOffline) return null;

    await _fetchLocker.acquire();
    try {
      final response = await _httpClient.get(url).timeout(
            Duration(seconds: 2),
            onTimeout: () => null,
          );
      _fetchLocker.release();
      return response;
    } catch (error) {
      print('Can\'t reach server: $error');
      return null;
    }
  }

  /// Fetch a JSON response given a query from the discogs database
  Future<http.Response> _fetchDiscogs(String query) async {
    if (Repository().settings.isOffline) return null;

    final key = 'jQAdutNleiRcSyAKdvdU';
    final secret = 'ZbUjUUiQiGUxDSOHmNusBWrLSGbAKMsz';
    final url = 'https://api.discogs.com/database/search?'
        'q=$query'
        '&key=$key&secret=$secret'
        '&type=artist'
        '&page=1&per_page=1';
    await _discogsLocker.acquire();
    try {
      final response = await _httpClient.get(url).timeout(
            Duration(seconds: 2),
            onTimeout: () => null,
          );
      await Future.delayed(Duration(seconds: 1));
      _discogsLocker.release();
      return response;
    } catch (e) {
      print('Failed to reach discogs.');
      return null;
    }
  }

  /// Generates random string
  /// Currently used to generate the 'salt' parameter in the construction of an url.
  String _randomString(int stringLength) {
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    Random rnd = Random(DateTime.now().millisecondsSinceEpoch);
    String result = "";
    for (var i = 0; i < stringLength; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }
    return result;
  }

  /// Singleton boilerplate
  static final ServerProvider _instance = ServerProvider._internal();

  ServerProvider._internal();

  factory ServerProvider() => _instance;
}
