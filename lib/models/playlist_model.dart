import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:xml/xml.dart' as xml;

class Playlist extends Equatable {
  final int id;
  final String name;
  final String comment;
  final String date;
  final List<int> songIds;

  const Playlist({this.id, this.name, this.comment, this.date, this.songIds});

  @override
  List<Object> get props => [id, name, songIds];

  factory Playlist.fromServer(xml.XmlDocument doc) {
    final songIds =
    doc.findAllElements('entry').map((e) => int.parse(e.getAttribute('id'))).toList();
    final element = doc.findAllElements('playlist').first;
    return Playlist(
      id: int.parse(element.getAttribute('id')),
      name: element.getAttribute('name'),
      comment: element.getAttribute('comment'),
      date: element.getAttribute('created'),
      songIds: songIds,
    );
  }

  factory Playlist.fromSQL(Map<String, dynamic> column) => Playlist(
        id: column['id'],
        name: column['name'],
        comment: column['comment'],
        date: column['date'],
        songIds: jsonDecode(column['songIds']).cast<int>(),
      );

  Map<String, dynamic> toSQL() => {
        'id': id,
        'name': name,
        'comment': comment,
        'date': date,
        'songIds': jsonEncode(songIds),
      };
}
