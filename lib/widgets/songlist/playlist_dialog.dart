import 'package:airstream/bloc/playlist_dialog.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlaylistDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Select playlist'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      children: [
        SizedBox(
          height: 250,
          width: 50,
          child: BlocProvider(
            create: (context) => PlaylistDialogBloc()..add(PlaylistDialogFetch()),
            child: BlocBuilder<PlaylistDialogBloc, PlaylistDialogState>(
              builder: (context, state) {
                if (state is PlaylistDialogSuccess) {
                  return Column(
                    children: <Widget>[
                      SizedBox(
                        height: 230,
                        child: _PlaylistOptions(playlists: state.playlists),
                      ),
                      _Indicator(currentIndex: state.currentView),
                    ],
                  );
                }

                if (state is PlaylistDialogComplete) {
                  Future.delayed(
                    Duration(milliseconds: 500),
                    () => Navigator.pop(context, state.playlist),
                  );
                  return Center(
                    child: Icon(Icons.check, color: Colors.green, size: 60),
                  );
                }

                if (state is PlaylistDialogFailure) {
                  return Center(child: state.message);
                }

                if (state is PlaylistDialogInitial) {
                  return Center(child: CircularProgressIndicator());
                }

                return Center(child: Text('Could not read state'));
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaylistOptions extends StatelessWidget {
  const _PlaylistOptions({Key key, @required this.playlists})
      : assert(playlists != null),
        super(key: key);

  final List<Playlist> playlists;

  @override
  Widget build(BuildContext context) {
    final _nameController = TextEditingController();
    final _commentController = TextEditingController();
    void dialogBloc(PlaylistDialogEvent event) =>
        context.bloc<PlaylistDialogBloc>().add(event);

    return PageView(
      onPageChanged: (index) =>
          context.bloc<PlaylistDialogBloc>().add(
            PlaylistDialogViewChange(index),
          ),
      children: <Widget>[
        // Current playlists
        ListView.builder(
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(playlists[index].name),
              onTap: () => dialogBloc(PlaylistDialogChosen(playlists[index])),
            );
          },
        ),
        // Create new playlist
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _nameController,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Name',
                  counterText: '',
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'Comment',
                ),
              ),
              SizedBox(height: 20),
              RawMaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                fillColor: Theme
                    .of(context)
                    .primaryColor,
                child: Text('Create'),
                onPressed: () =>
                    dialogBloc(PlaylistDialogCreate(
                      _nameController.value.text,
                      _commentController.value.text,
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({Key key, this.currentIndex = 0}) : super(key: key);

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    Widget circleBar(bool isActive) {
      final theme = Theme.of(context);
      return AnimatedContainer(
        duration: Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: 8),
        height: isActive ? 12 : 8,
        width: isActive ? 12 : 8,
        decoration: BoxDecoration(
            color: isActive ? theme.accentColor : theme.disabledColor,
            borderRadius: BorderRadius.all(Radius.circular(12))),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        circleBar(currentIndex == 0),
        circleBar(currentIndex == 1),
      ],
    );
  }
}