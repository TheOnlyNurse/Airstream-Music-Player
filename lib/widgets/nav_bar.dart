import 'package:airstream/bloc/nav_bar_bloc.dart';
import 'package:airstream/events/nav_bar_event.dart';
import 'package:airstream/states/nav_bar_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationBar extends StatelessWidget {
  static const buttonList = [
    _IconButton(iconData: Icons.home, title: 'Home'),
    _IconButton(iconData: Icons.star, title: 'Starred'),
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> _generateButtons(
        BuildContext context, NavigationBarState state) {
      void bloc(NavigationBarEvent event) {
        context.bloc<NavigationBarBloc>().add(event);
      }

      final widgetList = <Widget>[];
      final selectedIndex = state is NavigationBarSuccess ? state.index : 0;
      for (int index = 0; index < buttonList.length; index++) {
        final isSelected = index == selectedIndex;
        final color = isSelected
            ? Theme.of(context).accentColor
            : Theme.of(context).disabledColor;
        final onTap = () => bloc(NavigationBarNavigate(index));

        widgetList.add(buttonList[index].build(color, onTap));
      }
      if (state is NavigationBarSuccess && state.isNotched) {
        widgetList.insert(buttonList.length >> 1, Spacer());
      }
      return widgetList;
    }

    NotchedShape _getShape(NavigationBarState state) {
      if (state is NavigationBarSuccess && state.isNotched) {
        return CircularNotchedRectangle();
      } else {
        return null;
      }
    }

    Widget _getOfflineBanner(NavigationBarState state) {
      if (state is NavigationBarSuccess && state.isOffline) {
        final theme = Theme.of(context);

        return Container(
          height: 20,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                theme.cardColor,
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Text(
              'Offline mode',
              style: theme.textTheme.subtitle2,
            ),
          ),
        );
      } else {
        return Container();
      }
    }

    return BlocBuilder<NavigationBarBloc, NavigationBarState>(
      builder: (context, state) {
        return BottomAppBar(
          shape: _getShape(state),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _generateButtons(context, state),
              ),
              _getOfflineBanner(state),
            ],
          ),
        );
      },
    );
  }
}

class _IconButton {
	const _IconButton({
		@required this.iconData,
		@required this.title,
		this.height = 60.0,
	}) : assert(iconData != null && title != null);

	final IconData iconData;
	final String title;
	final double height;

	Widget build(Color color, Function onTap) {
		return Expanded(
			child: SizedBox(
				height: height,
				child: InkWell(
					onTap: onTap,
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							Icon(iconData, color: color),
							Text(title, style: TextStyle(color: color)),
						],
					),
				),
			),
		);
	}
}
