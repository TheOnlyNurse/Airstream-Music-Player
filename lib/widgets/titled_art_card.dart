import 'package:airstream/widgets/airstream_image.dart';
import 'package:flutter/material.dart';

class TitledArtCard extends StatelessWidget {
  final String artId;
  final String title;
  final String subtitle;
  final Function onTap;

  TitledArtCard({
    @required this.artId,
    @required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: <Widget>[
              AirstreamImage(
                  height: constraints.maxHeight - 50,
                  width: constraints.maxWidth,
                  coverArt: artId),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        title,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.caption,
                          maxLines: 1,
                          softWrap: false,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
