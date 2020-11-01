import 'package:airstream/complex_widgets/song_list/sliver_song_list.dart';

/// External Packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Internal Links
import '../models/image_adapter.dart';
import '../cubit/single_album_cubit.dart';
import '../complex_widgets/error_widgets.dart';
import '../static_assets.dart';
import '../widgets/flexible_image_with_title.dart';
import '../widgets/square_close_button.dart';

class SingleAlbumScreen extends StatelessWidget {
  const SingleAlbumScreen({
    Key key,
    @required this.cubit,
  })  :
        assert(cubit != null),
        super(key: key);

  final SingleAlbumCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SingleAlbumCubit, SingleAlbumState>(
      cubit: cubit,
      builder: (_, state) {
        if (state is SingleAlbumInitial) {
          return Center(child: CircularProgressIndicator());
        }

        if (state is SingleAlbumSuccess) {
          return _Success(state);
        }

        if (state is SingleAlbumError) {
          return Center(child: Text('TODO: proper error screen'));
        }

        return NoStateErrorScreen(message: state.toString());
      },
    );
  }
}

class _Success extends StatelessWidget {
  const _Success(this.state, {Key key}) : super(key: key);
  final SingleAlbumSuccess state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: airstreamScrollPhysics,
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          stretch: true,
          stretchTriggerOffset: 200,
          flexibleSpace: FlexibleImageWithTitle(
            title: state.album.title,
            adapter: ImageAdapter(album: state.album, isHiDef: true),
          ),
          automaticallyImplyLeading: false,
          title: SquareCloseButton(),
          titleSpacing: 0,
        ),
        SliverSongList(songs: state.songs),
      ],
    );
  }
}
