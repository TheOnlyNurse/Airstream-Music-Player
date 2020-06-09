import 'package:equatable/equatable.dart';

class Album extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String artistId;
  final int songCount;
  final String coverArt;

  const Album({
    this.id,
    this.title,
    this.artist,
    this.artistId,
    this.songCount,
    this.coverArt,
  });

  @override
	List<Object> get props => [id, title, artist];

	factory Album.fromJSON(Map<String, dynamic> json) =>
			Album(
				id: json['id'],
				title: json['name'],
				artist: json['artist'],
				artistId: json['artistId'],
				songCount: json['songCount'] as int,
				coverArt: json['coverArt'],
			);

	Map<String, dynamic> toJSON() =>
			{
				'id': id,
				'name': title,
				'artist': artist,
				'artistId': artistId,
				'songCount': songCount,
				'coverArt': coverArt,
			};
}
