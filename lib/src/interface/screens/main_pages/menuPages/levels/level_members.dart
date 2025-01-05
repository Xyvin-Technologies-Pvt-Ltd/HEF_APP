import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';

class LevelMembers extends StatelessWidget {
  final String chapterId;
  final String stateName;
  final String zoneName;
  final String districtName;
  final String chapterName;
  const LevelMembers(
      {super.key,
      required this.chapterId,
      required this.stateName,
      required this.zoneName,
      required this.districtName,
      required this.chapterName});

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();
    return Consumer(
      builder: (context, ref, child) {
        final asyncMembers =
            ref.watch(fetchChapterMemberDataProvider(chapterId, 'user'));
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text("Members"),
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
          body: asyncMembers.when(
            data: (members) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$stateName / $zoneName / $districtName /',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                        ),
                      ],
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
                                backgroundImage:
                                    NetworkImage(member.image ?? ''),
                              ),
                              title: Text(member.name ?? ''),
                              subtitle: Text(member.name ?? ''),
                              trailing: Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                navigationService.pushNamed('ProfileAnalytics',
                                    arguments: member);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: LoadingAnimation()),
            error: (error, stackTrace) => Center(child: Text('NO MEMBERS')),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Handle action
            },
            backgroundColor: Colors.orange,
            child: Icon(Icons.person_add, color: Colors.white),
          ),
        );
      },
    );
  }
}
