import 'dart:async';

import 'package:airstream/bloc/nav_bar_bloc.dart';
import 'package:airstream/events/nav_bar_event.dart';
import 'package:airstream/states/nav_bar_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AirstreamNavBar extends StatelessWidget {
  final PageController pageController;
  final GlobalKey<NavigatorState> libNavKey;

  const AirstreamNavBar({Key key, this.pageController, this.libNavKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBarBloc, NavigationBarState>(
      builder: (context, state) {
        final currentIndex = state is NavigationBarLoaded ? state.index : null;
        return BottomAppBar(
          shape: state is NavigationBarLoaded && state.musicPlaying
              ? CircularNotchedRectangle()
              : null,
          child: AnimatedContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            duration: Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            height: state is NavigationBarLoaded ? state.barHeight : 60,
            child: GestureDetector(
              onVerticalDragStart: (details) => context.bloc<NavigationBarBloc>().add(
                    NavigationBarDrag(
                      MediaQuery.of(context).size.height - details.globalPosition.dy,
                    ),
                  ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _AirstreamBottomBarIcon(
                        iconData: Icons.playlist_play,
                        title: 'Playlists',
                        selectedIndex: currentIndex,
                        index: 0,
                      ),
                      _AirstreamBottomBarIcon(
                        iconData: Icons.person,
                        title: 'Artists',
                        selectedIndex: currentIndex,
                        index: 1,
                      ),
                      Container(
                        width: 70,
                        height: 60,
                        color: Colors.transparent,
                      ),
                      _AirstreamBottomBarIcon(
                        iconData: Icons.album,
                        title: 'Albums',
                        selectedIndex: currentIndex,
                        index: 2,
                      ),
                      _AirstreamBottomBarIcon(
                        iconData: Icons.star,
                        title: 'Starred',
                        selectedIndex: currentIndex,
                        index: 3,
                      ),
                    ],
                  ),
                  FutureBuilder(
                    initialData: false,
                    future: state is NavigationBarLoaded && state.barHeight > 60
                        ? Future.delayed(Duration(milliseconds: 400), () => true)
                        : Future.delayed(Duration(), () => false),
                    builder: (context, snapshot) {
                      return Visibility(
                        visible: snapshot.data,
                        child: _SearchBar(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AirstreamBottomBarIcon extends StatelessWidget {
  final IconData iconData;
  final String title;
  final int selectedIndex;
  final int index;

  const _AirstreamBottomBarIcon(
      {this.iconData, this.title, this.selectedIndex, this.index});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 60,
        child: InkWell(
					onTap: () =>
							context.bloc<NavigationBarBloc>().add(NavigationBarNavigate(index)),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							Icon(
								iconData,
								color: selectedIndex == index
										? Theme
										.of(context)
										.accentColor
										: Theme
										.of(context)
										.disabledColor,
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

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: ListTile(
                leading: Icon(Icons.search),
                title: Text('Search'),
                onTap: () =>
                    Navigator.of(context, rootNavigator: true).pushNamed('/search'),
                trailing: IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pushNamed('/settings'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
