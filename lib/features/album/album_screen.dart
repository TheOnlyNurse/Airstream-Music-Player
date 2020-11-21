import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../common/error/widgets/error_widgets.dart';
import '../../common/models/image_adapter.dart';
import '../../common/providers/moor_database.dart';
import '../../common/repository/artist_repository.dart';
import '../../common/repository/audio_repository.dart';
import '../../common/selection_bar/bloc/selection_bar_cubit.dart';
import '../../common/selection_bar/sliver_selection_bar.dart';
import '../../common/song_list/sliver_song_list.dart';
import '../../common/widgets/flexible_image_with_title.dart';
import '../../common/widgets/future_button.dart';
import '../../global_assets.dart';
import 'bloc/album_cubit.dart';

part 'widgets/more_options.dart';
part 'widgets/shuffle_button.dart';
part 'widgets/star_button.dart';
part 'widgets/success.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({
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
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SingleAlbumSuccess) {
          return BlocProvider(
            create: (context) => SelectionBarCubit(),
            child: _Success(state, cubit: cubit),
          );
        }

        if (state is SingleAlbumError) {
          return const Center(child: Text('TODO: proper error screen'));
        }

        return StateErrorScreen(message: state.toString());
      },
    );
  }
}






