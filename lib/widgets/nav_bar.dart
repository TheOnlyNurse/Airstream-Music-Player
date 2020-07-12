import 'package:airstream/bloc/nav_bar_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationBar extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const NavigationBar({Key key, this.onTap, this.index = 0}) : super(key: key);

  NotchedShape _getShape(NavigationBarState state) {
    if (state is NavigationBarSuccess && state.isNotched) {
      return CircularNotchedRectangle();
    } else {
      return null;
    }
  }

  double _spacerWidth(NavigationBarState state) {
    return state is NavigationBarSuccess && state.isNotched ? 100 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBarBloc, NavigationBarState>(
      builder: (context, state) {
        return BottomAppBar(
          shape: _getShape(state),
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
                    currentIndex: index,
                    onTap: onTap,
                  ),
                  AnimatedContainer(
                    duration: Duration(seconds: 1),
                    curve: Curves.bounceOut,
                    width: _spacerWidth(state),
                  ),
                  _IconButton(
                    iconData: Icons.star,
                    caption: 'Starred',
                    assignedIndex: 1,
                    currentIndex: index,
                    onTap: onTap,
                  ),
                ],
              ),
              if (state is NavigationBarSuccess && state.isOffline)
                _OfflineBanner(),
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
		this.iconData,
		this.caption,
		this.height = 60,
		this.assignedIndex = 0,
		this.currentIndex = 1,
		this.onTap,
	})
			: assert(iconData != null),
				assert(caption != null),
				super(key: key);

	Color _color(BuildContext context) {
		if (assignedIndex == currentIndex) {
			return Theme
					.of(context)
					.accentColor;
		} else {
			return Theme
					.of(context)
					.disabledColor;
		}
	}

	Widget build(BuildContext context) {
		return Expanded(
			child: SizedBox(
				height: height,
				child: InkWell(
					onTap: () => onTap != null ? onTap(assignedIndex) : null,
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
			width: MediaQuery
					.of(context)
					.size
					.width,
			child: Center(
				child: Text('OFFLINE MODE', style: theme.textTheme.subtitle2),
			),
		);
	}
}
