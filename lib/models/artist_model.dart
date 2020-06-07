import 'package:equatable/equatable.dart';

class Artist extends Equatable {
  final String id;
  final String title;
  final int albumCount;
  final String coverArt;

  Artist({this.id, this.title, this.albumCount, this.coverArt});

  @override
  List<Object> get props => [id, title];

  @override
  String toString() => 'Artist { id: $id }';

  factory Artist.fromJSON(Map<String, dynamic> json) => Artist(
        id: json['id'],
        title: json['name'],
        albumCount: json['albumCount'],
        coverArt: json['coverArt'],
      );

  Map<String, dynamic> toJSON() => {
        'id': id,
        'name': title,
        'albumCount': albumCount,
        'coverArt': coverArt,
      };
}
