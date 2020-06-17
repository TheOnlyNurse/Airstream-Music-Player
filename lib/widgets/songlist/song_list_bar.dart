import 'package:airstream/bloc/song_list_bloc.dart';
import 'package:airstream/events/song_list_event.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/widgets/songlist/add_to_playlist_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SongListBar extends StatelessWidget {
  final SongListType type;
  final int selectedNumber;

  const SongListBar({Key key, this.type, this.selectedNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void listBloc(SongListEvent event) => context.bloc<SongListBloc>().add(event);

    return SliverAppBar(
      backgroundColor: Theme.of(context).cardColor,
      pinned: true,
      title: Text('$selectedNumber selected'),
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          listBloc(SongListClearSelection());
        },
      ),
      actions: <Widget>[
        if (type == SongListType.playlist)
          IconButton(
            icon: Icon(Icons.remove_circle_outline),
            tooltip: 'Remove from this playlist',
            onPressed: () => listBloc(SongListRemoveSelection()),
          ),
        IconButton(
          icon: Icon(Icons.add_circle_outline),
          tooltip: 'Add to playlist',
          onPressed: () async {
            final response = await showDialog(
                context: context,
                builder: (context) {
                  return AddToPlaylistDialog();
                });
            assert(response is Playlist || response == null);

            if (response != null) {
              listBloc(SongListPlaylistSelection(response));
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.queue_music),
          tooltip: 'Add to music queue',
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(type == SongListType.starred ? Icons.star_border : Icons.star),
          tooltip: type == SongListType.starred ? 'Unstar songs' : 'Star songs',
          onPressed: () {
            if (type == SongListType.starred) {
              listBloc(SongListRemoveSelection());
            } else {
              listBloc(SongListStarSelection());
            }
          },
        ),
      ],
    );
  }
}
