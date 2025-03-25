import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Terms & Conditions',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: RichText(
          text: const TextSpan(
            style: TextStyle(
                fontSize: 16, color: Colors.black), // Default style for body
            children: [
              TextSpan(
                text: '1. Acceptance of Terms\n',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold), // Style for heading
              ),
              TextSpan(
                text:
                    'By accessing and using the HEF app, you acknowledge that you have read, understood, and agree to be bound by these Terms, as well as our Privacy Policy. These Terms apply to all users of the App.\n\n',
              ),
              TextSpan(
                text: '2. Changes to Terms\n',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold), // Style for heading
              ),
              TextSpan(
                text:
                    'We reserve the right to modify or update these Terms at any time. Any changes will be effective immediately upon posting. Continued use of the App after any such changes constitutes your acceptance of the new Terms. It is your responsibility to review these Terms periodically.\n\n',
              ),
              TextSpan(
                text: '3. User Accounts\n',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold), // Style for heading
              ),
              TextSpan(
                text:
                    'To access certain features of the App, you may be required to create an account. You agree to provide accurate, current, and complete information when creating your account. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.\n\n',
              ),
              TextSpan(
                text: '4. Use of the App\n',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold), // Style for heading
              ),
              TextSpan(
                text:
                    '''The App is intended for personal, non-commercial use only. You agree not to use the App for any unlawful or prohibited purpose, including but not limited to:.\n\nEngaging in fraudulent activities.
-Harassing or threatening other users.
-Uploading, sharing, or distributing any content that is offensive, defamatory, or
-infringing on intellectual property rights.
-Attempting to gain unauthorized access to the App, other user accounts, or our systems.\n\n
''',
              ),
              TextSpan(
                text: '5. Intellectual Property\n',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold), // Style for heading
              ),
              TextSpan(
                text:
                    '''All content, trademarks, logos, and intellectual property related to the App are owned by or licensed to HEF. You may not reproduce, distribute, or otherwise exploit the content for commercial purposes without written consent from HEF.
''',
              ),
              TextSpan(
                text: '6. Privacy Policy\n',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold), // Style for heading
              ),
              TextSpan(
                text:
                    '''Your use of the App is also governed by our Privacy Policy, which outlines how we collect, use, and protect your personal information. By using the App, you consent to the collection and use of your data as outlined in the Privacy Policy.\n\n''',
              ),
              TextSpan(
                text: '7. Termination\n',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold), // Style for heading
              ),
              TextSpan(
                text:
                    '''We reserve the right to suspend or terminate your account and access to the App at our sole discretion, without notice or liability, for any reason, including but not limited to a violation of these Terms.\n\n''',
              ),
              TextSpan(
                text: '8. Limitation of Liability\n',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold), // Style for heading
              ),
              TextSpan(
                text:
                    '''HEF is not liable for any direct, indirect, incidental, or consequential damages arising from your use or inability to use the App. The App is provided on an "as-is" and "as available" basis without warranties of any kind.\n\n''',
              ),
              TextSpan(
                text: '9. Governing Law\n',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold), // Style for heading
              ),
              TextSpan(
                text:
                    '''These Terms shall be governed by and construed in accordance with the laws of [Your Jurisdiction], without regard to its conflict of law principles.\n\n''',
              ),
              TextSpan(
                text: '10. Contact Information\n',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold), // Style for heading
              ),
              TextSpan(
                text:
                    '''For any questions regarding these Terms, please contact us at mail@skybertech.com\n\n''',
              ),
              // Add the rest of the sections similarly
            ],
          ),
        )),
      ),
    );
  }
}
