/// External Packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class SingleAlbumCubit extends Cubit<SingleAlbumState> {
  SingleAlbumCubit() : super(SingleAlbumInitial());
}

abstract class SingleAlbumState extends Equatable {
  const SingleAlbumState();

  @override
  List<Object> get props => [];
}

class SingleAlbumInitial extends SingleAlbumState {}

class SingleAlbumSuccess extends SingleAlbumState {}