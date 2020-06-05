import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:airstream/temp_password_holder.dart';

class ServerProvider {
  // TODO: Data needs to be stored locally
  final String user = TempPasswordHolder.user;
  final String password = TempPasswordHolder.password;
  final String client = TempPasswordHolder.client;
  final String server = TempPasswordHolder.server;
  final http.Client httpClient;

  ServerProvider({@required this.httpClient});

  void errorMessage(url, error, stacktrace) {
    print('Server_Provider (Fetch) $error\nURL: $url\n$stacktrace');
  }

  String constructUrl(String request) {
    final String urlStart = 'https://$server/rest/';
    final String urlEnd = 'u=$user&p=$password&v=1.15.0&c=$client';
    return urlStart + request + urlEnd;
  }

  Future<http.Response> downloadFile(String url) async {
    try {
      final response = await httpClient.get(url).timeout(
            Duration(seconds: 5),
            onTimeout: () => null,
          );
      return response;
    } catch (error, stacktrace) {
      errorMessage(url, error, stacktrace);
      return null;
    }
  }

  Future<int> streamFile(String request, StreamController<List<int>> controller) async {
    final url = constructUrl(request);
    try {
      final response = await httpClient.send(http.Request('GET', Uri.parse(url)));
      response.stream.pipe(controller);
      return response.contentLength;
    } catch (error, stacktrace) {
      errorMessage(url, error, stacktrace);
      return null;
    }
  }

  // ignore: missing_return
  Future<xml.XmlDocument> fetchRequest(String request) async {
    final String url = constructUrl(request);
    try {
      final response = await httpClient.get(url).timeout(
            Duration(seconds: 5),
            onTimeout: () => null,
          );
      if (response != null) {
        final doc = xml.parse(response.body);
        final apiResponse = doc.findAllElements('subsonic-response').first;
        if (apiResponse.getAttribute('status') != 'ok') {
          final error = apiResponse.findAllElements('error').first;
          throw Exception('Tried fetching: $url\n'
              'Got response: ${error.getAttribute('code')}\n'
              'Message: ${error.getAttribute('message')}');
        }
        return doc;
      }
      // XML cannot be passed as parse as it breaks functionality
      return null;
    } catch (error, stacktrace) {
      errorMessage(url, error, stacktrace);
    }
  }
}
