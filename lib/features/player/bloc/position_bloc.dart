import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../common/global_assets.dart';
import '../../../common/repository/audio_repository.dart';
import '../../../common/repository/download_repository.dart';

part 'position_event.dart';
part 'position_state.dart';

class PositionBloc extends Bloc<PositionEvent, PositionState> {
  PositionBloc({
    AudioRepository audioRepository,
    DownloadRepository downloadRepository,
  })  : _audioRepository = getIt<AudioRepository>(audioRepository),
        _downloadRepository = getIt<DownloadRepository>(downloadRepository),
        super(PositionInitial()) {
    onPosition = _audioRepository.audioPosition.listen((duration) {
      add(PositionNew(duration));
    });
    onDownloading = _downloadRepository.percentage.listen((event) {
      if (event.songId == _audioRepository.current.id) {
        add(PositionDownload(event.percentage));
      }
    });
    onNewSong = _audioRepository.songState.listen((event) {
      add(PositionRefresh());
    });
  }

  final AudioRepository _audioRepository;
  final DownloadRepository _downloadRepository;
  StreamSubscription onPosition;
  StreamSubscription onDownloading;
  StreamSubscription onNewSong;

  @override
  Stream<PositionState> mapEventToState(PositionEvent event) async* {
    if (event is PositionRefresh) {
      yield PositionInitial();
    }
    if (event is PositionNew) {
      final maxDuration = _audioRepository.maxDuration;
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
