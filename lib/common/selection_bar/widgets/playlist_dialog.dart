import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../global_assets.dart';
import '../../models/playlist_model.dart';
import '../bloc/playlist_dialog_cubit.dart';

class PlaylistDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Select playlist'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Theme.of(context).cardColor,
      children: [
        SizedBox(
          height: 250,
          width: 50,
          child: BlocBuilder<PlaylistDialogCubit, PlaylistDialogState>(
            builder: (context, state) {
              if (state is PlaylistDialogSuccess) {
                return Column(
                  children: <Widget>[
                    SizedBox(
                      height: 220,
                      child: _PlaylistOptions(playlists: state.playlists),
                    ),
                    _Indicator(currentIndex: state.index),
                  ],
                );
              }

              if (state is PlaylistDialogComplete) {
                Future.delayed(
                  const Duration(milliseconds: 500),
                  () => Navigator.pop(context, state.playlist),
                );
                return const Center(
                  child: Icon(Icons.check, color: Colors.green, size: 60),
                );
              }

              if (state is PlaylistDialogFailure) {
                return Center(child: Text(state.response.error));
              }

              if (state is PlaylistDialogInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              return const Center(child: Text('Could not read state'));
            },
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
    final _allowedText = <TextInputFormatter>[
      FilteringTextInputFormatter(RegExp("[a-zA-z ]"), allow: true),
    ];

    return PageView(
      onPageChanged: context.read<PlaylistDialogCubit>().pageChange,
      physics: WidgetProperties.scrollPhysics,
      children: <Widget>[
        // Current playlists
        ListView.builder(
          itemCount: playlists.length,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          physics: WidgetProperties.scrollPhysics,
          itemBuilder: (context, index) {
            return Card(
              color: Theme.of(context).primaryColor,
              child: ListTile(
                title: Text(playlists[index].name),
                onTap: () {
                  context.read<PlaylistDialogCubit>().selected(playlists[index]);
                },
              ),
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
                inputFormatters: _allowedText,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                inputFormatters: _allowedText,
                decoration: const InputDecoration(
                  labelText: 'Comment',
                ),
              ),
              const SizedBox(height: 20),
              RawMaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                fillColor: Theme.of(context).primaryColor,
                onPressed: () => context.read<PlaylistDialogCubit>().create(
                      _nameController.value.text,
                      _commentController.value.text,
                    ),
                child: const Text('Create'),
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
    Widget circle({bool isActive}) {
      final theme = Theme.of(context);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        height: isActive ? 12 : 8,
        width: isActive ? 12 : 8,
        decoration: BoxDecoration(
            color: isActive ? theme.accentColor : theme.disabledColor,
            borderRadius: const BorderRadius.all(Radius.circular(12))),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          circle(isActive: currentIndex == 0),
          circle(isActive: currentIndex == 1),
        ],
      ),
    );
  }
}
