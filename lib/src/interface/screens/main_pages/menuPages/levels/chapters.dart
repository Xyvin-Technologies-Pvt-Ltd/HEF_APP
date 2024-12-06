import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/services/navgitor_service.dart';

class ChaptersPage extends StatelessWidget {
  final String districtId;
  const ChaptersPage({super.key, required this.districtId});

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();
    return Consumer(
      builder: (context, ref, child) {
        final asyncChapters =
            ref.watch(fetchLevelDataProvider(districtId, 'district'));
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text("Back"),
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
          body: asyncChapters.when(
              data: (chapters) {
                return ListView.builder(
                  itemCount: chapters.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                            child: Icon(Icons.groups_2_outlined,
                                color: kPrimaryColor),
                          ),
                          title: Text(
                            chapters[index].name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey),
                          onTap: () {
                            navigationService.pushNamed('LevelMembers',
                            arguments:chapters[index].id);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
               loading: () => const Center(
                                          child: Icon(Icons
                                              .notifications_none_outlined),
                                        ),
                                        error: (error, stackTrace) {
                                          return const Center(
                                            child: Text('Error loading chapters'),
                                          );
                                        },),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Handle button press
            },
            backgroundColor: Colors.orange,
            child:
                Icon(Icons.notifications_active_outlined, color: Colors.white),
          ),
          backgroundColor: Color(0xFFF8F8F8), // Light background color
        );
      },
    );
  }
}
