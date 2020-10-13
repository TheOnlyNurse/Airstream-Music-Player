import 'package:airstream/bloc/random_bloc.dart';
import 'package:airstream/events/random_event.dart';
import 'package:airstream/repository/album_repository.dart';
import 'package:airstream/states/random_state.dart';
import 'package:airstream/widgets/sliver_card_grid.dart';
import 'package:airstream/widgets/sliver_close_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class RandomScreen extends StatefulWidget {
  const RandomScreen({Key key}) : super(key: key);

  @override
  _RandomScreenState createState() => _RandomScreenState();
}

class _RandomScreenState extends State<RandomScreen> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  RandomBloc _randomBloc;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _randomBloc.add(RandomNext());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RandomBloc(GetIt.I.get<AlbumRepository>())..add(RandomFetch()),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<RandomBloc, RandomState>(builder: (context, state) {
            if (state is RandomSuccess) {
              _randomBloc = context.bloc<RandomBloc>();

              return CustomScrollView(
								controller: _scrollController,
                physics: BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverCloseBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text('Random',
                          style: Theme.of(context).textTheme.headline4),
                    ),
                  ),
                  SliverAlbumGrid(albumList: state.albums),
                ],
              );
            }

            return Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8),
                    child: RawMaterialButton(
                      shape: CircleBorder(),
                      constraints: BoxConstraints.tightFor(
                        width: 50,
                        height: 50,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Icon(Icons.close),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: (() {
                      if (state is RandomFailure) return state.message;
                      if (state is RandomInitial) return CircularProgressIndicator();
                      return Text('error reading state');
                    }()),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
