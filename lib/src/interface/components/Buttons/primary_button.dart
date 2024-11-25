
import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';

Widget customButton(
    {required String label,
    required VoidCallback onPressed,
    Color sideColor = kPrimaryColor,
    Color labelColor = Colors.white,
    int fontSize = 16,
    int buttonHeight = 45,
    Color buttonColor = kPrimaryColor}) {
  return SizedBox(
    height: buttonHeight.toDouble(),
    width: double.infinity,
    child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(buttonColor),
          backgroundColor: WidgetStateProperty.all<Color>(buttonColor),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: BorderSide(color: sideColor),
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: labelColor, fontSize: double.parse(fontSize.toString())),
        )),
  );
}
