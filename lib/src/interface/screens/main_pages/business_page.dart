import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/interface/screens/main_pages/bussiness_products/business_view.dart';
import 'package:hef/src/interface/screens/main_pages/bussiness_products/product_view.dart';
import 'package:hef/src/interface/screens/main_pages/chat_page.dart';

class BusinessPage extends StatelessWidget {
  const BusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2, // Number of tabs

        child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  PreferredSize(
                    preferredSize: Size.fromHeight(20),
                    child: Container(
                      margin: EdgeInsets.only(top: 0),
                      child: const SizedBox(
                        height: 50,
                        child: TabBar(
                          enableFeedback: true,
                          isScrollable: false,
                          indicatorColor: kPrimaryColor,
                          indicatorWeight: 3.0,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: kPrimaryColor,
                          unselectedLabelColor: Colors.grey,
                          labelStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: [
                            Tab(
                              text: "Business",
                            ),
                            Tab(
                              text: "Products",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              

                  Expanded(
                    child: TabBarView(
                      children: [
                        BusinessView(),
                        ProductView(),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }
}
