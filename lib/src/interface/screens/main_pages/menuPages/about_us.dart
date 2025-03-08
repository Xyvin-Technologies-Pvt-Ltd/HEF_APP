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
            Image.asset('assets/aboutus1.png'),
            SizedBox(height: 16),
            SizedBox(height: 8),
            Text(
              '''The Hindu Economic Forum is a non-profit, non-political Hindu organisation. The Hindu Economic Forum has been created to share and protect the Hindu business class.

The forum will be serving as a collaborative platform, it unites entrepreneurs, industrialists, professionals, technocrats, investors, bankers, traders, and more to share tangible wealth, knowledge, expertise, and vital information.''',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.phone, color: Color(0xFF004797)),
                SizedBox(width: 10),
                Text('8078955514', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.email, color: Color(0xFF004797)),
                SizedBox(width: 10),
                Text('kssiatrisur@gmail.com', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: Color(0xFF004797)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '''
Kerala State Small Industries Association Thrissur,
KSSIA Building, Patturaikkal, Shornur Road, Thiruvamapadi P. O, Thrissur - 680022
Tel 0487-2321562''',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Image.network('https://placehold.co/600x400/png'),
          ],
        ),
      ),
    );
  }
}
