import 'package:flutter/material.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/my_subscription.dart';

class UpgradeDialog extends StatelessWidget {
  const UpgradeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/pngs/upgrade.png',
              height: 80,
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              'Upgrade required !',
            ),
            const SizedBox(height: 8),

            // Subtitle
            const SizedBox(
              child: Text(
                'Please upgrade to premium to access this feature',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customButton(
                      labelColor: Colors.black,
                      sideColor: const Color(0xFFF2F2F7),
                      buttonColor: const Color(0xFFF2F2F7),
                      label: 'Cancel',
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )),
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customButton(
                      fontSize: 12,
                      label: 'Upgrade',
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MySubscriptionPage(),
                            ));
                      }),
                ))
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build buttons
}
