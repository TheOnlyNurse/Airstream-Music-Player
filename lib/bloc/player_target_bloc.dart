import 'package:airstream/barrel/bloc_basics.dart';

enum PlayerTargetEvent { dragStart, dragEnd }
enum PlayerTargetState { visible, invisible }

class PlayerTargetBloc extends Bloc<PlayerTargetEvent, PlayerTargetState> {
  @override
  // TODO: implement initialState
  PlayerTargetState get initialState => PlayerTargetState.invisible;

  @override
  Stream<PlayerTargetState> mapEventToState(PlayerTargetEvent event) async* {
    switch (event) {
      case PlayerTargetEvent.dragStart:
        yield PlayerTargetState.visible;
        break;
      default:
        yield PlayerTargetState.invisible;
    }
  }
}
