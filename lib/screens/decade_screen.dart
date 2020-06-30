import 'package:airstream/data_providers/repository/repository.dart';
import 'package:airstream/models/response/album_response.dart';
import 'package:airstream/widgets/sliver_close_bar.dart';
import 'package:flutter/material.dart';

class DecadeScreen extends StatefulWidget {
  const DecadeScreen();

  @override
  _DecadeScreenState createState() => _DecadeScreenState();
}

class _DecadeScreenState extends State<DecadeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: Repository().album.decades(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final AlbumResponse response = snapshot.data;

              if (response.hasData) {
                final List<int> decadesAvailable = response.decades;
                return CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: <Widget>[
                    SliverCloseBar(),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _DecadeCard(
                            decade: decadesAvailable[index],
                            index: index,
                          );
												},
												childCount: decadesAvailable.length,
											),
										),
									],
								);
							}

							return Center(child: response.message);
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _DecadeCard extends StatelessWidget {
  const _DecadeCard({Key key, this.decade, this.index}) : super(key: key);

  final int decade;
  final int index;

  Color _iterateThroughColors() {
    final colors = Colors.primaries;
    final evenDivisions = index ~/ colors.length;
    if (evenDivisions == 0) return colors[index][800];
    final adjustedIndex = index - evenDivisions * colors.length;
    return colors[adjustedIndex][800];
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headline4;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          'library/albumList',
          arguments: () => Repository().album.decade(decade),
        ),
        child: Container(
          height: 250,
          decoration: BoxDecoration(
            color: _iterateThroughColors(),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text('$decade\'s', style: style),
          ),
        ),
      ),
    );
  }
}
