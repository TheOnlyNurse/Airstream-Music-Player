import 'package:equatable/equatable.dart';
import 'package:xml/xml.dart' as XML;

class Album extends Equatable {
  final int id;
  final String name;
  final String artistName;
  final int artistId;
  final int songCount;
  final String coverArt;

  const Album(
      {this.id,
      this.name,
      this.artistName,
      this.artistId,
      this.songCount,
      this.coverArt});

  @override
  List<Object> get props => [id, name, artistName];

  @override
  String toString() => 'Album { name: $name }';

  factory Album.fromXML(XML.XmlElement xml) => new Album(
        id: int.parse(xml.getAttribute('id')),
        name: xml.getAttribute('name'),
        artistName: xml.getAttribute('artist'),
        artistId: int.parse(xml.getAttribute('artistId')),
        songCount: int.parse(xml.getAttribute('songCount')),
        coverArt: xml.getAttribute('coverArt'),
      );

  factory Album.fromMap(Map<String, dynamic> json) => new Album(
        id: json['id'],
        name: json['name'],
        artistName: json['artistName'],
        artistId: json['artistId'],
        songCount: json['songCount'],
        coverArt: json['coverArt'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'artistName': artistName,
        'artistId': artistId,
        'songCount': songCount,
        'coverArt': coverArt,
      };
}
