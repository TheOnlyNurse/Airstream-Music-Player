import 'package:airstream/data_providers/moor_database.dart';
import 'package:equatable/equatable.dart';

abstract class SingleAlbumEvent extends Equatable {
  const SingleAlbumEvent();

  @override
  List<Object> get props => [];
}

class FetchAlbumInfo extends SingleAlbumEvent {
  final Album album;

  FetchAlbumInfo({this.album});
}
