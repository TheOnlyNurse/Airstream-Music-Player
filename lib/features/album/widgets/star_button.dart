import 'package:flutter/material.dart';

import '../bloc/album_cubit.dart';

class AlbumStarButton extends StatefulWidget {
  const AlbumStarButton({Key key, this.isStarred = false, @required this.cubit})
      : assert(cubit != null),
        super(key: key);

  final bool isStarred;
  final SingleAlbumCubit cubit;

  @override
  _AlbumStarButtonState createState() => _AlbumStarButtonState();
}

class _AlbumStarButtonState extends State<AlbumStarButton> {
  bool isStarred;

  @override
  void initState() {
    isStarred = widget.isStarred;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: const BoxConstraints.tightFor(height: 55, width: 55),
      shape: const CircleBorder(),
      onPressed: () {
        final newStarred = !isStarred;
        widget.cubit.change(isStarred: newStarred);
        setState(() => isStarred = newStarred);
      },
      child: Icon(isStarred ? Icons.star : Icons.star_border),
    );
  }
}