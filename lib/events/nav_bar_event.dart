abstract class NavigationBarEvent {}

class NavigationBarMusicStopped extends NavigationBarEvent {}

class NavigationBarMusicStarted extends NavigationBarEvent {}

class NavigationBarNavigate extends NavigationBarEvent {
  final int index;

  NavigationBarNavigate(this.index);
}

class NavigationBarUpdate extends NavigationBarEvent {
  final int index;

  NavigationBarUpdate(this.index);
}

class NavigationBarDrag extends NavigationBarEvent {
  final double height;

  NavigationBarDrag(this.height);
}
