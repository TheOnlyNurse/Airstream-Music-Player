import 'package:equatable/equatable.dart';

abstract class AirstreamBaseModel extends Equatable {
  int get id;

  String get name;

  String get coverArt;
}
