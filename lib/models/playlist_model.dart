import 'package:equatable/equatable.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final String comment;
  final String date;
  final List<String> songList;

  Playlist({this.id, this.name, this.comment, this.date, this.songList});

  @override
  List<Object> get props => [id, name];

  factory Playlist.fromJSON(Map<String, dynamic> json) => Playlist(
        id: json['id'],
        name: json['name'],
        comment: json['comment'],
        date: json['date'],
        songList: json['songList'].split("'")[0],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'comment': comment,
        'date': date,
        'songList': songList.toString(),
      };
}
