import 'package:flutter/material.dart';

import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/interface/screens/main_pages/chat/chat_dash.dart';
import 'package:hef/src/interface/screens/main_pages/chat/members.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            backgroundColor: kWhite,
            body: SafeArea(
              child: Column(
                children: [
                  PreferredSize(
                    preferredSize: Size.fromHeight(20),
                    child: Container(
                      margin: EdgeInsets.only(top: 0),
                      child: const SizedBox(
                        height: 40,
                        child: TabBar(
                          enableFeedback: true,
                          isScrollable: false,
                          indicatorColor: kPrimaryColor,
                          indicatorWeight: 3.0,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: kPrimaryColor,
                          unselectedLabelColor: Colors.grey,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: [
                            Tab(text: "MEMBERS"),
                            Tab(text: "CHAT LIST"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        const MembersPage(),
                        ChatDash(),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }
}
