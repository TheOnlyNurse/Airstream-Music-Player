import 'package:equatable/equatable.dart';
import 'package:xml/xml.dart' as xml;

class Artist extends Equatable {
	final int id;
  final String name;
  final int albumCount;
  final String art;

  const Artist({this.id, this.name, this.albumCount, this.art});

  @override
  List<Object> get props => [id, name];

  @override
  String toString() => 'Artist { id: $id }';

  factory Artist.fromServer(xml.XmlElement element) => Artist(
        id: element.getAttribute('id') != null
            ? int.parse(element.getAttribute('id'))
            : null,
        name: element.getAttribute('name'),
        albumCount: element.getAttribute('albumCount') != null
            ? int.parse(element.getAttribute('albumCount'))
            : null,
        art: element.getAttribute('coverArt'),
      );

  factory Artist.fromSQL(Map<String, dynamic> json) => Artist(
        id: json['id'],
        name: json['name'],
        albumCount: json['albumCount'],
        art: json['art'],
      );

  Map<String, dynamic> toSQL() => {
        'id': id,
        'name': name,
        'albumCount': albumCount,
        'art': art,
      };
}
