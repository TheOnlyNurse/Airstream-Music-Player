import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/circle_close_button.dart';
import '../bloc/selection_bar_cubit.dart';

class SelectionTitle extends StatelessWidget {
  const SelectionTitle({Key key, @required this.state})
      : assert(state != null),
        super(key: key);
  final SelectionBarActive state;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          stops: const [0.4, 1],
          colors: [Theme.of(context).cardColor, Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleCloseButton(
            onPressed: () => context.read<SelectionBarCubit>().clear(),
          ),
          const SizedBox(width: 8),
          Text('${state.selected.length} selected'),
          const SizedBox(width: 50),
        ],
      ),
    );
  }
}
