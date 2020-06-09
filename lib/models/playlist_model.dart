import 'package:equatable/equatable.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final String comment;
  final String date;
  final List<String> songList;

  const Playlist({this.id, this.name, this.comment, this.date, this.songList});

  @override
  List<Object> get props => [id, name];

  factory Playlist.fromDatabase(Map<String, dynamic> json) {
    List<String> _decodeListFromString(String initialString) {
      final withoutBrackets = initialString.substring(1, initialString.length - 1);
      if (withoutBrackets.length == 0) return [];
      if (!withoutBrackets.contains(',')) return [withoutBrackets];
      return withoutBrackets.split(', ');
    }

    return Playlist(
      id: json['id'],
      name: json['name'],
      comment: json['comment'],
      date: json['date'],
      songList: _decodeListFromString(json['songList']),
    );
  }

  factory Playlist.fromServer(Map<String, dynamic> json) {
    final List<String> songList = [];
    if (json['entry'] != null) json['entry'].forEach((e) => songList.add(e['id']));
    return Playlist(
      id: json['id'],
      name: json['name'],
      comment: json['comment'],
      date: json['created'],
      songList: songList,
    );
  }

  Map<String, dynamic> toDatabase() => {
        'id': id,
        'name': name,
        'comment': comment,
        'date': date,
        'songList': songList.toString(),
      };
}
