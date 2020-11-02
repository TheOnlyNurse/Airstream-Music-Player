library single_album;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// Internal
import '../models/image_adapter.dart';
import 'bloc/cubit.dart';
import '../complex_widgets/error_widgets.dart';
import '../static_assets.dart';
import '../widgets/flexible_image_with_title.dart';
import '../widgets/circle_close_button.dart';
import '../complex_widgets/song_list/sliver_song_list.dart';
import '../providers/moor_database.dart';
import '../repository/artist_repository.dart';
import '../widgets/future_button.dart';
import '../providers/repository/repository.dart';

/// Library
part 'widgets/more_options.dart';
part 'widgets/star_button.dart';
part 'widgets/shuffle_button.dart';
part 'widgets/success.dart';

class SingleAlbumScreen extends StatelessWidget {
  const SingleAlbumScreen({
    Key key,
    @required this.cubit,
  })  : assert(cubit != null),
        super(key: key);

  final SingleAlbumCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SingleAlbumCubit, SingleAlbumState>(
      cubit: cubit,
      builder: (_, state) {
        if (state is SingleAlbumInitial) {
          return Center(child: CircularProgressIndicator());
        }

        if (state is SingleAlbumSuccess) {
          return _Success(state, cubit: cubit);
        }

        if (state is SingleAlbumError) {
          return Center(child: Text('TODO: proper error screen'));
        }

        return NoStateErrorScreen(message: state.toString());
      },
    );
  }
}






