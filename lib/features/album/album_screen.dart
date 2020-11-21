import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/error/widgets/error_widgets.dart';
import '../../common/selection_bar/bloc/selection_bar_cubit.dart';
import 'bloc/album_cubit.dart';

import 'widgets/success_screen.dart';

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
            child: AlbumSuccessScreen(state, cubit: cubit),
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






