part of '../album_screen.dart';

class _Success extends StatelessWidget {
  const _Success(this.state, {Key key, this.cubit}) : super(key: key);

  final SingleAlbumSuccess state;
  final SingleAlbumCubit cubit;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: WidgetProperties.scrollPhysics,
      slivers: [
        SliverAppBar(
          expandedHeight: 400,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                maxFontSize: 25,
                textAlign: TextAlign.center,
              ),
            ),
            adapter: AlbumImageAdapter(album: state.album, isHiDef: true),
          ),
          automaticallyImplyLeading: false,
          titleSpacing: 8,
          title: CircleCloseButton(),
          actions: [
            _StarButton(isStarred: state.album.isStarred, cubit: cubit),
            const _MoreOptions(),
          ],
        ),
        SliverToBoxAdapter(child: _ShuffleButton(songs: state.songs)),
        SliverSongList(
          songs: state.songs,
          audioRepository: GetIt.I.get<AudioRepository>(),
        ),
      ],
    );
  }
}
