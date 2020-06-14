import 'package:airstream/bloc/song_list_bloc.dart';
import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/events/song_list_event.dart';
import 'package:airstream/models/song_model.dart';
import 'package:airstream/states/song_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SongList extends StatelessWidget {
  const SongList({
    @required this.type,
    @required this.typeValue,
    this.leading,
  })  : assert(type != null),
        assert(typeValue != null);

  final SongListType type;
  final dynamic typeValue;
  final List<Widget> leading;

  @override
  Widget build(BuildContext context) {
    final listKey = GlobalKey<SliverAnimatedListState>();

    return BlocProvider(
      create: (context) => SongListBloc()..add(SongListFetch(type, typeValue)),
      child: BlocConsumer<SongListBloc, SongListState>(
        listener: (context, state) {
          if (state is SongListSuccess && state.removeMap.isNotEmpty) {
            for (int index in state.removeMap.keys) {
              listKey.currentState.removeItem(index, (context, animation) {
                return _SongTile(
                  animation: animation,
                  song: state.removeMap[index],
                );
              });
            }
          }
        },
        builder: (context, state) {
          if (state is SongListSuccess) {
            void tileSelected(int index) {
              context.bloc<SongListBloc>().add(SongListSelection(index));
            }

            void play(int index) {
              Repository().audio.play(playlist: state.songList, index: index);
            }

            Widget _trailingIcon(int index) {
              final color = Theme.of(context).accentColor;
              if (state.selected.contains(index)) {
                return Icon(Icons.check_circle_outline, color: color);
              }
              return null;
            }

            Widget _appbar() {
              return _SongListBar(
                type: type,
                selectedNumber: state.selected.length,
              );
            }

            Widget _list() {
              return SliverPadding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
                sliver: SliverAnimatedList(
                  key: listKey,
                  initialItemCount: state.songList.length,
                  itemBuilder: (context, index, animation) {
                    return _SongTile(
                      animation: animation,
                      trailing: _trailingIcon(index),
                      song: state.songList[index],
                      onLongPress: () => tileSelected(index),
                      onTap: () {
                        if (state.selected.length > 0) {
                          tileSelected(index);
                        } else {
                          play(index);
                        }
                      },
                    );
                  },
                ),
              );
            }

            List<Widget> _getSlivers() {
              if (leading == null) {
                return <Widget>[
                  if (state.selected.isNotEmpty) _appbar(),
                  _list(),
                ];
              } else {
                final slivers = <Widget>[];
                if (state.selected.isNotEmpty) slivers.add(_appbar());
                slivers.addAll(leading);
                slivers.add(_list());
                return slivers;
              }
            }

            return CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: _getSlivers(),
            );
          }

          if (state is SongListInitial) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is SongListFailure) {
            return Center(child: state.errorMessage);
          }

          return Center(child: Text('Couldn\'t read state}'));
        },
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  const _SongTile({
    @required this.song,
    this.onLongPress,
    this.onTap,
    this.trailing,
    this.animation,
  }) : assert(song != null);

  final Song song;
  final Function onLongPress;
  final Function onTap;
  final Widget trailing;
  final Animation<double> animation;

  static final _slideTween = Tween<Offset>(
    begin: const Offset(-1.0, 0.0),
    end: Offset.zero,
  );

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation.drive(_slideTween),
      child: Container(
        color: Colors.transparent,
        child: ListTile(
          onLongPress: onLongPress,
          contentPadding: EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
          title: Text(song.title),
          subtitle: Text(
            song.artist,
            style: Theme
                .of(context)
                .textTheme
                .caption,
          ),
          onTap: onTap,
          trailing: trailing,
        ),
      ),
    );
  }
}

class _SongListBar extends StatelessWidget {
  final SongListType type;
  final int selectedNumber;

  const _SongListBar({Key key, this.type, this.selectedNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void listBloc(SongListEvent event) => context.bloc<SongListBloc>().add(event);

    return SliverAppBar(
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
            onPressed: () => listBloc(SongListRemoveSelection()),
          ),
        IconButton(
          icon: Icon(Icons.add_to_photos),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.playlist_add),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(type == SongListType.starred ? Icons.star_border : Icons.star),
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
