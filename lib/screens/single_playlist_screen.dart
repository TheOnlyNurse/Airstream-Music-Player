import 'package:airstream/bloc/song_list_bloc.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/widgets/songlist/song_list.dart';
import 'package:flutter/material.dart';

class SinglePlaylistScreen extends StatefulWidget {
  final Playlist playlist;

  const SinglePlaylistScreen({Key key, this.playlist}) : super(key: key);

  @override
  _SinglePlaylistScreenState createState() => _SinglePlaylistScreenState();
}

class _SinglePlaylistScreenState extends State<SinglePlaylistScreen> {
  bool appbarHidden = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SongList(
        type: SongListType.playlist,
        typeValue: widget.playlist,
        leading: <Widget>[
          if (!appbarHidden)
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: RawMaterialButton(
                child: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.playlist.name,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ),
        ],
        onSelection: (hasSelection) {
          if (appbarHidden != hasSelection)
            setState(() {
              appbarHidden = hasSelection;
            });
        },
      ),
    );
  }
}
