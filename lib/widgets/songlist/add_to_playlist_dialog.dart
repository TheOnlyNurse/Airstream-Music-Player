import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:flutter/material.dart';

class AddToPlaylistDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Select playlist'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      children: [
        SizedBox(
          height: 250,
          width: 50,
          child: FutureBuilder(
            future: Repository().playlist.library(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final ProviderResponse response = snapshot.data;
                if (response.status == DataStatus.ok) {
                  final List<Playlist> playlists = response.data;

                  return ListView.builder(
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(playlists[index].name),
                        onTap: () => Navigator.pop(context, playlists[index]),
                      );
                    },
                  );
                }

                return Center(child: response.message);
              }

              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RawMaterialButton(
              fillColor: Theme.of(context).primaryColor,
              onPressed: null,
              child: Text('New', style: Theme.of(context).textTheme.subtitle2),
            ),
          ],
        )
      ],
    );
  }
}
