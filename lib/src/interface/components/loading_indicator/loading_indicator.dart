import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingAnimation extends StatelessWidget {
  final double size;

  const LoadingAnimation({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.hexagonDots(
      color: kPrimaryColor,
      size: size,
    );
  }
}
