part of 'selection_bar_cubit.dart';

abstract class SelectionBarState {
  const SelectionBarState();
}

class SelectionBarInactive extends SelectionBarState {
  const SelectionBarInactive();
}

class SelectionBarActive extends SelectionBarState {
  final List<Song> selected;

  const SelectionBarActive({@required this.selected})
      : assert(selected != null);
}
