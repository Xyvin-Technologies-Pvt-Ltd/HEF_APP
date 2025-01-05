import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/create_notification_page.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/level_members.dart';

class ChaptersPage extends StatelessWidget {
  final String districtId;
  final String stateName;
  final String zoneName;
  final String districtName;

  const ChaptersPage({
    super.key,
    required this.districtId,
    required this.stateName,
    required this.zoneName,
    required this.districtName,
  });

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
            title: Text("Chapters"),
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
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 20),
                    child: Row(
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
                  ),
                  Expanded(
                    child: ListView.builder(
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
                            child: CustomExpansionTile(
                              title: Text(
                                chapters[index].name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: kWhite,
                                child: Icon(Icons.groups_2_outlined,
                                    color: kPrimaryColor),
                              ),
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: customButton(
                                            buttonHeight: 40,
                                            labelColor: kPrimaryColor,
                                            label: 'Activity',
                                            onPressed: () {
                                              navigationService.pushNamed(
                                                  'ActivityPage',
                                                  arguments:
                                                      chapters[index].id);
                                            },
                                            buttonColor: kWhite,
                                            sideColor: kPrimaryColor),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: customButton(
                                          buttonHeight: 40,
                                          label: 'View List',
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        LevelMembers(
                                                          chapterId:
                                                              chapters[index]
                                                                  .id,
                                                          stateName: stateName,
                                                          zoneName: zoneName,
                                                          districtName:
                                                              districtName,
                                                          chapterName:
                                                              chapters[index]
                                                                  .name,
                                                        )));
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Icon(Icons.notifications_none_outlined),
            ),
            error: (error, stackTrace) {
              return const Center(
                child: Text('Error loading chapters'),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateNotificationPage(
                            level: 'district',
                            levelId: districtId,
                          )));
            },
            backgroundColor: Colors.orange,
            child:
                Icon(Icons.notifications_active_outlined, color: Colors.white),
          ),
          backgroundColor: Color(0xFFF8F8F8),
        );
      },
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  final Widget title;
  final Widget? leading;
  final List<Widget> children;

  const CustomExpansionTile({
    Key? key,
    required this.title,
    this.leading,
    required this.children,
  }) : super(key: key);

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: widget.leading,
          title: widget.title,
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.25 : 0.0,
            duration: Duration(milliseconds: 200),
            child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isExpanded
              ? Column(
                  children: widget.children,
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}
