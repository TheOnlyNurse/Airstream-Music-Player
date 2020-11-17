part of '../player_screen.dart';

class _SongTitle extends StatelessWidget {
  final PlayerSuccess state;

  const _SongTitle({Key key, this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureButton<Either<String, Album>>(
      future: GetIt.I.get<AlbumRepository>().byId(state.song.albumId),
      onTap: (potentialAlbum) {
        potentialAlbum.fold(
          // ignore: avoid_print
          (error) => print('Future button should take Either types.'),
          (album) {
            if (libraryNavigator.currentState.canPop()) {
              libraryNavigator.currentState.popUntil((route) => route.isFirst);
            }
            Navigator.of(libraryNavigator.currentContext).pushNamed(
              'library/singleAlbum',
              arguments: album,
            );
            Navigator.pop(context);
          },
        );
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
