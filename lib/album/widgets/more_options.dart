part of '../screen.dart';

class _MoreOptions extends StatelessWidget {
  const _MoreOptions({Key key, this.cubit}) : super(key: key);

  final SingleAlbumCubit cubit;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: Icon(Icons.more_vert),
      itemBuilder: (_) => <PopupMenuEntry<int>>[
        const PopupMenuItem(
          child: Text('Reload album'),
          value: 1,
        ),
      ],
      onSelected: (index) => cubit.popupSelected(index),
    );
  }
}
