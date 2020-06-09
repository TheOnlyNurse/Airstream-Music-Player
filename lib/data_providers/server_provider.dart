import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:airstream/temp_password_holder.dart';

class ServerProvider {
  final String user = TempPasswordHolder.user;
  final String password = TempPasswordHolder.password;
  final String client = TempPasswordHolder.client;
  final String server = TempPasswordHolder.server;
  final http.Client httpClient = http.Client();
  bool isStreaming = false;
  String _serverToken;
  String _serverSalt;

  static final ServerProvider _instance = ServerProvider._internal();

  ServerProvider._internal() {
    print("Server Provider started");
  }

  factory ServerProvider() {
    return _instance;
  }

  String _constructUrl(String request) {
    if (_serverToken == null) {
      _serverSalt = _randomString(6);
      _serverToken = md5.convert(utf8.encode(password + _serverSalt)).toString();
    }
    final String urlStart = 'https://$server/rest/';
    final String urlEnd = '&u=$user&t=$_serverToken&s=$_serverSalt&v=1.15.0&c=$client';
    return urlStart + request + urlEnd;
  }

  Future<http.Response> downloadFile(String request) async {
    final url = _constructUrl(request);
    final response = await httpClient.get(url).timeout(
          Duration(seconds: 5),
          onTimeout: () => null,
        );
    return response;
  }

  Future<int> streamFile(String request, StreamController<List<int>> controller) async {
		if (isStreaming)
			return null;
		isStreaming = true;
		final url = _constructUrl(request);
		final response = await httpClient.send(http.Request('GET', Uri.parse(url)));
		response.stream.pipe(controller);
		isStreaming = false;
		return response.contentLength;
	}

  /// Fetch JSON files from the Airsonic server
	///
	/// The response is a single monolithic 'subsonic-response' object. This function formats
	/// the data by only sending the 'body' of the json response. It returns null when the
	/// server fails generally or doesn't send data within 5 seconds.
	Future<Map<String, dynamic>> fetchJson(String request) async {
		final String url = _constructUrl(request) + '&f=json';
		final response =
		await httpClient.get(url).timeout(
				Duration(seconds: 5), onTimeout: () => throw Exception('Server timeout'));

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
		return null;
	}

	String _randomString(int stringLength) {
		const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
		Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
		String result = "";
		for (var i = 0; i < stringLength; i++) {
			result += chars[rnd.nextInt(chars.length)];
		}
		return result;
	}
}
