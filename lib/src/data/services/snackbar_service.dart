import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';

class SnackbarService {
  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
      String message) {
       final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white),
          SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: kPrimaryColor,
      behavior:
          SnackBarBehavior.floating, // Makes the Snackbar float above the UI
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(16), // Adds margin to make it more aesthetic
      duration: Duration(seconds: 4), // Duration the Snackbar is visible
      action: SnackBarAction(
        label: 'DISMISS',
        textColor: Colors.white,
        onPressed: () {
          // Do something when the action is clicked, if needed
        },
      ),
    );
    log(scaffoldMessengerKey.currentState!.mounted.toString());
    return scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
  }
}