import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:hive/hive.dart';
import 'package:xml/xml.dart';

/// Internal
import '../models/playlist_model.dart';

class PlaylistProvider {
  const PlaylistProvider({@required Box<Playlist> hive})
      : assert(hive != null),
        _hive = hive;

  /// Hive box used as to store and retrieve [Playlist] objects.
  final Box<Playlist> _hive;

  /// ========== QUERIES ==========

  /// Returns all playlists in alphabetical order.
  List<Playlist> byAlphabet() {
    final unsorted = _hive.values?.toList() ?? [];
    return unsorted..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Returns a playlist by it's name.
  Option<Playlist> byName(String name) {
    final result = _hive.values.firstWhere(
      (playlist) => playlist.name == name,
      orElse: () => null,
    );
    return result == null ? none() : some(result);
  }

  /// ========== DB MANAGEMENT ==========

  /// Decode a playlist xml document and insert as a [Playlist] into the database.
  void insertDocument(XmlDocument document) {
    final songIds = document
        .findAllElements('entry')
        .map((e) => int.parse(e.getAttribute('id')))
        .toList();

    final element = document.findAllElements('playlist').first;

    final playlist = Playlist(
      id: int.parse(element.getAttribute('id')),
      name: element.getAttribute('name'),
      comment: element.getAttribute('comment'),
      songIds: songIds,
    );
    _hive.put(playlist.id, playlist);
  }

  /// Clears the database of all playlists.
  Future<void> clear() => _hive.clear();

  /// Removes the song ids in the given indexes from a playlist.
  Future<void> removeSongs(int id, List<int> removeIndexes) {
    final playlist = _hive.get(id);
    for (final index in removeIndexes) {
      playlist.songIds.removeAt(index);
    }
    return _hive.put(id, playlist);
  }

  /// Adds songs to an existing playlist.
  Future<void> addSongs(int id, List<int> songIdList) {
    final playlist = _hive.get(id);
    playlist.songIds.addAll(songIdList);
    return _hive.put(id, playlist);
  }

  /// Replace a comment on a playlist.
  Future<void> changeComment(int id, String comment) async {
    final playlist = _hive.get(id).copyWith(comment: comment);
    return _hive.put(id, playlist);
  }
}
