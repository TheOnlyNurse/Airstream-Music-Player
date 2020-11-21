import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../common/models/image_adapter.dart';
import '../../../common/providers/moor_database.dart';
import '../../../common/repository/artist_repository.dart';
import '../../../common/repository/audio_repository.dart';
import '../../../common/selection_bar/sliver_selection_bar.dart';
import '../../../common/song_list/sliver_song_list.dart';
import '../../../common/widgets/flexible_image_with_title.dart';
import '../../../common/widgets/future_button.dart';
import '../bloc/album_cubit.dart';
import 'more_options.dart';
import 'shuffle_button.dart';
import 'star_button.dart';

class AlbumSuccessScreen extends StatelessWidget {
  const AlbumSuccessScreen(this.state, {Key key, this.cubit}) : super(key: key);

  final SingleAlbumSuccess state;
  final SingleAlbumCubit cubit;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics(),),
      slivers: [
        SliverSelectionBar(
          expandedHeight: 400,
          stretch: true,
          stretchTriggerOffset: 200,
          flexibleSpace: FlexibleImageWithTitle(
            title: FutureButton<Artist>(
              future: GetIt.I.get<ArtistRepository>().byId(
                    state.album.artistId,
                  ),
              onTap: (artist) => Navigator.pushReplacementNamed(
                context,
                'library/singleArtist',
                arguments: artist,
              ),
              child: AutoSizeText(
                state.album.title,
                style: Theme.of(context).textTheme.headline4,
                maxLines: 2,
                maxFontSize: 35,
                textAlign: TextAlign.center,
              ),
            ),
            adapter: AlbumImageAdapter(album: state.album, isHiDef: true),
          ),
          actions: [
            AlbumStarButton(isStarred: state.album.isStarred, cubit: cubit),
            const AlbumMoreOptions(),
          ],
        ),
        SliverToBoxAdapter(child: AlbumShuffleButton(songs: state.songs)),
        SliverSongList(
          songs: state.songs,
          audioRepository: GetIt.I.get<AudioRepository>(),
        ),
      ],
    );
  }
}
