import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Internal
import '../song_list/bloc/song_list_bloc.dart';
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
        icon: Icon(Icons.close),
        onPressed: () {
          context.bloc<SongListBloc>().add(SongListClearSelection());
        },
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
      icon: Icon(Icons.add_circle_outline),
      tooltip: 'Add to playlist',
      onPressed: () async {
        final response = await showDialog(
          context: context,
          builder: (context) {
            return PlaylistDialog();
          },
        );
        assert(response is Playlist || response == null);
        if (response != null) {
          context.bloc<SongListBloc>().add(SongListPlaylistSelection(response));
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
          context.bloc<SongListBloc>().add(SongListRemoveSelection());
        } else {
          context.bloc<SongListBloc>().add(SongListStarSelection());
        }
      },
    );
  }
}
