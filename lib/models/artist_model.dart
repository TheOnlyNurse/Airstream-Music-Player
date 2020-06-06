import 'package:airstream/models/airstream_base_model.dart';
import 'package:xml/xml.dart' as XML;

class Artist extends AirstreamBaseModel {
  final int id;
  final String name;
  final int albumCount;
  final String coverArt;

  Artist({this.id, this.name, this.albumCount, this.coverArt});

  @override
  List<Object> get props => [id, name];

  @override
  String toString() => 'Artist { id: $id }';

  factory Artist.fromXML(XML.XmlElement xml) => new Artist(
        id: int.parse(xml.getAttribute('id')),
        name: xml.getAttribute('name'),
        albumCount: int.parse(xml.getAttribute('albumCount')),
        coverArt: xml.getAttribute('coverArt'),
      );

  factory Artist.fromMap(Map<String, dynamic> json) => new Artist(
        id: json['id'],
        name: json['name'],
        albumCount: json['albumCount'],
        coverArt: json['coverArt'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'albumCount': albumCount,
        'coverArt': coverArt,
      };
}
