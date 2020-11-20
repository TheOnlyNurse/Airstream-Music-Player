part of '../sliver_selection_bar.dart';

class _SelectionTitle extends StatelessWidget {
  const _SelectionTitle({Key key, @required this.state})
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
