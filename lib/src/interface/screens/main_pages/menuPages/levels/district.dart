import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/chapters.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/create_notification_page.dart';

import '../../../../../data/services/navgitor_service.dart';

class DistrictsPage extends StatelessWidget {
  final String zoneId;
  final String stateName;
  final String zoneName;
  const DistrictsPage(
      {super.key,
      required this.zoneId,
      required this.stateName,
      required this.zoneName});

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();
    return Consumer(
      builder: (context, ref, child) {
        final asyncDistrict = ref.watch(fetchLevelDataProvider(zoneId, 'zone'));
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text("Districts"),
            centerTitle: false,
            backgroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Colors.black),
          ),
          body: asyncDistrict.when(
            data: (districts) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 20),
                    child: Row(
                      children: [
                        Text(
                          '$stateName / $zoneName /',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: districts.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: kWhite,
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
                                child: Icon(Icons.map_outlined,
                                    color: kPrimaryColor),
                              ),
                              title: Text(
                                districts[index].name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChaptersPage(
                                              districtName:
                                                  districts[index].name,
                                              stateName: stateName,
                                              zoneName: zoneName,
                                              districtId: districts[index].id,
                                            )));
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => Center(child: LoadingAnimation()),
            error: (error, stackTrace) {
              // Handle error state
              return Center(
                child: Text('Error Loading States'),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CreateNotificationPage(level: 'zone',levelId: zoneId,)));
            },
            backgroundColor: Colors.orange,
            child: Icon(Icons.notifications, color: Colors.white),
          ),
          backgroundColor: Color(0xFFF8F8F8), // Light background color
        );
      },
    );
  }
}
