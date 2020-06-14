import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:equatable/equatable.dart';
import 'package:xml/xml.dart' as xml;

class Song extends Equatable {
  final int id;
  final String title;
  final String album;
  final String artist;
  final String art;
  final int albumId;
  final bool isStarred;

  const Song(
      {this.id,
      this.title,
      this.album,
      this.artist,
      this.art,
      this.albumId,
      this.isStarred});

  @override
  List<Object> get props => [id, title, artist];

  @override
  String toString() => 'Song { title: $title, artist: $artist, isStarred: $isStarred }';

  factory Song.fromServer(xml.XmlElement element, {isStarred = false}) => Song(
        id: int.parse(element.getAttribute('id')),
        title: element.getAttribute('title'),
        album: element.getAttribute('album'),
        artist: element.getAttribute('artist'),
        art: element.getAttribute('coverArt'),
        albumId: int.parse(element.getAttribute('albumId')),
        isStarred: isStarred,
      );

  factory Song.fromSQL(Map<String, dynamic> json) => Song(
		id: json['id'],
		title: json['title'],
		album: json['album'],
		artist: json['artist'],
		art: json['art'],
		albumId: json['albumId'],
		isStarred: json['isStarred'] == 1 ? true : false,
      );

	Map<String, dynamic> toSQL() =>
			{
				'id': id,
				'title': title,
				'album': album,
				'artist': artist,
				'art': art,
				'albumId': albumId,
				'isStarred': isStarred ? 1 : 0,
			};

	Metas toMetas() =>
			Metas(
				title: title,
				artist: artist,
				album: album,
			);
}
