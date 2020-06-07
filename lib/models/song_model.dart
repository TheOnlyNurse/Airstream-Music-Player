import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final String id;
  final String title;
  final String album;
  final String artist;
  final String coverArt;
  final String albumId;
  final String artistId;

  Song({
    this.id,
    this.title,
    this.album,
    this.artist,
    this.coverArt,
    this.albumId,
    this.artistId,
  });

  @override
  List<Object> get props => [id, title, artist];

  @override
  String toString() => 'Song { title: $title, artist: $artist }';

  factory Song.fromJSON(Map<String, dynamic> json) => Song(
        id: json['id'],
        title: json['title'],
        album: json['album'],
        artist: json['artist'],
        coverArt: json['coverArt'],
        albumId: json['albumId'],
        artistId: json['artistId'],
      );

  Map<String, dynamic> toJSONAsStarred({bool isStarred = false}) => {
        'id': id,
        'title': title,
        'album': album,
        'artist': artist,
        'coverArt': coverArt,
        'albumId': albumId,
        'artistId': artistId,
        'starred': isStarred ? 1 : 0,
      };

  Metas toMetas() => Metas(
        title: title,
        artist: artist,
        album: album,
      );
}
