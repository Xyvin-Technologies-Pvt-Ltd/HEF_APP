// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
// import 'package:hef/src/data/api_routes/user_api/user_data/edit_user.dart';
// import 'package:hef/src/data/constants/color_constants.dart';
// import 'package:hef/src/data/constants/style_constants.dart';
// import 'package:hef/src/data/models/user_model.dart';
// import 'package:hef/src/data/notifiers/user_notifier.dart';
// import 'package:hef/src/data/services/snackbar_service.dart';
// import 'package:hef/src/interface/components/Buttons/primary_button.dart';
// import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
// import 'package:hef/src/interface/screens/main_pages/admin/allocate_member.dart';

// class NoChapterConditionPage extends ConsumerStatefulWidget {
//   final UserModel user;
//   const NoChapterConditionPage({super.key, required this.user});

//   @override
//   ConsumerState<NoChapterConditionPage> createState() =>
//       _NoChapterConditionPageState();
// }

// class _NoChapterConditionPageState
//     extends ConsumerState<NoChapterConditionPage> {
//   String? selectedStateId;
//   String? selectedZone;
//   String? selectedDistrict;
//   String? selectedChapter;
//   Future<String> _submitData({required UserModel user}) async {
//     // String fullName =
//     //     '${user.name!.first} ${user.name!.middle} ${user.name!.last}';

//     // List<String> nameParts = fullName.split(' ');

//     // String firstName = nameParts[0];
//     // String middleName = nameParts.length > 2 ? nameParts[1] : ' ';
//     // String lastName = nameParts.length > 1 ? nameParts.last : ' ';

//     final Map<String, dynamic> profileData = {
//       "name": user.name ?? '',
//       "email": user.email,
//       "phone": user.phone,
//       'chapter': selectedChapter,
//       if (user.image != null && user.image != '') "image": user.image ?? '',
//       if (user.address != null && user.address != '')
//         "address": user.address ?? '',
//       if (user.bio != null && user.bio != '') "bio": user.bio ?? '',
//       if (user.secondaryPhone != null)
//         "secondaryPhone": {
//           if (user.secondaryPhone?.whatsapp != null)
//             "whatsapp": user.secondaryPhone?.whatsapp ?? '',
//           if (user.secondaryPhone?.business != null)
//             "business": user.secondaryPhone?.business ?? '',
//         },
//       if (user.company != null)
//         "company": user.company!.map((company) {
//           final name = company.name?.trim();
//           final designation = company.designation?.trim();
//           final phone = company.phone?.trim();
//           final email = company.email?.trim();
//           final websites = company.websites?.trim();

//           return {
//             if (name != null && name.isNotEmpty) "name": name,
//             if (designation != null && designation.isNotEmpty)
//               "designation": designation,
//             if (phone != null && phone.isNotEmpty) "phone": phone,
//             if (email != null && email.isNotEmpty) "email": email,
//             if (websites != null && websites.isNotEmpty) "websites": websites,
//           };
//         }).toList(),
//       "social": [
//         for (var i in user.social!) {"name": "${i.name}", "link": i.link}
//       ],
//       "websites": [
//         for (var i in user.websites!)
//           {"name": i.name.toString(), "link": i.link}
//       ],
//       "videos": [
//         for (var i in user.videos!) {"name": i.name, "link": i.link}
//       ],
//       "awards": [
//         for (var i in user.awards!)
//           {"name": i.name, "image": i.image, "authority": i.authority}
//       ],
//       "certificates": [
//         for (var i in user.certificates!) {"name": i.name, "link": i.link}
//       ],
//     };
//     log(profileData.toString());
//     String response = await editUser(profileData);

//     return response;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final asyncStates = ref.watch(fetchStatesProvider);
//     final asyncZones =
//         ref.watch(fetchLevelDataProvider(selectedStateId ?? '', 'state'));
//     final asyncDistricts =
//         ref.watch(fetchLevelDataProvider(selectedZone ?? '', 'zone'));
//     final asyncChapters =
//         ref.watch(fetchLevelDataProvider(selectedDistrict ?? '', 'district'));

//     return Scaffold(
//       backgroundColor: kWhite,
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Select Your Chapter',
//               style: kHeadTitleB,
//             ),
//             asyncStates.when(
//               data: (states) => SelectionDropDown(
//                 hintText: 'Choose State',
//                 value: selectedStateId,
//                 label: null,
//                 items: states.map((state) {
//                   return DropdownMenuItem<String>(
//                     value: state.id,
//                     child: Text(state.name),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedStateId = value;
//                     selectedZone = null;
//                     selectedDistrict = null;
//                     selectedChapter = null;
//                   });
//                 },
//               ),
//               loading: () => const Center(child: LoadingAnimation()),
//               error: (error, stackTrace) => const SizedBox(),
//             ),
//             const SizedBox(height: 16),
//             asyncZones.when(
//               data: (zones) => SelectionDropDown(
//                 hintText: 'Choose Zone',
//                 value: selectedZone,
//                 label: null,
//                 items: zones.map((zone) {
//                   return DropdownMenuItem<String>(
//                     value: zone.id,
//                     child: Text(zone.name),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedZone = value;
//                     selectedDistrict = null;
//                     selectedChapter = null;
//                   });
//                 },
//               ),
//               loading: () => const Center(
//                 child: SizedBox(),
//               ),
//               error: (error, stackTrace) => const SizedBox(),
//             ),
//             const SizedBox(height: 16),
//             asyncDistricts.when(
//               data: (districts) => SelectionDropDown(
//                 hintText: 'Choose District',
//                 value: selectedDistrict,
//                 label: null,
//                 items: districts.map((district) {
//                   return DropdownMenuItem<String>(
//                     value: district.id,
//                     child: Text(district.name),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedDistrict = value;
//                     selectedChapter = null;
//                   });
//                 },
//               ),
//               loading: () => const Center(
//                 child: SizedBox(),
//               ),
//               error: (error, stackTrace) => const SizedBox(),
//             ),
//             const SizedBox(height: 16),
//             asyncChapters.when(
//               data: (chapters) => SelectionDropDown(
//                 hintText: 'Choose Chapter',
//                 value: selectedChapter,
//                 label: null,
//                 items: chapters.map((chapter) {
//                   return DropdownMenuItem<String>(
//                     value: chapter.id,
//                     child: Text(chapter.name),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedChapter = value;
//                   });
//                 },
//               ),
//               loading: () => const Center(
//                 child: SizedBox(),
//               ),
//               error: (error, stackTrace) => const SizedBox(),
//             ),
//             const SizedBox(height: 16),
//             if (selectedChapter != null)
//               customButton(
//                 label: 'Continue',
//                 onPressed: () async {
//                   String response = await _submitData(user: widget.user);
//                   SnackbarService snackbarService = SnackbarService();
//                   snackbarService.showSnackBar(response);
//                   if (response.contains('success')) {
//                     ref.read(userProvider.notifier).refreshUser();
//                   }
//                 },
//               )
//           ],
//         ),
//       ),
//     );
//   }
// }
