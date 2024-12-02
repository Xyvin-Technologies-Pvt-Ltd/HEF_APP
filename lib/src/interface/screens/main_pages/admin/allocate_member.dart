import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/screens/main_pages/admin/member_creation.dart';

class AllocateMember extends StatefulWidget {
  final UserModel newUser;
  const AllocateMember({super.key, required this.newUser});

  @override
  State<AllocateMember> createState() => _AllocateMemberState();
}

class _AllocateMemberState extends State<AllocateMember> {
  String? selectedState;
  String? selectedZone;
  String? selectedDistrict;
  String? selectedChapter;
  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          'Member Creation',
          style: kBodyTitleR,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => navigationService.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CustomDropdown(
              label: 'Business Category',
              items: const ['IT', 'Finance', 'Education'],
              onChanged: (value) {
                setState(() {
                  selectedState = value;
                });
              },
            ),
            CustomDropdown(
              label: 'Sub category',
              items: const ['Software', 'Hardware'],
              onChanged: (value) {
                setState(() {
                  selectedDistrict = value;
                });
              },
            ),
            CustomDropdown(
              label: 'Status',
              items: const ['active', 'inactive', 'suspended'],
              onChanged: (value) {
                setState(() {
                  selectedChapter = value;
                });
              },
            ),
            CustomDropdown(
              label: 'Status',
              items: const ['Active', 'Inactive', 'Suspended'],
              onChanged: (value) {
                setState(() {
                  selectedZone = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: customButton(
                    labelColor: kPrimaryColor,
                    buttonColor: Colors.transparent,
                    label: 'Cancel',
                    onPressed: () {
                      navigationService.pop();
                    },
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Flexible(
                  child: customButton(
                    label: 'Save',
                    onPressed: () async {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
