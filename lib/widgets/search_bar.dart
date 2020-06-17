import 'package:flutter/material.dart';

class SearchBarLink extends StatelessWidget {
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
                color: Theme.of(context).cardColor,
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
