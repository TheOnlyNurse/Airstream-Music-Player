abstract class NavigationBarEvent {}

class NavigateToPage extends NavigationBarEvent {
  final int index;

  NavigateToPage({this.index});
}

class UpdateNavBar extends NavigationBarEvent {
  final int index;

  UpdateNavBar({this.index});
}
