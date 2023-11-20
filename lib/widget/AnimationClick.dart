import 'package:flutter/material.dart';

class AnimationClick extends StatefulWidget {
  const AnimationClick({Key? key, required this.child, this.function, this.opacity = 0.2})
      : super(key: key);
  final Widget child;
  final Function? function;
  final double opacity;
  @override
  _AnimationClickState createState() => _AnimationClickState();
}

class _AnimationClickState extends State<AnimationClick> {
  double opacity = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) {
        opacity = widget.opacity;
        setState(() {});
      },
      onPanCancel: widget.function != null
          ? () {
              opacity = 1.0;
              setState(() {});
              widget.function!();
            }
          : () {
              opacity = 1.0;
              setState(() {});
            },
      onTapCancel: () {
        opacity = 1.0;
        setState(() {});
      },
      child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: opacity,
          child: widget.child),
    );
  }
}
