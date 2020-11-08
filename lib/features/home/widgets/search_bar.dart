import 'package:flutter/material.dart';

class SearchBarLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: ListTile(
          leading: const Icon(Icons.search),
          title: const Text('Search'),
          onTap: () =>
              Navigator.of(context, rootNavigator: true).pushNamed('/search'),
          trailing: RawMaterialButton(
            shape: const CircleBorder(),
            constraints: const BoxConstraints.tightFor(width: 50, height: 50),
            onPressed: () => Navigator.of(context, rootNavigator: true)
                .pushNamed('/settings'),
            child: const Icon(Icons.settings),
          ),
        ),
      ),
    );
  }
}
