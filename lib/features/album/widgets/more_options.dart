part of '../album_screen.dart';

class _MoreOptions extends StatelessWidget {
  const _MoreOptions({Key key, this.cubit}) : super(key: key);

  final SingleAlbumCubit cubit;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (_) => <PopupMenuEntry<int>>[
        const PopupMenuItem(
          value: 1,
          child: Text('Reload album'),
        ),
      ],
      onSelected: (index) => cubit.popupSelected(index),
    );
  }
}
