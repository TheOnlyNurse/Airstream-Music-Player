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

  factory Playlist.fromSQL(Map<String, dynamic> json) {
    List<int> _decodeListFromString(String initialString) {
      final withoutBrackets = initialString.substring(1, initialString.length - 1);
      if (withoutBrackets.length == 0) return [];
      if (!withoutBrackets.contains(',')) return [int.parse(withoutBrackets)];
      final stringList = withoutBrackets.split(', ');
      return stringList.map((e) => int.parse(e)).toList();
    }

    return Playlist(
      id: json['id'],
      name: json['name'],
      comment: json['comment'],
      date: json['date'],
      songIds: _decodeListFromString(json['songIds']),
    );
  }

	Map<String, dynamic> toSQL() =>
			{
				'id': id,
				'name': name,
				'comment': comment,
				'date': date,
				'songIds': songIds.toString(),
			};
}
