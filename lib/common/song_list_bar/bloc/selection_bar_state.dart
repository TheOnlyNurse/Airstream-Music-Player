part of 'selection_bar_cubit.dart';

abstract class SelectionBarState extends Equatable {
  const SelectionBarState();

  @override
  List<Object> get props => [];
}

class SelectionBarInactive extends SelectionBarState {}

class SelectionBarActive extends SelectionBarState {
  final List<Song> selected;

  const SelectionBarActive({@required this.selected})
      : assert(selected != null);

  SelectionBarActive copyWith({List<Song> selected}) =>
      SelectionBarActive(selected: selected ?? this.selected);

  SelectionBarActive addSong(Song song) =>
      SelectionBarActive(selected: [...selected, song]);

  @override
  List<Object> get props => [selected];
}
