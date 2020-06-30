import 'package:airstream/data_providers/repository/repository.dart';
import 'package:airstream/bloc/song_list_bloc.dart';
import 'package:airstream/widgets/songlist/song_list.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class QueueDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return SimpleDialog(
			title: Text('Queue', style: Theme.of(context).textTheme.headline5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      children: <Widget>[
        SizedBox(
          height: math.max(media.height - 300, 250),
          width: math.max(media.height - 50, 250),
          child: SongList(
            type: SongListType.musicQueue,
            typeValue: Repository().audio.queue,
          ),
        )
      ],
    );
  }
}
