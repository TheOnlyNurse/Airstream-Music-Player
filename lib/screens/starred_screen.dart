import 'package:airstream/bloc/song_list_bloc.dart';
import 'package:airstream/bloc/starred_bloc.dart';
import 'package:airstream/widgets/song_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StarredScreen extends StatefulWidget {
  const StarredScreen({Key key}) : super(key: key);

  _StarredScreenState createState() => _StarredScreenState();
}

class _StarredScreenState extends State<StarredScreen>
    with AutomaticKeepAliveClientMixin<StarredScreen> {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider(
      create: (context) => StarredBloc()..add(StarredEvent.fetch),
      child: BlocBuilder<StarredBloc, StarredState>(
        builder: (context, state) {
          if (state is StarredSuccess) {
            return RefreshIndicator(
              onRefresh: () async {
                context.bloc<StarredBloc>().add(StarredEvent.refresh);
                return;
              },
              child: SongList(type: SongListType.starred, typeValue: state.songList),
            );
          }
          if (state is StarredInitial) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is StarredFailure) {
            return Center(child: state.error);
          }

          return Center(child: Text('error reading state'));
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
