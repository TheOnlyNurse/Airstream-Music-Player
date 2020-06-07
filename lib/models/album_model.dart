import 'package:equatable/equatable.dart';

class Album extends Equatable {
  final String id;
  final String name;
  final String artistName;
  final String artistId;
  final int songCount;
  final String coverArt;

  Album({
    this.id,
    this.name,
    this.artistName,
    this.artistId,
    this.songCount,
    this.coverArt,
  });

  @override
  List<Object> get props => [id, name, artistName];

  factory Album.fromJSON(Map<String, dynamic> json) => Album(
        id: json['id'],
        name: json['name'],
        artistName: json['artistName'],
        artistId: json['artistId'],
        songCount: json['songCount'] as int,
        coverArt: json['coverArt'],
      );

  Map<String, dynamic> toJSON() => {
        'id': id,
        'name': name,
        'artistName': artistName,
        'artistId': artistId,
        'songCount': songCount,
        'coverArt': coverArt,
      };
}
