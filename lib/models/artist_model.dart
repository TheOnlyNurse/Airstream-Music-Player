import 'package:equatable/equatable.dart';

class Artist extends Equatable {
  final String id;
  final String name;
  final int albumCount;
  final String coverArt;

  const Artist({this.id, this.name, this.albumCount, this.coverArt});

  @override
  List<Object> get props => [id, name];

  @override
  String toString() => 'Artist { id: $id }';

  factory Artist.fromJSON(Map<String, dynamic> json) => Artist(
        id: json['id'],
        name: json['name'],
        albumCount: json['albumCount'],
        coverArt: json['coverArt'],
      );

  Map<String, dynamic> toJSON() => {
        'id': id,
        'name': name,
        'albumCount': albumCount,
        'coverArt': coverArt,
      };
}
