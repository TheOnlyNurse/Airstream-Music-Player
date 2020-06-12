import 'package:airstream/bloc/airstream_collage_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AirstreamCollage extends StatelessWidget {
  final List<int> artistIdList;
  final int columns;
  final int rows;
  final BoxFit fit;

  const AirstreamCollage({
    Key key,
    this.artistIdList,
    this.columns = 2,
    this.rows = 2,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AirstreamCollageBloc()..add(FetchCollage(artistIdList)),
      child: BlocBuilder<AirstreamCollageBloc, AirstreamCollageState>(
          builder: (context, state) {
        if (state is CollageLoaded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                children: List.generate(state.imageList.length, (index) {
                  return Image.file(
                    state.imageList[index],
                    width: constraints.maxWidth / columns,
                    height: constraints.maxHeight / rows,
                    fit: fit,
                  );
                }),
              );
            },
          );
        }
        if (state is CollageUninitialised) {
          return Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset('lib/graphics/album.png'),
        );
      }),
    );
  }
}
