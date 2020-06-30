import 'package:airstream/bloc/song_list_bloc.dart';
import 'package:airstream/data_providers/repository/repository.dart';
import 'package:airstream/events/song_list_event.dart';
import 'package:airstream/states/song_list_state.dart';
import 'package:airstream/widgets/songlist/song_list_bar.dart';
import 'package:airstream/widgets/songlist/song_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SongList extends StatelessWidget {
  const SongList(
      {@required this.type,
      @required this.typeValue,
      this.title,
      this.leading,
      this.onSelection,
      this.controller});

  final SongListType type;
  final dynamic typeValue;
  final Widget title;
  final List<Widget> leading;
  final Function(bool hasSelection) onSelection;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final listKey = GlobalKey<SliverAnimatedListState>();

    return BlocProvider(
      create: (context) =>
          SongListBloc()..add(SongListFetch(type, typeValue, onSelection)),
      child: BlocConsumer<SongListBloc, SongListState>(
        listener: (context, state) {
          if (state is SongListSuccess && state.removeMap.isNotEmpty) {
            for (int index in state.removeMap.keys) {
              listKey.currentState.removeItem(index, (context, animation) {
								return SongListTile(
                  animation: animation,
                  song: state.removeMap[index],
                );
              });
            }
          }
        },
        builder: (context, state) {
          if (state is SongListSuccess) {
            void bloc(SongListEvent event) => context.bloc<SongListBloc>().add(event);

            Widget _trailingIcon(int index) {
              if (state.selected.contains(index))
                return Icon(
                  Icons.check,
                  color: Theme.of(context).accentColor,
                );

              return null;
            }

            Widget _list() {
              return SliverPadding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
                sliver: SliverAnimatedList(
                  key: listKey,
                  initialItemCount: state.songList.length,
                  itemBuilder: (context, index, animation) {
										return SongListTile(
											animation: animation,
											trailing: _trailingIcon(index),
											song: state.songList[index],
											onLongPress: () => bloc(SongListSelection(index)),
											onTap: () {
												if (state.selected.length > 0) {
													bloc(SongListSelection(index));
												} else {
													Repository().audio.start(
															playlist: state.songList, index: index);
												}
                      },
                    );
                  },
                ),
              );
            }

            List<Widget> _getSlivers() {
              final slivers = <Widget>[];
              if (state.selected.isNotEmpty) {
                slivers.add(
                  SongListBar(type: type, selectedNumber: state.selected.length),
                );
              }
              if (leading != null) {
                slivers.addAll(leading);
              }
              if (title != null) {
                slivers.add(SliverToBoxAdapter(child: title));
              }
              slivers.add(_list());
              return slivers;
            }

            return CustomScrollView(
              physics: BouncingScrollPhysics(),
              controller: controller,
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
