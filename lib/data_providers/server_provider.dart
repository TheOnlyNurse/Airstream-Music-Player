import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/data_providers/scheduler.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:airstream/temp_password_holder.dart';

class ServerProvider {
  /// Private Variables
  final http.Client _httpClient = http.Client();
  bool _isStreaming = false;
  String _serverToken;
  String _serverSalt;

  /// Global Functions
  ///
  /// Pipes a given request in a StreamController
  /// Returns the file size.
  /// Multiple requests whilst a stream is already active will result in null responses until
  /// that particular stream has completed/been cancelled.
  /// TODO: Downloading should be down within this Provider and a file should be passed.
  Future<int> streamFile(String request, StreamController<List<int>> controller) async {
    if (await SettingsProvider().isOffline) return null;
    if (_isStreaming) return null;

    _isStreaming = true;
    final url = _constructUrl(request);
    final response = await _httpClient.send(http.Request('GET', Uri.parse(url)));
    response.stream.pipe(controller);
    _isStreaming = false;
    return response.contentLength;
  }

  /// Fetches by a given request from the Airsonic server
  /// Different fetch types confer different amounts of processing.
  /// XmlDocs which aren't greeted with an 'ok' status are returned as null.
  /// Awaits until all push (upload) requests are finished before issuing a pull.
  Future<ProviderResponse> fetchRequest(String request, FetchType type) async {
    // Wait for any scheduled jobs to complete first before fetching anything
    final hasJobs = await Scheduler().hasJobs;
    // If jobs still exist, don't fetch anything
    if (hasJobs) return null;

    final response = await _fetch(_constructUrl(request));

    if (response != null) {
      switch (type) {
        case FetchType.xmlDoc:
          final xmlDoc = xml.parse(response.body);
          final status =
              xmlDoc.findAllElements('subsonic-response').first.getAttribute('status');
          if (status != 'ok') {
            final error = xmlDoc.findAllElements('error').first;
            print('Server Provider. Url: ${response.request.url}\n'
                'Code: ${error.getAttribute('code')}\n'
                'Message: ${error.getAttribute('message')}');
            return ProviderResponse(
              status: DataStatus.error,
              source: ProviderSource.server,
              message: error.getAttribute('message'),
            );
          }
          return ProviderResponse(status: DataStatus.ok, data: xmlDoc);
          break;
        case FetchType.bytes:
          return ProviderResponse(status: DataStatus.ok, data: response.bodyBytes);
          break;
      }
    }
    return ProviderResponse(
      status: DataStatus.error,
      source: ProviderSource.server,
      message: 'couldn\'t fetch request: $request',
    );
  }

  /// Sends an push request to server
  /// An 'ok' response is treated as completion.
  /// Specific error codes can also be treated as completion.
  Future<bool> upload(String request) async {
    final response = await _fetch(_constructUrl(request));
    print(request);
    if (response != null) {
      final xmlDoc = xml.parse(response.body);
      final status =
          xmlDoc.findAllElements('subsonic-response').first.getAttribute('status');
      if (status == 'ok') {
        return true;
      } else {
        final errorCode =
            int.parse(xmlDoc.findAllElements('error').first.getAttribute('code'));
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
      _serverToken = md5.convert(utf8.encode(password + _serverSalt)).toString();
    }
    final String urlStart = 'https://$server/rest/';
    final String urlEnd = '&u=$user&t=$_serverToken&s=$_serverSalt&v=1.15.0&c=$client';
    return urlStart + request + urlEnd;
  }

  /// Low level fetch
  /// Returns null when an invalid response is received.
  /// Denies all requests (with null) when the user setting 'isOffline' is true.
  Future<http.Response> _fetch(String url) async {
    if (await SettingsProvider().isOffline) return null;

    http.Response response;
    try {
      response = await http.get(url).timeout(Duration(seconds: 5), onTimeout: null);
      return response;
    } catch (error) {
      print('Can\'t reach server: $error');
      return null;
    }
  }

  /// Generates random string
  /// Currently used to generate the 'salt' parameter in the construction of an url.
  String _randomString(int stringLength) {
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    Random rnd = Random(DateTime
        .now()
        .millisecondsSinceEpoch);
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

enum FetchType { xmlDoc, bytes }
