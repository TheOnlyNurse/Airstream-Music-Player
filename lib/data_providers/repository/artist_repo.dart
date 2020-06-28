import 'package:airstream/barrel/repository_subdivision_tools.dart';
import 'package:airstream/data_providers/artist_provider.dart';

class ArtistRepository {
  final _provider = ArtistProvider();

  Future<ProviderResponse> library({bool force = false}) async {
    final response = await _provider.library(force);
    return response;
  }

  Future<ProviderResponse> query({String query}) => _provider.query(name: query);
}