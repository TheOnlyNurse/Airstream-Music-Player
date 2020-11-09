
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../models/song_list_delegate.dart';
import '../providers/moor_database.dart';
import '../repository/playlist_repository.dart';
import '../repository/repository.dart';
import '../repository/song_repository.dart';
import '../song_list_bar/song_list_bar.dart';
import '../static_assets.dart';
import 'bloc/song_list_bloc.dart';
import 'widgets/song_list_tile.dart';

// Barrelling
export '../models/song_list_delegate.dart';

class SongList extends StatelessWidget {
  const SongList(
      {@required this.delegate,
      this.sliverTitle,
      this.leading,
      this.trailing,
      this.sliverAppBar,
      this.controller})
      : assert(delegate != null);

  final SongListDelegate delegate;
  final Widget sliverTitle;
  final List<Widget> leading;
  final List<Widget> trailing;
  final Widget sliverAppBar;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final animatedListKey = GlobalKey<SliverAnimatedListState>();

    /// Return if this song list is able to un-star songs
    bool _canRemoveStar(SongListDelegate delegate) {
      return delegate is SimpleSongList && delegate.canRemoveStar;
    }

    /// Animated removal of songs
    void _removeSongs(Map<int, Song> removeMap) {
      for (final index in removeMap.keys) {
        animatedListKey.currentState.removeItem(index, (context, animation) {
          return SongListTile(animation: animation, song: removeMap[index]);
        });
      }
    }

    /// Compile slivers from widget variables
    List<Widget> _createSlivers(SongListSuccess state) {
      final slivers = <Widget>[];

      // Add app bar, either selection bar or user set
      if (state.selected.isNotEmpty) {
        slivers.add(SongListBar(
          selectedNumber: state.selected.length,
          canRemoveStar: _canRemoveStar(delegate),
        ));
      } else if (sliverAppBar != null) {
        slivers.add(sliverAppBar);
      }

      // Add widgets that appear before the song list
      if (leading != null) slivers.addAll(leading);

      // If a title is set, add before song list
      if (sliverTitle != null) slivers.add(sliverTitle);

      // Finally add the song list
      slivers.add(
        _SliverSongList(
          animatedListKey: animatedListKey,
          songs: state.songList,
          selectedIndexes: state.selected,
        ),
      );

      if (trailing != null) slivers.addAll(trailing);

      return slivers;
    }

    /// Widget based on states that isn't a success state
    Widget _processOtherStates(SongListState state) {
      if (state is SongListInitial) return const CircularProgressIndicator();
      if (state is SongListFailure) return state.errorMessage;
      return const Text('Failed to read state.');
    }

    return BlocProvider(
      create: (context) => SongListBloc(
        songRepository: GetIt.I.get<SongRepository>(),
        playlistRepository: GetIt.I.get<PlaylistRepository>(),
      )..add(SongListFetch(delegate)),
      child: BlocConsumer<SongListBloc, SongListState>(
        listener: (context, state) {
          if (state is SongListSuccess && state.removeMap.isNotEmpty) {
            _removeSongs(state.removeMap);
          }
        },
        builder: (context, state) {
          if (state is SongListSuccess) {
            return CustomScrollView(
              physics: WidgetProperties.scrollPhysics,
              controller: controller,
              slivers: _createSlivers(state),
            );
          }

          return Center(child: _processOtherStates(state));
        },
      ),
    );
  }
}

class _SliverSongList extends StatelessWidget {
  final GlobalKey<SliverAnimatedListState> animatedListKey;
  final List<Song> songs;
  final List<int> selectedIndexes;

  const _SliverSongList({
    Key key,
    @required this.songs,
    this.animatedListKey,
    List<int> selectedIndexes,
  })  : selectedIndexes = selectedIndexes ?? const <int>[],
        assert(songs != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      sliver: SliverAnimatedList(
        key: animatedListKey,
        initialItemCount: songs.length,
        itemBuilder: (context, index, animation) {
          return SongListTile(
            animation: animation,
            isSelected: selectedIndexes.contains(index),
            song: songs[index],
            onLongPress: () {
              context.bloc<SongListBloc>().add(SongListSelection(index));
            },
            onTap: () {
              if (selectedIndexes.isNotEmpty) {
                context.bloc<SongListBloc>().add(SongListSelection(index));
              } else {
                Repository().audio.start(playlist: songs, index: index);
              }
            },
          );
        },
      ),
    );
  }
}
