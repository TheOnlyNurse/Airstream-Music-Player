import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../common/repository/audio_repository.dart';
import '../../../common/repository/repository.dart';

part 'position_event.dart';

part 'position_state.dart';

class PositionBloc extends Bloc<PositionEvent, PositionState> {
  PositionBloc({@required this.audioRepository}) : super(PositionInitial()) {
    onPosition = audioRepository.audioPosition.listen((duration) {
      add(PositionNew(duration));
    });
    onDownloading = Repository().download.percentageStream.listen((event) {
      if (event.songId == audioRepository.current.id) {
        add(PositionDownload(event.percentage));
      }
    });
    onNewSong = audioRepository.songState.listen((event) {
      add(PositionRefresh());
    });
  }

  final AudioRepository audioRepository;
  StreamSubscription onPosition;
  StreamSubscription onDownloading;
  StreamSubscription onNewSong;

  @override
  Stream<PositionState> mapEventToState(PositionEvent event) async* {
    if (event is PositionRefresh) {
      yield PositionInitial();
    }
    if (event is PositionNew) {
      final maxDuration = audioRepository.maxDuration;
      var position = event.position;
      if (maxDuration < event.position) position = maxDuration;
      yield PositionSuccess(position, maxDuration);
    }

    if (event is PositionDownload) yield PositionLoading(event.percentage);
  }

  @override
  Future<void> close() {
    onPosition.cancel();
    onDownloading.cancel();
    onNewSong.cancel();
    return super.close();
  }
}
