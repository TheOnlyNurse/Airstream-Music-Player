part of '../sliver_selection_bar.dart';

class _PlaylistButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_circle_outline),
      tooltip: 'Add to playlist',
      onPressed: () async {
        final response = await showDialog<Playlist>(
          context: context,
          builder: (_) => BlocProvider(
            create: (context) => PlaylistDialogCubit(
              playlistRepository: GetIt.I.get<PlaylistRepository>(),
            )..fetch(),
            child: PlaylistDialog(),
          ),
        );

        if (response != null) {
          throw UnimplementedError();
        }
      },
    );
  }
}
