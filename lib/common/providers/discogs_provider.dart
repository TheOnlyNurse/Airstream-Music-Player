import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:mutex/mutex.dart';

const _key = 'jQAdutNleiRcSyAKdvdU';
const _secret = 'ZbUjUUiQiGUxDSOHmNusBWrLSGbAKMsz';

class DiscogsProvider {
  const DiscogsProvider({@required Mutex locker, @required http.Client client})
      : assert(locker != null),
        assert(client != null),
        _locker = locker,
        _client = client;

  final Mutex _locker;
  final http.Client _client;

  /// Fetches a custom artist image from the discogs api
  Future<Either<String, Uint8List>> image(String name) async {
    final query = name.toLowerCase().replaceAll(' ', '+');
    final imageUrl = (await _search(query)).bind<String>(_decodeResponse);
    return imageUrl.fold((error) => left(error), (url) => _fetch(Uri.parse(url)));
  }

  /// Fetch a JSON response given a [query] from the discogs database
  Future<Either<String, http.Response>> _search(String query) async {
    final url = Uri.parse('https://api.discogs.com/database/search?'
        'q=$query'
        '&key=$_key&secret=$_secret'
        '&type=artist'
        '&page=1&per_page=1');

    await _locker.acquire();
    final response = _client.get(url).timeout(const Duration(seconds: 2));

    try {
      final result = await response;
      if (result.statusCode != 200) {
        throw HttpException('Status Code: ${result.statusCode}');
      }
      return right(result);
    } catch (e) {
      return left(e.toString());
    } finally {
      await Future.delayed(const Duration(seconds: 1));
      _locker.release();
    }
  }

  /// Fetches an image given an [url].
  Future<Either<String, Uint8List>> _fetch(Uri url) async {
    final response = _client.get(url).timeout(const Duration(seconds: 2));
    try {
      final result = await response;
      if (result.statusCode != 200) {
        throw HttpException('Status Code: ${result.statusCode}');
      }
      return right(result.bodyBytes);
    } catch (e) {
      return left(e.toString());
    }
  }
}

/// Returns whether
Either<String, String> _decodeResponse(http.Response response) {
  final json = jsonDecode(response.body);
  final results = json['results'] as List<dynamic>;
  return results.isEmpty
      ? left('No images found.')
      : right(results.first['cover_image'] as String);
}
