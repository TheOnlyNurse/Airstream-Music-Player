/// External Packages
import 'package:hive/hive.dart';
import 'package:xml/xml.dart';

/// Internal Links
import '../providers/server_provider.dart';
import '../models/response/starred_response.dart';


class StarredProvider {
  /// Holds starred song, album and artist ids
  final _hiveBox = Hive.box('cache');

  Future<StarredResponse> query(String key) async {
    List<int> result = _hiveBox.get(_uniqueKey(key));
    if (result == null) {
      await _download();
      result = _hiveBox.get(_uniqueKey(key));
    }
    if (result.isEmpty) {
      return StarredResponse(error: 'Failed to find any starred of key: $key.');
    } else {
      return StarredResponse(hasData: true, idList: result);
    }
  }

  /// Updates the starred id list from server and returns true once complete
  Future<StarredResponse> update() async {
    await _download();
    return StarredResponse(hasData: true);
  }

  String _uniqueKey(String key) => 'st@r-$key';

  /// Attempts to populate the hive box by downloading server starred
  Future<void> _download() async {
    final response = await ServerProvider().fetchXml('getStarred2?');
    if (response.hasNoData) return;
    _parseDocument(response.document, 'song');
    return;
  }

  /// Takes elements of a given string (key) in an xml document and places
  /// them into the hive box
  Future<void> _parseDocument(XmlDocument document, String key) async {
    final elements = document.findAllElements(key);
    final idList = <int>[];
    for (var element in elements) {
      idList.add(int.parse(element.getAttribute('id')));
    }
    _hiveBox.put(_uniqueKey(key), idList);
    return;
  }
}
