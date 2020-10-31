/// External Packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Internal Links
import '../data_providers/moor_database.dart';
import '../models/image_adapter.dart';
import '../models/song_list_delegate.dart';
import '../complex_widgets/airstream_image.dart';
import '../complex_widgets/song_list/song_list.dart';
import '../cubit/single_album_cubit.dart';
import '../complex_widgets/error_widgets.dart';

class SingleAlbumScreen extends StatelessWidget {
  const SingleAlbumScreen({
    Key key,
    @required this.album,
    @required this.cubit,
  })  : assert(album != null),
        assert(cubit != null),
        super(key: key);

  final Album album;
  final SingleAlbumCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SingleAlbumCubit, SingleAlbumState>(
      cubit: cubit,
      builder: (_, state) {
        return NoStateErrorScreen(state: state.toString());
      },
    );
  }
}
