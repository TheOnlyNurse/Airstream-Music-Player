import 'package:airstream/barrel/repository_subdivision_tools.dart';
import 'package:airstream/bloc/song_list_bloc.dart';
import 'package:airstream/widgets/songlist/song_list.dart';
import 'package:flutter/material.dart';

class QueueDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return SimpleDialog(
      title: Text('Queue', style: Theme.of(context).textTheme.headline6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      children: <Widget>[
        SizedBox(
          height: media.height - 200,
          width: media.width - 50,
          child: SongList(
            type: SongListType.musicQueue,
            typeValue: Repository().audio.queue,
          ),
        )
      ],
    );
  }
}
