import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/events/position_event.dart';
import 'package:airstream/states/position_state.dart';

// Barrel for import clarity
export 'package:airstream/events/position_event.dart';
export 'package:airstream/states/position_state.dart';

class PositionBloc extends Bloc<PositionEvent, PositionState> {
  final _repository = Repository();
  StreamSubscription onPosition;
  StreamSubscription onDownloading;
  StreamSubscription onNewSong;

  PositionBloc() : super(PositionInitial()) {
    onPosition = _repository.audio.audioPosition.listen((duration) {
      this.add(PositionNew(duration));
    });
    onDownloading = _repository.download.percentageStream.listen((event) {
      if (event.songId == _repository.audio.current.id) {
        this.add(PositionDownload(event.percentage));
      }
    });
    onNewSong = _repository.audio.songState.listen((event) {
      if (event == AudioPlayerSongState.newSong) {
        this.add(PositionRefresh());
      }
    });
  }

  @override
  Stream<PositionState> mapEventToState(PositionEvent event) async* {
    if (event is PositionRefresh) {
      yield PositionInitial();
    }
    if (event is PositionNew) {
      final maxDuration = Repository().audio.maxDuration;
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
