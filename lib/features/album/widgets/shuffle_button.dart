import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../common/providers/moor_database.dart';
import '../../../common/repository/audio_repository.dart';

class AlbumShuffleButton extends StatelessWidget {
  const AlbumShuffleButton({Key key, @required this.songs})
      : assert(songs != null),
        super(key: key);

  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Center(
        child: RawMaterialButton(
          fillColor: Theme.of(context).buttonColor,
          constraints: const BoxConstraints.tightFor(width: 200, height: 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          onPressed: () {
            songs.shuffle();
            final repository = GetIt.I.get<AudioRepository>();
            repository.start(songs: songs);
          },
          child: Text('Shuffle', style: Theme.of(context).textTheme.headline6),
        ),
      ),
    );
  }
}