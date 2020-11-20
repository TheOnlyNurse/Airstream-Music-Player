import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Internal
import 'bloc/navigation_bar_bloc.dart';

class NavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBarBloc, NavigationBarState>(
      builder: (context, state) {
        return BottomAppBar(
          shape: state.isNotched ? const CircularNotchedRectangle() : null,
          elevation: 0,
          color: Theme.of(context).bottomAppBarColor.withOpacity(0.3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _IconButton(
                    iconData: Icons.home,
                    caption: 'Home',
                    assignedIndex: 0,
                    currentIndex: state.pageIndex,
                  ),
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.bounceOut,
                    width: state.isNotched ? 100 : 0,
                  ),
                  _IconButton(
                    iconData: Icons.star,
                    caption: 'Starred',
                    assignedIndex: 1,
                    currentIndex: state.pageIndex,
                  ),
                ],
              ),
              if (state.isOffline) _OfflineBanner(),
            ],
          ),
        );
      },
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData iconData;
  final String caption;
  final int assignedIndex;
  final int currentIndex;
  final Function(int) onTap;
  final double height;

  const _IconButton({
    Key key,
    @required this.iconData,
    @required this.caption,
    this.height = 60,
    this.assignedIndex,
    this.currentIndex = 1,
    this.onTap,
  })  : assert(iconData != null),
        assert(caption != null),
        super(key: key);

  Color _color(BuildContext context) {
    if (assignedIndex == currentIndex) {
      return Theme.of(context).accentColor;
    } else {
      return Theme.of(context).disabledColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: height,
        child: InkWell(
          onTap: () {
            context.read<NavigationBarBloc>().add(
                  NavigationBarTapped(index: assignedIndex),
                );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(iconData, color: _color(context)),
              Text(caption, style: TextStyle(color: _color(context))),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 20,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Text('OFFLINE MODE', style: theme.textTheme.subtitle2),
      ),
    );
  }
}
