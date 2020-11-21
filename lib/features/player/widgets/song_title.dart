import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../common/providers/moor_database.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/widgets/future_button.dart';
import '../../../global_assets.dart';
import '../bloc/player_bloc.dart';

class PlayerSongTitle extends StatelessWidget {
  const PlayerSongTitle({Key key, this.state}) : super(key: key);

  final PlayerSuccess state;

  @override
  Widget build(BuildContext context) {
    return FutureButton<Album>(
      future: GetIt.I.get<AlbumRepository>().byId(state.song.albumId),
      onTap: (album) {
        if (libraryNavigator.currentState.canPop()) {
          libraryNavigator.currentState.popUntil((route) => route.isFirst);
        }
        Navigator.of(libraryNavigator.currentContext).pushNamed(
          'library/singleAlbum',
          arguments: album,
        );
        Navigator.pop(context);
      },
      child: _TitleColumn(song: state.song),
    );
  }
}

class _TitleColumn extends StatelessWidget {
  const _TitleColumn({Key key, this.song}) : super(key: key);
  final Song song;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          Text(
            song.title,
            style: Theme.of(context).textTheme.headline5.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            song.artist,
            style: Theme.of(context).textTheme.subtitle1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
