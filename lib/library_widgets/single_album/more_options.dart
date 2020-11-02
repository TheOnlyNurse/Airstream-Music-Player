part of '../../screens/single_album_screen.dart';

class _MoreOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: Icon(Icons.more_vert),
      itemBuilder: (_) => <PopupMenuEntry<int>>[
        const PopupMenuItem(child: Text('Refresh album'), value: 1,),
      ],
      onSelected: (index) => null,
    );
  }
}