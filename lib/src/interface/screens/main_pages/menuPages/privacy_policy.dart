import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Privacy Policy",
          style: TextStyle(fontSize: 15),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Last updated: March 25, 2025',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              _sectionTitle('Introduction'),
              _sectionText(
                  'This Privacy Policy describes Our policies and procedures on the '
                  'collection, use and disclosure of Your information when You use the '
                  'Service and tells You about Your privacy rights and how the law protects You.'),
              SizedBox(height: 16),
              _sectionText(
                  'We use Your Personal data to provide and improve the Service. By using the '
                  'Service, You agree to the collection and use of information in accordance '
                  'with this Privacy Policy.'),
              _sectionTitle('Interpretation and Definitions'),
              _sectionSubtitle('Interpretation'),
              _sectionText(
                  'The words of which the initial letter is capitalized have meanings defined under the following conditions. '
                  'The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.'),
              _sectionSubtitle('Definitions'),
              _sectionText('For the purposes of this Privacy Policy:'),
              _bulletPoint(
                  'Account means a unique account created for You to access our Service or parts of our Service.'),
              _bulletPoint(
                  'Affiliate means an entity that controls, is controlled by or is under common control with a party, '
                  'where "control" means ownership of 50% or more of the shares, equity interest or other securities entitled '
                  'to vote for election of directors or other managing authority.'),
              _bulletPoint(
                  'Application refers to HEF, the software program provided by the Company.'),
              _bulletPoint(
                  'Company refers to Skybertech IT Innovations Pvt Ltd, Infopark Technology Business Centre Sector D, E & F Hall, '
                  'JNI Stadium Complex, Kaloor Kochi, Kerala 682 017, IN.'),
              SizedBox(height: 16),
              _sectionTitle('Collecting and Using Your Personal Data'),
              _sectionSubtitle('Types of Data Collected'),
              _sectionSubtitle('Personal Data'),
              _sectionText(
                  'While using Our Service, We may ask You to provide Us with certain personally identifiable '
                  'information that can be used to contact or identify You. Personally identifiable information may include, but is not limited to:'),
              _bulletPoint('Email address'),
              _bulletPoint('First name and last name'),
              _bulletPoint('Phone number'),
              _bulletPoint('Address, State, Province, ZIP/Postal code, City'),
              SizedBox(height: 16),
              _sectionSubtitle('Usage Data'),
              _sectionText(
                  'Usage Data is collected automatically when using the Service.'),
              _sectionText(
                  'Usage Data may include information such as Your Device\'s Internet Protocol address (e.g. IP address), '
                  'browser type, browser version, the pages of our Service that You visit, the time and date of Your visit, '
                  'the time spent on those pages, unique device identifiers and other diagnostic data.'),
              SizedBox(height: 16),
              // Add more sections following the same pattern...
              _sectionTitle('Contact Us'),
              _sectionText(
                  'If you have any questions about this Privacy Policy, You can contact us:'),
              _bulletPoint('By email: mail@skybertech.com'),
              _bulletPoint(
                  'By visiting this page on our website: www.skybertech.com'),
              _bulletPoint('By phone number: +918138916303'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _sectionSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        subtitle,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
