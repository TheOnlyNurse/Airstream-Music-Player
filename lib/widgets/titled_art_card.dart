import 'package:airstream/widgets/airstream_image.dart';
import 'package:flutter/material.dart';

class TitledArtCard extends StatelessWidget {
  final String artId;
  final String title;
  final String subtitle;
  final Function onTap;

  TitledArtCard({@required this.artId, @required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: <Widget>[
						AirstreamImage(coverArt: artId),
						Column(
							mainAxisAlignment: MainAxisAlignment.end,
							children: <Widget>[
								Container(
									color: Theme
											.of(context)
											.cardColor,
									alignment: Alignment.bottomCenter,
									padding: EdgeInsets.all(8.0),
									child: Column(
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
													style: Theme
															.of(context)
															.textTheme
															.caption,
													maxLines: 1,
													softWrap: false,
												),
										],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
