part of '../screen.dart';

class _ShuffleButton extends StatelessWidget {
  const _ShuffleButton({Key key, @required this.songs})
      : assert(songs != null),
        super(key: key);

  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Center(
        child: RawMaterialButton(
          fillColor: Theme.of(context).buttonColor,
          constraints: const BoxConstraints.tightFor(width: 200, height: 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          onPressed: () {
            songs.shuffle();
            Repository().audio.start(playlist: songs);
          },
          child: Text('Shuffle', style: Theme.of(context).textTheme.headline6),
        ),
      ),
    );
  }
}