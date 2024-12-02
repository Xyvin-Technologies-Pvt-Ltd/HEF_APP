import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/services/navgitor_service.dart';

class LevelMembers extends StatelessWidget {
  final List<Map<String, String>> members = [
    {
      'name': 'Ankur Kumar',
      'email': 'ankurkumar@gmail.com',
      'image': 'assets/ankur.jpg'
    },
    {
      'name': 'Rakesh Lal',
      'email': 'rakeshlal@gmail.com',
      'image': 'assets/rakesh.jpg'
    },
    {
      'name': 'Riya Sharma',
      'email': 'riyasharma@gmail.com',
      'image': 'assets/riya.jpg'
    },
    {
      'name': 'Rahul Mandal',
      'email': 'rahulmandal@gmail.com',
      'image': 'assets/rahul.jpg'
    },
    {
      'name': 'Siddharth Kaur',
      'email': 'siddharthkayr@gmail.com',
      'image': 'assets/siddharth.jpg'
    },
    {
      'name': 'Anjali Mandal',
      'email': 'anjalimandal@gmail.com',
      'image': 'assets/anjali.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'State Name / Zone Name / District Name / Chapter Item',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Text(
              'Members',
              style: kBodyTitleB.copyWith(color: kBlack54),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return Card(
                    elevation: 0.1,
                    color: kWhite,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(member['image']!),
                      ),
                      title: Text(member['name']!),
                      subtitle: Text(member['email']!),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        navigationService.pushNamed('ProfileAnalytics');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle action
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
