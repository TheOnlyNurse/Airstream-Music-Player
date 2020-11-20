import 'package:airstream/common/providers/moor_database.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'selection_bar_state.dart';

class SelectionBarCubit extends Cubit<SelectionBarState> {
  SelectionBarCubit() : super(SelectionBarInactive());

  void selected(Song song) {
    final currentState = state;
    if (currentState is SelectionBarActive) {
      final selected = currentState.selected;
      // Remove the song if within the list, else add.
      selected.contains(song) ? selected.remove(song) : selected.add(song);
      emit(selected.isEmpty
          ? SelectionBarInactive()
          : SelectionBarActive(selected: selected));
    } else {
      emit(SelectionBarActive(selected: [song]));
    }
  }
}
