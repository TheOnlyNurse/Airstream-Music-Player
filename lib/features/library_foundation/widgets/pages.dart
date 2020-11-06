part of '../foundation.dart';

class _Pages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBarBloc, NavigationBarState>(
      builder: (context, state) {
        switch (state.pageIndex) {
          case 0:
            return HomeScreen(
              albumRepository: GetIt.I.get<AlbumRepository>(),
              artistRepository: GetIt.I.get<ArtistRepository>(),
            );
            break;
          case 1:
            return StarredScreen();
            break;
          default:
            throw UnimplementedError('Page index: ${state.pageIndex}');
        }
      },
    );
  }
}