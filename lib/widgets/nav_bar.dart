import 'package:airstream/bloc/nav_bar_bloc.dart';
import 'package:airstream/events/nav_bar_event.dart';
import 'package:airstream/states/nav_bar_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AirstreamNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBarBloc, NavigationBarState>(
      builder: (context, state) {
        if (state is HomePage) {
          return BottomAppBar(
            shape: CircularNotchedRectangle(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  AirstreamBottomBarIcon(
                    iconData: Icons.playlist_play,
                    title: 'Playlists',
                    selectedIndex: state.index,
                    index: 0,
                  ),
                  AirstreamBottomBarIcon(
                    iconData: Icons.person,
                    title: 'Artists',
                    selectedIndex: state.index,
                    index: 1,
                  ),
                  Spacer(),
                  AirstreamBottomBarIcon(
                    iconData: Icons.album,
                    title: 'Albums',
                    selectedIndex: state.index,
                    index: 2,
                  ),
                  AirstreamBottomBarIcon(
                    iconData: Icons.star,
                    title: 'Starred',
                    selectedIndex: state.index,
                    index: 3,
                  ),
                ],
              ),
            ),
          );
        }
        return Center(
          child: Text('Couldn\'t render current navigation state.'),
        );
      },
    );
  }
}

class AirstreamBottomBarIcon extends StatelessWidget {
  final IconData iconData;
  final String title;
  final int selectedIndex;
  final int index;

  const AirstreamBottomBarIcon(
      {this.iconData, this.title, this.selectedIndex, this.index});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 60.0,
        child: InkWell(
          onTap: () =>
              context.bloc<NavigationBarBloc>().add(NavigateToPage(index: index)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                iconData,
                color: selectedIndex == index
                    ? Theme.of(context).accentColor
                    : Theme.of(context).disabledColor,
              ),
              if (selectedIndex == index)
                Text(title, style: TextStyle(color: Theme.of(context).accentColor)),
            ],
          ),
        ),
      ),
    );
  }
}
