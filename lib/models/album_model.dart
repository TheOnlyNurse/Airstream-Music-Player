import 'package:equatable/equatable.dart';
import 'package:xml/xml.dart' as xml;

class Album extends Equatable {
	final int id;
  final String title;
  final String artist;
  final int artistId;
  final int songCount;
  final String art;

  const Album({
    this.id,
    this.title,
    this.artist,
    this.artistId,
    this.songCount,
    this.art,
  });

  @override
  List<Object> get props => [id, title, artist];

  factory Album.fromServer(xml.XmlElement element) => Album(
        id: int.parse(element.getAttribute('id')),
        title: element.getAttribute('name'),
        artist: element.getAttribute('artist'),
        artistId: int.parse(element.getAttribute('artistId')),
        songCount: int.parse(element.getAttribute('artistId')),
        art: element.getAttribute('coverArt'),
      );

  factory Album.fromSQL(Map<String, dynamic> json) => Album(
        id: json['id'],
        title: json['title'],
        artist: json['artist'],
        artistId: json['artistId'],
        songCount: json['songCount'],
        art: json['art'],
      );

  Map<String, dynamic> toSQL() => {
        'id': id,
        'title': title,
        'artist': artist,
        'artistId': artistId,
        'songCount': songCount,
        'art': art,
      };
}
