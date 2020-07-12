import 'package:flutter/material.dart';

class SearchBarLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: ListTile(
          leading: Icon(Icons.search),
          title: Text('Search'),
          onTap: () =>
              Navigator.of(context, rootNavigator: true).pushNamed('/search'),
          trailing: RawMaterialButton(
            shape: CircleBorder(),
            constraints: BoxConstraints.tightFor(width: 50, height: 50),
            child: Icon(Icons.settings),
            onPressed: () => Navigator.of(context, rootNavigator: true)
                .pushNamed('/settings'),
          ),
        ),
      ),
    );
  }
}
