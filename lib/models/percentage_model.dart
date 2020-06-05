import 'package:equatable/equatable.dart';

class PercentageModel extends Equatable {
  final int current;
  final int total;

  PercentageModel({this.current, this.total});

  int get percent => (current / total * 100).round();

  @override
  List<Object> get props => [percent];
}
