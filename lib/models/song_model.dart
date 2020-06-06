import 'package:airstream/models/airstream_base_model.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:xml/xml.dart' as XML;

class Song extends AirstreamBaseModel {
  final int id;
  final String name;
  final String albumName;
  final String artistName;
  final int duration;
  final String coverArt;
  final int albumId;
  final int artistId;

  Song({
    this.id,
    this.name,
    this.albumName,
    this.artistName,
    this.duration,
    this.coverArt,
    this.albumId,
    this.artistId,
  });

  @override
	List<Object> get props => [id, name, artistName];

	@override
	String toString() => 'Song { name: $name, artist: $artistName, artistId: $artistId }';

	factory Song.fromXML(XML.XmlElement xml) {
		int passNullOrParse(String element) => element != null ? int.parse(element) : null;

		return Song(
			id: int.parse(xml.getAttribute('id')),
			name: xml.getAttribute('title'),
			albumName: xml.getAttribute('album'),
			artistName: xml.getAttribute('artist'),
			duration: passNullOrParse(xml.getAttribute('duration')),
			coverArt: xml.getAttribute('coverArt'),
			albumId: passNullOrParse(xml.getAttribute('albumId')),
			artistId: passNullOrParse(xml.getAttribute('artistId')),
		);
	}

	factory Song.fromMap(Map<String, dynamic> json) => Song(
		id: json['id'],
		name: json['name'],
		albumName: json['albumName'],
		artistName: json['artistName'],
		duration: json['duration'],
		coverArt: json['coverArt'],
		albumId: json['albumId'],
		artistId: json['artistId'],
	);

	Map<String, dynamic> toMapAsStarred({bool isStarred = false}) => {
		'id': id,
		'name': name,
		'albumName': albumName,
		'artistName': artistName,
		'duration': duration,
		'coverArt': coverArt,
		'albumId': albumId,
		'artistId': artistId,
		'starred': isStarred ? 1 : 0,
	};

	Metas toMetas() => Metas(
		title: name,
		artist: artistName,
		album: albumName,
	);
}
