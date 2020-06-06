import 'package:airstream/models/airstream_base_model.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/widgets/titled_art_card.dart';
import 'package:flutter/material.dart';

class SliverCardGrid extends StatelessWidget {
  final List<AirstreamBaseModel> modelList;

  SliverCardGrid({@required this.modelList});

  Function _getFunction(BuildContext context, AirstreamBaseModel model) {
    if (model is Album)
      return () =>
          Navigator.of(context).pushNamed('library/singleAlbum', arguments: model);
    if (model is Artist)
      return () =>
          Navigator.of(context).pushNamed('library/singleArtist', arguments: model);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 30.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200.0,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 2.0,
          childAspectRatio: 1 / 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, int index) {
            final model = modelList[index];
            return TitledArtCard(
              artId: model.coverArt,
              title: model.name,
              subtitle: model is Album ? model.artistName : null,
              onTap: _getFunction(context, model),
            );
          },
          childCount: modelList.length,
        ),
      ),
    );
  }
}
