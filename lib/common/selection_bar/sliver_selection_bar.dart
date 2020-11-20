import 'package:airstream/common/widgets/circle_close_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/playlist_model.dart';
import 'bloc/selection_bar_cubit.dart';
import 'widgets/playlist_dialog.dart';

part 'widgets/selection_title.dart';

class SliverSelectionBar extends StatelessWidget {
  final double expandedHeight;
  final bool stretch;
  final double stretchTriggerOffset;
  final Widget flexibleSpace;
  final List<Widget> actions;

  const SliverSelectionBar({
    Key key,
    this.expandedHeight,
    this.stretch,
    this.stretchTriggerOffset,
    this.flexibleSpace,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectionBarCubit, SelectionBarState>(
      builder: (context, state) {
        return SliverAppBar(
          expandedHeight: expandedHeight,
          stretch: stretch,
          stretchTriggerOffset: stretchTriggerOffset,
          flexibleSpace: flexibleSpace,
          backgroundColor: Theme.of(context).backgroundColor,
          pinned: true,
          titleSpacing: 8,
          automaticallyImplyLeading: false,
          title: state is SelectionBarActive
              ? _SelectionTitle(state: state)
              : const CircleCloseButton(),
          actions: state is SelectionBarInactive
              ? actions
              : <Widget>[
                  _AddToPlaylist(),
                  const _ChangeStar(canRemoveStar: false),
                ],
        );
      },
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
