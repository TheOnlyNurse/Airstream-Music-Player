import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 1)
class Playlist extends Equatable {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String comment;
  @HiveField(3)
  final List<int> songIds;

  const Playlist({this.id, this.name, this.comment, this.songIds});

  @override
  List<Object> get props => [id, name, songIds];

  Playlist copyWith({int id, String name, String comment}) => Playlist(
        id: id ?? this.id,
        name: name ?? this.name,
        comment: comment ?? this.comment,
        songIds: this.songIds,
      );
}
