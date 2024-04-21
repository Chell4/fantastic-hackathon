import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AvatarImage extends StatelessWidget {
  final Uint8List? avatar;
  final double width;

  const AvatarImage({
    Key? key,
    required this.avatar,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      avatar ?? Uint8List(0),
      gaplessPlayback: true,
      width: width,
      height: width,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (BuildContext context, Object obj, StackTrace? e) {
        return Lottie.asset(
          "assets/Cup.json",
          frameRate: const FrameRate(60),
          repeat: true,
          width: width,
          fit: BoxFit.fitWidth,
          onLoaded: (composition) {
            var _gifController;
            _gifController
              ..duration = composition.duration
              ..forward()
              ..repeat();
          },
          filterQuality: FilterQuality.low,
        );
      },
    );
  }
}