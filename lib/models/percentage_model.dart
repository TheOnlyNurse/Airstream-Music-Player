import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class PercentageModel extends Equatable {
  final bool hasData;
  final int songId;
  final int current;
  final int total;

  const PercentageModel({
    @required this.hasData,
    this.songId,
    this.current = 0,
    this.total = 1,
  }) : assert(hasData != null);

  int get percentage => (current / total * 100).round();

	@override
	List<Object> get props => [hasData, songId, percentage];

	PercentageModel update({bool hasData, int addToCurrent, int total}) {
		return PercentageModel(
			hasData: hasData ?? this.hasData,
			songId: this.songId,
			current: addToCurrent != null ? this.current + addToCurrent : this
					.current,
			total: total ?? this.total,
		);
	}
}
