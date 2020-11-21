import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../models/playlist_model.dart';
import '../../repository/playlist_repository.dart';
import '../bloc/playlist_dialog_cubit.dart';
import 'playlist_dialog.dart';

class PlaylistButton extends StatelessWidget {
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
