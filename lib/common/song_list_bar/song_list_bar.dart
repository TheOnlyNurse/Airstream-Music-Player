import 'package:flutter/material.dart';

import '../models/playlist_model.dart';
import 'widgets/playlist_dialog.dart';

class SongListBar extends StatelessWidget {
  final int selectedNumber;
  final bool canRemoveStar;

  const SongListBar({
    Key key,
    this.selectedNumber,
    this.canRemoveStar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).cardColor,
      pinned: true,
      title: selectedNumber != null ? Text('$selectedNumber selected') : null,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => throw UnimplementedError(),
      ),
      actions: <Widget>[
        _AddToPlaylist(),
        _ChangeStar(canRemoveStar: canRemoveStar),
      ],
    );
  }
}

class _AddToPlaylist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_circle_outline),
      tooltip: 'Add to playlist',
      onPressed: () async {
        final response = await showDialog(
          context: context,
          builder: (_) => PlaylistDialog(),
        ) as Playlist;

        if (response != null) {
          throw UnimplementedError();
        }
      },
    );
  }
}

class _ChangeStar extends StatelessWidget {
  final bool canRemoveStar;

  const _ChangeStar({Key key, this.canRemoveStar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(canRemoveStar ? Icons.star_border : Icons.star),
      tooltip: canRemoveStar ? 'Remove star' : 'Star songs',
      onPressed: () {
        if (canRemoveStar) {
          throw UnimplementedError();
        } else {
          throw UnimplementedError();
        }
      },
    );
  }
}
