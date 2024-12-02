import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';

class ProfileAnalyticsPage extends StatelessWidget {
  final List<Map<String, String>> reviews = [
    {
      'name': 'Jane Doe',
      'date': '12th Jan 2024',
      'rating': '5',
      'comment':
          'Lorem ipsum dolor sit amet consectetur. Justo vitae a iaculis integer pulvinar. Nunc enim sapien elit tempus quam mi enim porta mattis. Interdum tincidunt id.'
    },
    {
      'name': 'Jane Doe',
      'date': '6 days ago',
      'rating': '5',
      'comment':
          'Lorem ipsum dolor sit amet consectetur. Justo vitae a iaculis integer pulvinar. Nunc enim sapien elit tempus quam mi enim porta mattis. Interdum tincidunt id.'
    },
    {
      'name': 'Jane Doe',
      'date': '6 days ago',
      'rating': '4',
      'comment':
          'Lorem ipsum dolor sit amet consectetur. Justo vitae a iaculis integer pulvinar. Nunc enim sapien elit tempus quam mi enim porta mattis. Interdum tincidunt id.'
    },
  ];

  ProfileAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Back'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: .1,
                  offset: Offset(0, 1),
                ),
              ]),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 90, // Diameter of the avatar including the border
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kPrimaryColor,
                          width: 2.0, // Border width
                        ),
                      ),
                      child: CircleAvatar(
                        radius:
                            40, // Adjust the radius to fit inside the container
                        backgroundImage: AssetImage('assets/profile.jpg'),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sanu Kumar',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'sanukumar@gmail.com',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: 190,
                      height: 40,
                      child: customButton(
                          label: 'View Profile Card',
                          onPressed: () {},
                          buttonColor: kWhite,
                          labelColor: kPrimaryColor),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Statistics Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Requirements Posted', '23', Colors.orange),
                _buildStatCard('Reviews Received', '45', Colors.grey),
              ],
            ),
            SizedBox(height: 16),
            // Reviews Section
            Text(
              'Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true, // Prevent layout overflow
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(Icons.person, color: Colors.grey),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  review['name']!,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(
                              review['date']!,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: List.generate(
                            int.parse(review['rating']!),
                            (index) => Icon(Icons.star,
                                color: Colors.orange, size: 16),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          review['comment']!,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build the statistics card
  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
