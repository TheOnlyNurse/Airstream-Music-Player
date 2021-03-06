import 'dart:io';
import 'package:airstream/models/image_adapter.dart';
import 'package:airstream/repository/image_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AirstreamImage extends StatelessWidget {
  const AirstreamImage({
    Key key,
    this.adapter,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
  }) : super(key: key);

  final ImageAdapter adapter;
  final BoxFit fit;
  final double height;
  final double width;

  /// Returns the empty widget when file is null.
  Widget _getChild(File image) {
    if (image != null) {
      return Image.file(image, height: height, width: width, fit: fit);
    } else {
      return _EmptyImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: adapter.resolve(GetIt.I.get<ImageRepository>()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (adapter.shouldAnimate) {
            return _AnimatedImage(child: _getChild(snapshot.data));
          } else {
            return _getChild(snapshot.data);
          }
        }

        return SizedBox.expand(
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _AnimatedImage extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _AnimatedImage({
    Key key,
    this.duration = const Duration(seconds: 1),
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  @override
  __AnimatedImageState createState() => __AnimatedImageState();
}

class __AnimatedImageState extends State<_AnimatedImage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..forward(from: 0);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

class _EmptyImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Image.asset('lib/graphics/album.png', fit: BoxFit.contain),
    );
  }
}
