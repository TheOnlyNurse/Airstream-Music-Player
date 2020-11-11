import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class DownloadPercentage extends Equatable {
  const DownloadPercentage({
    @required this.songId,
    this.isActive = true,
    this.current = 0,
    this.total = 1,
  }) : assert(songId != null);

  final bool isActive;
  final int songId;
  final int current;
  final int total;

  int get percentage => (current / total * 100).round();

  @override
  List<Object> get props => [isActive, songId, current, total];

  DownloadPercentage copyWith({bool isActive, int increment, int total}) =>
      DownloadPercentage(
        isActive: isActive ?? this.isActive,
        songId: songId,
        current: increment != null ? current + increment : current,
        total: total ?? this.total,
      );
}
