import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/services/navgitor_service.dart';

class StatesPage extends StatelessWidget {
  final List<String> states = [
    "State 1",
    "State 2",
    "State 3",
    "State 4",
    "State 5",
    "State 6",
    "State 7",
    "State 8",
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
        title: Text("Levels"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        itemCount: states.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: .1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: kWhite,
                  child: Icon(Icons.gps_fixed, color: kPrimaryColor),
                ),
                title: Text(
                  states[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                trailing:
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  navigationService.pushNamed('Zones');
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle button press
        },
        backgroundColor: kPrimaryColor,
        child: Icon(Icons.notifications, color: kWhite),
      ),
      backgroundColor: Color(0xFFF8F8F8), // Light background color
    );
  }
}
