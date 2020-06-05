abstract class NavigationBarState {}

class HomePage extends NavigationBarState {
  final int index;
  final bool shouldNavigate;

  HomePage({this.index, this.shouldNavigate = true});
}
