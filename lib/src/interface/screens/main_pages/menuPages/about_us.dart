import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/pngs/aboutus1.png'),
            SizedBox(height: 16),
            SizedBox(height: 8),
            Text(
              '''The Hindu Economic Forum is a non-profit, non-political Hindu organisation. The Hindu Economic Forum has been created to share and protect the Hindu business class.

The forum will be serving as a collaborative platform, it unites entrepreneurs, industrialists, professionals, technocrats, investors, bankers, traders, and more to share tangible wealth, knowledge, expertise, and vital information.''',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            SizedBox(height: 16),
            // Image.network('https://placehold.co/600x400/png'),
          ],
        ),
      ),
    );
  }
}
