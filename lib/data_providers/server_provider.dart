import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  Future<http.Response> downloadFile(String request) async {
    final url = constructUrl(request);
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

  /// Fetch JSON files from the Airsonic server
  ///
  /// The response is a single monolithic 'subsonic-response' object. This function formats
  /// the data by only sending the 'body' of the json response. It returns null when the
  /// server fails generally or doesn't send data within 5 seconds.
  Future<Map<String, dynamic>> fetchJson(String request) async {
    final String url = constructUrl(request) + '&f=json';
    final response =
        await httpClient.get(url).timeout(Duration(seconds: 5), onTimeout: () => null);

    if (response != null) {
      final Map<String, dynamic> decodedResp =
          jsonDecode(response.body)['subsonic-response'];
      if (decodedResp['status'] != 'ok') {
        final error = decodedResp['error'];
        throw Exception('Server Provider. Url: $url\n'
            'Code: ${error['code']}\n'
            'Message: ${error['message']}');
      }
      final key = decodedResp.keys.toList()[2];
      return decodedResp[key];
    }
    // XML cannot be passed as parse as it breaks functionality
    return null;
  }
}
