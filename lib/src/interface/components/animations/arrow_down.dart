import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';

class BlinkingFloatingArrow extends StatefulWidget {
  const BlinkingFloatingArrow({Key? key}) : super(key: key);

  @override
  _BlinkingFloatingArrowState createState() => _BlinkingFloatingArrowState();
}

class _BlinkingFloatingArrowState extends State<BlinkingFloatingArrow>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Blinking animation
    _blinkController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _blinkAnimation =
        Tween<double>(begin: 0.3, end: 1.0).animate(_blinkController);

    // Floating animation
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation =
        Tween<double>(begin: 0.0, end: 15.0).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_blinkController, _floatController]),
      builder: (context, child) {
        return Opacity(
          opacity: _blinkAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_downward, size: 48, color: kPrimaryColor),
              ],
            ),
          ),
        );
      },
    );
  }
}
