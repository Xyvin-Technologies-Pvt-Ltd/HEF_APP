
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:file_picker/file_picker.dart';

// class DetailsPage extends ConsumerStatefulWidget {
//   const DetailsPage({super.key});

//   @override
//   ConsumerState<DetailsPage> createState() => _DetailsPageState();
// }

// class _DetailsPageState extends ConsumerState<DetailsPage> {
//   TextEditingController productPriceType = TextEditingController();

//   // final isPhoneNumberVisibleProvider = StateProvider<bool>((ref) => false);
//   // final isLandlineVisibleProvider = StateProvider<bool>((ref) => false);
//   // final isContactDetailsVisibleProvider = StateProvider<bool>((ref) => false);
//   // final isSocialDetailsVisibleProvider = StateProvider<bool>((ref) => false);
//   // final isWebsiteDetailsVisibleProvider = StateProvider<bool>((ref) => false);
//   // final isVideoDetailsVisibleProvider = StateProvider<bool>((ref) => false);
//   // final isAwardsDetailsVisibleProvider = StateProvider<bool>((ref) => false);
//   // final isProductsDetailsVisibleProvider = StateProvider<bool>((ref) => false);
//   // final isCertificateDetailsVisibleProvider =
//   //     StateProvider<bool>((ref) => false);
//   // final isBrochureDetailsVisibleProvider = StateProvider<bool>((ref) => false);

//   final TextEditingController firstNameController = TextEditingController();

//   final TextEditingController middleNameController = TextEditingController();

//   final TextEditingController lastNameController = TextEditingController();

//   final TextEditingController landlineController = TextEditingController();
//   final TextEditingController bloodGroupController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController profilePictureController =
//       TextEditingController();
//   final TextEditingController personalPhoneController = TextEditingController();
//   final TextEditingController companyPhoneController = TextEditingController();
//   final TextEditingController whatsappController = TextEditingController();
//   final TextEditingController whatsappBusinessController =
//       TextEditingController();
//   final TextEditingController designationController = TextEditingController();
//   final TextEditingController companyNameController = TextEditingController();
//   final TextEditingController companyEmailController = TextEditingController();
//   final TextEditingController companyAddressController =
//       TextEditingController();
//   final TextEditingController bioController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   final TextEditingController igController = TextEditingController();
//   final TextEditingController linkedinController = TextEditingController();
//   final TextEditingController twtitterController = TextEditingController();
//   final TextEditingController facebookController = TextEditingController();
//   final TextEditingController websiteNameController = TextEditingController();
//   final TextEditingController websiteLinkController = TextEditingController();
//   final TextEditingController videoNameController = TextEditingController();
//   final TextEditingController videoLinkController = TextEditingController();
//   final TextEditingController awardNameController = TextEditingController();
//   final TextEditingController awardAuthorityController =
//       TextEditingController();
//   final TextEditingController productNameController = TextEditingController();
//   final TextEditingController productDescriptionController =
//       TextEditingController();
//   final TextEditingController productMoqController = TextEditingController();
//   final TextEditingController productActualPriceController =
//       TextEditingController();
//   final TextEditingController productOfferPriceController =
//       TextEditingController();
//   final TextEditingController certificateNameController =
//       TextEditingController();
//   final TextEditingController brochureNameController = TextEditingController();
//   File? _profileImageFile;
//   File? _companyImageFile;
//   File? _awardImageFIle;
//   File? _productImageFIle;
//   File? _certificateImageFIle;
//   File? _brochurePdfFile;

//   final _formKey = GlobalKey<FormState>();
//   ApiRoutes api = ApiRoutes();

//   String productUrl = '';
//   List<String> filesToBeDeleted = [];
//   Future<File?> _pickFile({required String imageType}) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: [
//         'png',
//         'jpg',
//         'jpeg',
//       ],
//     );

//     if (result != null) {
//       // Check if the file size is more than or equal to 1 MB (1 MB = 1024 * 1024 bytes)
//       // if (result.files.single.size >= 1024 * 1024) {
//       //   CustomSnackbar.showSnackbar(context, 'File size cannot exceed 1MB');

//       //   return null; // Exit the function if the file is too large
//       // }

//       // Continue with your logic based on imageType
//       if (imageType == 'profile') {
//         setState(() {
//           _profileImageFile = File(result.files.single.path!);
//           api.createFileUrl(file: _profileImageFile!, token: token).then((url) {
//             String profileUrl = url;
//             ref.read(userProvider.notifier).updateProfilePicture(profileUrl);
//             print((profileUrl));
//           });
//         });
//         return _profileImageFile;
//       } else if (imageType == 'award') {
//         _awardImageFIle = File(result.files.single.path!);
//         return _awardImageFIle;
//       } else if (imageType == 'product') {
//         _productImageFIle = File(result.files.single.path!);
//         return _productImageFIle;
//       } else if (imageType == 'certificate') {
//         _certificateImageFIle = File(result.files.single.path!);
//         return _certificateImageFIle;
//       } else if (imageType == 'company') {
//         setState(() {
//           _companyImageFile = File(result.files.single.path!);
//           api.createFileUrl(file: _companyImageFile!, token: token).then((url) {
//             String companyUrl = url;
//             ref.read(userProvider.notifier).updateCompanyLogo(companyUrl);
//             print(companyUrl);
//           });
//         });
//         return _companyImageFile;
//       } else {
//         _brochurePdfFile = File(result.files.single.path!);
//         return _brochurePdfFile;
//       }
//     }
//     return null;
//   }

//   Future<File?> _pickBrochure({required String imageType}) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
//     );

//     if (result != null) {
//       if (result.files.single.size >= 1024 * 1024) {
//         CustomSnackbar.showSnackbar(context, 'File size cannot exceed 1MB');

//         return null; // Exit the function if the file is too large
//       }

//       _brochurePdfFile = File(result.files.single.path!);
//       log('picked pdf :$_brochurePdfFile');
//       return _brochurePdfFile;
//     }
//     return null;
//   }

//   void _removeProduct(int index) async {
//     // await api
//     //     .deleteFile(
//     //         token, ref.read(userProvider).value!.products![index].image!)
//     // filesToBeDeleted.add(ref.read(userProvider).value!.products![index].image!);
//     ref
//         .read(userProvider.notifier)
//         .removeProduct(ref.read(userProvider).value!.products![index]);
//   }
//   // void _addAwardCard() async {
//   // await api.createFileUrl(file: _awardImageFIle!).then((url) {
//   //   awardUrl = url;
//   //   print((awardUrl));
//   // });
//   //   ref.read(userProvider.notifier).updateAwards([...?ref.read(userProvider).value?.awards, newAward]);
//   // }

//   Future<void> _addNewAward() async {
//     await api.createFileUrl(file: _awardImageFIle!, token: token).then((url) {
//       final String awardUrl = url;
//       final newAward = Award(
//         name: awardNameController.text,
//         url: awardUrl,
//         authorityName: awardAuthorityController.text,
//       );

//       ref
//           .read(userProvider.notifier)
//           .updateAwards([...?ref.read(userProvider).value?.awards, newAward]);
//     });
//     _awardImageFIle == null;
//   }

//   void _removeAward(int index) async {
//     // await api
//     //     .deleteFile(token, ref.read(userProvider).value!.awards![index].url!)
//     filesToBeDeleted.add(ref.read(userProvider).value!.awards![index].url!);
//     ref
//         .read(userProvider.notifier)
//         .removeAward(ref.read(userProvider).value!.awards![index]);
//   }

//   Future<void> _addNewCertificate() async {
//     await api
//         .createFileUrl(file: _certificateImageFIle!, token: token)
//         .then((url) {
//       final String certificateUrl = url;
//       final newCertificate = Certificate(
//           name: certificateNameController.text, url: certificateUrl);

//       ref.read(userProvider.notifier).updateCertificate(
//           [...?ref.read(userProvider).value?.certificates, newCertificate]);
//     });
//   }

//   void _removeCertificate(int index) async {
//     // await api.deleteFile(
//     //     token, ref.read(userProvider).value!.certificates![index].url!);
//     filesToBeDeleted
//         .add(ref.read(userProvider).value!.certificates![index].url!);
//     ref
//         .read(userProvider.notifier)
//         .removeCertificate(ref.read(userProvider).value!.certificates![index]);
//   }

//   Future<void> _addNewBrochure() async {
//     log("picked pdf while add:$_brochurePdfFile");
//     final String brochureUrl =
//         await api.createFileUrl(file: _brochurePdfFile!, token: token);

//     final newBrochure =
//         Brochure(name: brochureNameController.text, url: brochureUrl);

//     ref.read(userProvider.notifier).updateBrochure(
//         [...?ref.read(userProvider).value?.brochure, newBrochure]);
//   }

//   void _removeBrochure(int index) async {
//     // await api
//     //     .deleteFile(
//     //         token, ref.read(userProvider).value!.certificates![index].url!)
//     filesToBeDeleted.add(ref.read(userProvider).value!.brochure![index].url!);
//     ref
//         .read(userProvider.notifier)
//         .removeBrochure(ref.read(userProvider).value!.brochure![index]);
//   }

//   void _addNewWebsite() async {
//     Website newWebsite = Website(
//         url: websiteLinkController.text.toString(),
//         name: websiteNameController.text.toString());
//     log('Hello im in website bug:${ref.read(userProvider).value?.websites}');
//     ref.read(userProvider.notifier).updateWebsite(
//         [...?ref.read(userProvider).value?.websites, newWebsite]);
//     websiteLinkController.clear();
//     websiteNameController.clear();
//   }

//   void _removeWebsite(int index) async {
//     ref
//         .read(userProvider.notifier)
//         .removeWebsite(ref.read(userProvider).value!.websites![index]);
//   }

//   void _addNewVideo() async {
//     Video newVideo = Video(
//         url: videoLinkController.text.toString(),
//         name: videoNameController.text.toString());
//     ref
//         .read(userProvider.notifier)
//         .updateVideos([...?ref.read(userProvider).value?.video, newVideo]);
//     videoLinkController.clear();
//     videoNameController.clear();
//   }

//   void _removeVideo(int index) async {
//     ref
//         .read(userProvider.notifier)
//         .removeVideo(ref.read(userProvider).value!.video![index]);
//   }

//   @override
//   void dispose() {
//     // Dispose controllers when the widget is disposed
//     firstNameController.dispose();
//     middleNameController.dispose();
//     lastNameController.dispose();
//     bloodGroupController.dispose();
//     emailController.dispose();
//     profilePictureController.dispose();
//     personalPhoneController.dispose();
//     landlineController.dispose();
//     companyPhoneController.dispose();
//     whatsappController.dispose();
//     whatsappBusinessController.dispose();
//     designationController.dispose();
//     companyNameController.dispose();
//     companyEmailController.dispose();
//     bioController.dispose();
//     addressController.dispose();

//     super.dispose();
//   }

//   Future<String> _submitData({required UserModel user}) async {
//     log('profile: ${user.profilePicture}');
//     log('company logo: ${user.companyLogo}');
//     final Map<String, dynamic> profileData = {
//       "name": {
//         "first_name": user.name?.firstName,
//         // if (user.name?.middleName != null && user.name?.middleName != '')
//         "middle_name": user.name?.middleName ?? "",
//         "last_name": user.name?.lastName ?? '',
//       },

//       // if (user.bloodGroup != null)
//       "blood_group": user.bloodGroup ?? '',
//       if (user.email != null) "email": user.email,
//       if (user.profilePicture != null) "profile_picture": user.profilePicture,
//       "phone_numbers": {
//         if (user.phoneNumbers?.personal != null)
//           "personal": user.phoneNumbers!.personal ?? '',
//         // if (user.phoneNumbers?.landline != null &&
//         //     user.phoneNumbers?.landline != '')
//         "landline": user.phoneNumbers!.landline ?? '',
//         // if (user.phoneNumbers?.companyPhoneNumber != null)
//         "company_phone_number": user.phoneNumbers!.companyPhoneNumber ?? '',
//         // if (user.phoneNumbers?.whatsappNumber != null)
//         "whatsapp_number": user.phoneNumbers!.whatsappNumber ?? '',
//         // if (user.phoneNumbers?.whatsappBusinessNumber != null)
//         "whatsapp_business_number":
//             user.phoneNumbers!.whatsappBusinessNumber ?? '',
//       },
//       // if (user.designation != null && user.designation != '')
//       "designation": user.designation,
//       if (user.companyLogo != null && user.companyLogo != '')
//         "company_logo": user.companyLogo,
//       // if (user.companyName != null && user.companyName != '')
//       "company_name": user.companyName ?? '',
//       if (user.companyEmail != null && user.companyEmail != '')
//         "company_email": user.companyEmail,
//       if (user.companyAddress != null && user.companyAddress != '')
//         "company_address": user.companyAddress,
//       if (user.bio != null && user.bio != '') "bio": user.bio,
//       if (user.address != null && user.address != '') "address": user.address,
//       // if (user.socialMedia != null &&
//       //     user.socialMedia!.any((e) => e.url != null && e.url!.isNotEmpty))
//       "social_media": [
//         for (var i in user.socialMedia!)
//           {"platform": "${i.platform}", "url": i.url}
//       ],
//       "websites": [
//         for (var i in user.websites!) {"name": i.name.toString(), "url": i.url}
//       ],
//       "video": [
//         for (var i in user.video!) {"name": i.name, "url": i.url}
//       ],
//       "awards": [
//         for (var i in user.awards!)
//           {"name": i.name, "url": i.url, "authority_name": i.authorityName}
//       ],
//       "certificates": [
//         for (var i in user.certificates!) {"name": i.name, "url": i.url}
//       ],
//       "brochure": [
//         for (var i in user.brochure!) {"name": i.name, "url": i.url}
//       ],
//       "products": [
//         for (var i in user.products!)
//           {
//             "_id": i.id,
//             "seller_id": i.sellerId,
//             "name": i.name,
//             "image": i.image,
//             "price": i.price,
//             "offer_price": i.offerPrice,
//             "description": i.description,
//             "moq": i.moq ?? 0,
//             "units": i.units ?? 0,
//             "status": i.status,
//             "tags": ["string"]
//           }
//       ]
//     };
//     log(profileData.toString());
//     String response = await api.editUser(profileData);
//     return response;
//   }
//   // Future<void> _selectImageFile(ImageSource source, String imageType) async {
//   //   final XFile? image = await _picker.pickImage(source: source);
//   //   print('$image');
//   //   if (image != null && imageType == 'profile') {
//   //     setState(() {
//   //       _profileImageFile = _pickFile()
//   //     });
//   //   } else if (image != null && imageType == 'company') {
//   //     setState(() {
//   //       _companyImageFile = File(image.path);
//   //     });
//   //   }
//   // }

//   Future<void> _pickImage(ImageSource source, String imageType) async {
//     PermissionStatus status;

//     if (source == ImageSource.camera) {
//       status = await Permission.camera.request();
//     } else if (source == ImageSource.gallery) {
//       status = await Permission.photos.request();
//     } else {
//       return;
//     }

//     if (status.isGranted) {
//       _pickFile(imageType: imageType);
//     } else if (status.isPermanentlyDenied) {
//       _showPermissionDeniedDialog(true);
//     } else {
//       _showPermissionDeniedDialog(false);
//     }
//   }

//   void _showPermissionDeniedDialog(bool isPermanentlyDenied) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Permission Denied'),
//           content: Text(isPermanentlyDenied
//               ? 'Permission is permanently denied. Please enable it from the app settings.'
//               : 'Permission is denied. Please grant the permission to proceed.'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 if (isPermanentlyDenied) {
//                   openAppSettings();
//                 }
//               },
//               child: Text(isPermanentlyDenied ? 'Open Settings' : 'OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _openModalSheet(
//       {required String sheet, String brochureName = 'Sample'}) {
//     if (sheet == 'product') {
//       Navigator.push(context,
//           MaterialPageRoute(builder: (context) => EnterProductsPage()));
//     } else {
//       showModalBottomSheet(
//         isScrollControlled: true,
//         context: context,
//         builder: (context) {
//           if (sheet == 'award') {
//             return ShowEnterAwardSheet(
//               pickImage: _pickFile,
//               addAwardCard: _addNewAward,
//               imageType: sheet,
//               textController1: awardNameController,
//               textController2: awardAuthorityController,
//             );
//           } else if (sheet == 'certificate') {
//             return ShowAddCertificateSheet(
//                 addCertificateCard: _addNewCertificate,
//                 textController: certificateNameController,
//                 imageType: sheet,
//                 pickImage: _pickFile);
//           } else {
//             return ShowAddBrochureSheet(
//                 brochureName: brochureName,
//                 textController: brochureNameController,
//                 pickPdf: _pickBrochure,
//                 imageType: sheet,
//                 addBrochureCard: _addNewBrochure);
//           }
//         },
//       );
//     }
//   }

//   void navigateBasedOnPreviousPage() {
//     final previousPage = ModalRoute.of(context)?.settings.name;
//     log('previousPage: $previousPage');
//     if (previousPage == 'ProfileCompletion') {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const MainPage()),
//       );
//     } else {
//       Navigator.pop(context);
//       ref.read(userProvider.notifier).refreshUser();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final asyncUser = ref.watch(userProvider);

//     return PopScope(
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) {
//           ref.read(userProvider.notifier).refreshUser();
//         }
//       },
//       child: GestureDetector(
//         onTap: () {
//           FocusScope.of(context).unfocus();
//         },
//         child: Scaffold(
//             backgroundColor: Colors.white,
//             body: asyncUser.when(
//               loading: () {
//                 log('im inside details page');
//                 return const EditUserShimmer();
//               },
//               error: (error, stackTrace) {
//                 return const Center(
//                   child: LoadingAnimation(),
//                 );
//               },
//               data: (user) {
//                 if (firstNameController.text.isEmpty) {
//                   firstNameController.text = user.name?.firstName ?? '';
//                 }
//                 if (firstNameController.text.isEmpty) {
//                   firstNameController.text = user.name?.firstName ?? '';
//                 }
//                 if (middleNameController.text.isEmpty) {
//                   middleNameController.text = user.name?.middleName ?? '';
//                 }
//                 if (lastNameController.text.isEmpty) {
//                   lastNameController.text = user.name?.lastName ?? '';
//                 }
//                 if (designationController.text.isEmpty) {
//                   designationController.text = user.designation ?? '';
//                 }
//                 if (bioController.text.isEmpty) {
//                   bioController.text = user.bio ?? '';
//                 }
//                 if (companyNameController.text.isEmpty) {
//                   companyNameController.text = user.companyName ?? '';
//                 }
//                 if (companyAddressController.text.isEmpty) {
//                   companyAddressController.text = user.companyAddress ?? '';
//                 }
//                 if (personalPhoneController.text.isEmpty) {
//                   personalPhoneController.text =
//                       user.phoneNumbers?.personal?.toString() ?? '';
//                 }
//                 if (landlineController.text.isEmpty) {
//                   landlineController.text = user.phoneNumbers?.landline ?? '';
//                 }
//                 if (emailController.text.isEmpty) {
//                   emailController.text = user.email ?? '';
//                 }
//                 if (whatsappBusinessController.text.isEmpty) {
//                   whatsappBusinessController.text =
//                       user.phoneNumbers?.whatsappBusinessNumber ?? '';
//                 }
//                 if (whatsappController.text.isEmpty) {
//                   whatsappController.text =
//                       user.phoneNumbers?.whatsappNumber ?? '';
//                 }
//                 if (addressController.text.isEmpty) {
//                   addressController.text = user.address ?? '';
//                 }
      
//                 // Set social media URLs based on the platform
//                 for (SocialMedia social in user.socialMedia ?? []) {
//                   if (social.platform == 'instagram' &&
//                       igController.text.isEmpty) {
//                     igController.text = social.url ?? '';
//                   } else if (social.platform == 'linkedin' &&
//                       linkedinController.text.isEmpty) {
//                     linkedinController.text = social.url ?? '';
//                   } else if (social.platform == 'twitter' &&
//                       twtitterController.text.isEmpty) {
//                     twtitterController.text = social.url ?? '';
//                   } else if (social.platform == 'facebook' &&
//                       facebookController.text.isEmpty) {
//                     facebookController.text = social.url ?? '';
//                   }
//                 }
//                 return Consumer(
//                   builder: (context, ref, child) {
//                     return Stack(
//                       children: [
//                         SingleChildScrollView(
//                           child: Form(
//                             key: _formKey,
//                             child: Column(
//                               children: [
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.1),
//                                         offset: const Offset(0, 2),
//                                         blurRadius: 4,
//                                       ),
//                                     ],
//                                   ),
//                                   child: AppBar(
//                                     scrolledUnderElevation: 0,
//                                     backgroundColor: Colors.white,
//                                     elevation: 0,
//                                     leadingWidth: 100,
//                                     leading: Padding(
//                                       padding:
//                                           const EdgeInsets.only(left: 10),
//                                       child: SizedBox(
//                                         width: 100,
//                                         height: 100,
//                                         child: Image.asset(
//                                           'assets/icons/kssiaLogo.png',
//                                           fit: BoxFit.contain,
//                                         ),
//                                       ),
//                                     ),
//                                     actions: [
//                                       TextButton(
//                                           onPressed: () {
//                                             ref
//                                                 .read(userProvider.notifier)
//                                                 .refreshUser();
//                                             navigateBasedOnPreviousPage();
//                                           },
//                                           child: const Icon(Icons.close)),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 35),
//                                 FormField<File>(
//                                   // validator: (value) {
//                                   //   if (user.profilePicture == null) {
//                                   //     return 'Please select a profile image';
//                                   //   }
//                                   //   return null;
//                                   // },
//                                   builder: (FormFieldState<File> state) {
//                                     return Center(
//                                       child: Column(
//                                         children: [
//                                           Stack(
//                                             children: [
//                                               DottedBorder(
//                                                 borderType: BorderType.Circle,
//                                                 dashPattern: [6, 3],
//                                                 color: Colors.grey,
//                                                 strokeWidth: 2,
//                                                 child: ClipOval(
//                                                     child: Container(
//                                                   width: 120,
//                                                   height: 120,
//                                                   color: const Color.fromARGB(
//                                                       255, 255, 255, 255),
//                                                   child: user.profilePicture !=
//                                                           null
//                                                       ? Image.network(
//                                                           errorBuilder:
//                                                               (context, error,
//                                                                   stackTrace) {
//                                                             return const Icon(
//                                                                 Icons.person);
//                                                           },
//                                                           user.profilePicture ??
//                                                               'https://placehold.co/600x400',
//                                                           fit: BoxFit.cover,
//                                                         )
//                                                       : Image.asset(
//                                                           'assets/icons/dummy_person_large.png'),
//                                                 )),
//                                               ),
//                                               Positioned(
//                                                 bottom: 4,
//                                                 right: 4,
//                                                 child: InkWell(
//                                                   onTap: () {
//                                                     _pickFile(
//                                                         imageType: 'profile');
//                                                   },
//                                                   child: Container(
//                                                     decoration: BoxDecoration(
//                                                       boxShadow: [
//                                                         BoxShadow(
//                                                           color: Colors.black
//                                                               .withOpacity(
//                                                                   0.2),
//                                                           offset:
//                                                               const Offset(
//                                                                   2, 2),
//                                                           blurRadius: 4,
//                                                         ),
//                                                       ],
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                     child: const CircleAvatar(
//                                                       radius: 17,
//                                                       backgroundColor:
//                                                           Colors.white,
//                                                       child: Icon(
//                                                         Icons.edit,
//                                                         color:
//                                                             Color(0xFF004797),
//                                                         size: 16,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           if (state.hasError)
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   top: 15),
//                                               child: Text(
//                                                 state.errorText ?? '',
//                                                 style: const TextStyle(
//                                                     color: Colors.red),
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                 ),
//                                 const Row(
//                                   children: [
//                                     Padding(
//                                       padding: EdgeInsets.only(
//                                           top: 60, left: 16, bottom: 10),
//                                       child: Text(
//                                         'Personal Details',
//                                         style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 20,
//                                       right: 20,
//                                       top: 10,
//                                       bottom: 10),
//                                   child: Column(
//                                     children: [
//                                       CustomTextFormField(
//                                         validator: (value) {
//                                           if (value == null ||
//                                               value.isEmpty) {
//                                             return 'Please Enter Your First Name';
//                                           }
//                                           return null;
//                                         },
//                                         textController: firstNameController,
//                                         labelText: 'Enter your First name',
//                                       ),
//                                       const SizedBox(height: 20.0),
//                                       CustomTextFormField(
//                                         textController: middleNameController,
//                                         labelText: 'Enter your Middle name',
//                                       ),
//                                       const SizedBox(height: 20.0),
//                                       CustomTextFormField(
//                                         // validator: (value) {
//                                         //   if (value == null || value.isEmpty) {
//                                         //     return 'Please Enter Your Full Name';
//                                         //   }
//                                         //   return null;
//                                         // },
//                                         textController: lastNameController,
//                                         labelText: 'Enter your Last name',
//                                       ),
//                                       const SizedBox(height: 20.0),
//                                       CustomTextFormField(
//                                           // validator: (value) {
//                                           //   if (value == null || value.isEmpty) {
//                                           //     return 'Please Enter Your Designation';
//                                           //   }
//                                           //   return null;
//                                           // },
//                                           textController:
//                                               designationController,
//                                           labelText: 'Designation'),
//                                       const SizedBox(height: 20.0),
//                                       CustomTextFormField(
//                                           // validator: (value) {
//                                           //   if (value == null || value.isEmpty) {
//                                           //     return 'Please Enter Your Bio';
//                                           //   }
//                                           //   return null;
//                                           // },
//                                           textController: bioController,
//                                           labelText: 'Bio',
//                                           maxLines: 5),
//                                     ],
//                                   ),
//                                 ),
//                                 const Padding(
//                                   padding: EdgeInsets.only(right: 20),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       // Text(
//                                       //   'Add more',
//                                       //   style: TextStyle(
//                                       //       color: Color(0xFF004797),
//                                       //       fontWeight: FontWeight.w600,
//                                       //       fontSize: 15),
//                                       // ),
//                                       // Icon(
//                                       //   Icons.add,
//                                       //   color: Color(0xFF004797),
//                                       //   size: 18,
//                                       // )
//                                     ],
//                                   ),
//                                 ),
//                                 const Row(
//                                   children: [
//                                     Padding(
//                                       padding: EdgeInsets.only(
//                                           top: 60, left: 16, bottom: 10),
//                                       child: Text(
//                                         'Company Details',
//                                         style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 // FormField<File>(
//                                 //   // validator: (value) {
//                                 //   //   if (user.companyLogo == null) {
//                                 //   //     return 'Please select a company logo';
//                                 //   //   }
//                                 //   //   return null;
//                                 //   // },
//                                 //   builder: (FormFieldState<File> state) {
//                                 //     return Center(
//                                 //       child: Column(
//                                 //         children: [
//                                 //           Stack(
//                                 //             children: [
//                                 //               DottedBorder(
//                                 //                 radius:
//                                 //                     const Radius.circular(10),
//                                 //                 borderType: BorderType.RRect,
//                                 //                 dashPattern: [6, 3],
//                                 //                 color: Colors.grey,
//                                 //                 strokeWidth: 2,
//                                 //                 child: ClipRRect(
//                                 //                   child: Container(
//                                 //                       width: 110,
//                                 //                       height: 100,
//                                 //                       color: const Color
//                                 //                           .fromARGB(
//                                 //                           255, 255, 255, 255),
//                                 //                       child:
//                                 //                           user.companyLogo !=
//                                 //                                   null
//                                 //                               ? Image.network(
//                                 //                                   user.companyLogo!, // Replace with your image URL
//                                 //                                   fit: BoxFit
//                                 //                                       .cover,
//                                 //                                 )
//                                 //                               : const Center(
//                                 //                                   child:
//                                 //                                       Column(
//                                 //                                   mainAxisAlignment:
//                                 //                                       MainAxisAlignment
//                                 //                                           .center,
//                                 //                                   children: [
//                                 //                                     Row(
//                                 //                                       mainAxisAlignment:
//                                 //                                           MainAxisAlignment.center,
//                                 //                                       children: [
//                                 //                                         Text(
//                                 //                                           'Upload',
//                                 //                                           style: TextStyle(
//                                 //                                               fontSize: 17,
//                                 //                                               fontWeight: FontWeight.w600,
//                                 //                                               color: Colors.grey),
//                                 //                                         ),
//                                 //                                       ],
//                                 //                                     ),
//                                 //                                     Row(
//                                 //                                       mainAxisAlignment:
//                                 //                                           MainAxisAlignment.center,
//                                 //                                       children: [
//                                 //                                         Text(
//                                 //                                           'Company',
//                                 //                                           style: TextStyle(
//                                 //                                               fontSize: 17,
//                                 //                                               fontWeight: FontWeight.w600,
//                                 //                                               color: Colors.grey),
//                                 //                                         ),
//                                 //                                       ],
//                                 //                                     ),
//                                 //                                     Row(
//                                 //                                       mainAxisAlignment:
//                                 //                                           MainAxisAlignment.center,
//                                 //                                       children: [
//                                 //                                         Text(
//                                 //                                           'Logo',
//                                 //                                           style: TextStyle(
//                                 //                                               fontSize: 17,
//                                 //                                               fontWeight: FontWeight.w600,
//                                 //                                               color: Colors.grey),
//                                 //                                         ),
//                                 //                                       ],
//                                 //                                     ),
//                                 //                                   ],
//                                 //                                 ))),
//                                 //                 ),
//                                 //               ),
//                                 //               Positioned(
//                                 //                 bottom: -4,
//                                 //                 right: -4,
//                                 //                 child: InkWell(
//                                 //                   onTap: () {
//                                 //                     _pickFile(
//                                 //                         imageType: 'company');
//                                 //                   },
//                                 //                   child: Container(
//                                 //                     decoration: BoxDecoration(
//                                 //                       boxShadow: [
//                                 //                         BoxShadow(
//                                 //                           color: Colors.black
//                                 //                               .withOpacity(
//                                 //                                   0.2),
//                                 //                           offset:
//                                 //                               const Offset(
//                                 //                                   -1, -1),
//                                 //                           blurRadius: 4,
//                                 //                         ),
//                                 //                       ],
//                                 //                       shape: BoxShape.circle,
//                                 //                     ),
//                                 //                     child: const CircleAvatar(
//                                 //                       radius: 17,
//                                 //                       backgroundColor:
//                                 //                           Colors.white,
//                                 //                       child: Icon(
//                                 //                         Icons.edit,
//                                 //                         color:
//                                 //                             Color(0xFF004797),
//                                 //                         size: 16,
//                                 //                       ),
//                                 //                     ),
//                                 //                   ),
//                                 //                 ),
//                                 //               ),
//                                 //             ],
//                                 //           ),
//                                 //           if (state.hasError)
//                                 //             Padding(
//                                 //               padding: const EdgeInsets.only(
//                                 //                   top: 15),
//                                 //               child: Text(
//                                 //                 state.errorText ?? '',
//                                 //                 style: const TextStyle(
//                                 //                     color: Colors.red),
//                                 //               ),
//                                 //             ),
//                                 //         ],
//                                 //       ),
//                                 //     );
//                                 //   },
//                                 // ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       top: 20,
//                                       left: 20,
//                                       right: 20,
//                                       bottom: 10),
//                                   child: CustomTextFormField(
//                                       // validator: (value) {
//                                       //   if (value == null || value.isEmpty) {
//                                       //     return 'Please Enter Your Company Name';
//                                       //   }
//                                       //   return null;
//                                       // },
//                                       labelText: 'Enter Company Name',
//                                       textController: companyNameController),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(20),
//                                   child: CustomTextFormField(
//                                     // validator: (value) {
//                                     //   if (value == null || value.isEmpty) {
//                                     //     return 'Please Enter Your Company Address (street, city, state, zip)';
//                                     //   }
//                                     //   return null;
//                                     // },
//                                     labelText: 'Enter Company Address',
//                                     textController: companyAddressController,
//                                     maxLines: 3,
//                                     prefixIcon: const Icon(
//                                       Icons.location_city,
//                                       color: Color(0xFF004797),
//                                     ),
//                                   ),
//                                 ),
//                                 const Padding(
//                                   padding: EdgeInsets.only(
//                                       left: 20, right: 20, bottom: 20),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         'Phone Number',
//                                         style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w600),
//                                       ),
//                                       // CustomSwitch(
//                                       //   value: ref
//                                       //       .watch(isPhoneNumberVisibleProvider),
//                                       //   onChanged: (bool value) async {
//                                       //     SharedPreferences switchPreference =
//                                       //         await SharedPreferences
//                                       //             .getInstance();
//                                       //     switchPreference.setBool(
//                                       //         'phoneSwitch', value);
//                                       //     ref
//                                       //         .read(isPhoneNumberVisibleProvider
//                                       //             .notifier)
//                                       //         .state = value;
//                                       //   },
//                                       // ),
//                                     ],
//                                   ),
//                                 ),
//                                 // if (isPhoneNumberVisible)
//                                 // Padding(
//                                 //   padding: const EdgeInsets.only(
//                                 //       left: 20, right: 20, top: 0, bottom: 10),
//                                 //   child: CustomTextFormField(
//                                 //     validator: (value) {
//                                 //       if (value == null || value.isEmpty) {
//                                 //         return 'Please Enter Your Phone Number';
//                                 //       }
//                                 //       return null;
//                                 //     },
//                                 //     textController: personalPhoneController,
//                                 //     labelText: 'Enter phone number',
//                                 //     prefixIcon: const Icon(Icons.phone,
//                                 //         color: Color(0xFF004797)),
//                                 //   ),
//                                 // ),
//                                 // if (isPhoneNumberVisible && !isLandlineVisible)
//                                 // Padding(
//                                 //   padding: const EdgeInsets.only(
//                                 //       right: 20, bottom: 50),
//                                 //   child: GestureDetector(
//                                 //     onTap: () async {
//                                 //       SharedPreferences switchPreference =
//                                 //           await SharedPreferences.getInstance();
//                                 //       switchPreference.setBool(
//                                 //           'landlineAddmore',
//                                 //           !isLandlineVisible);
//                                 //       ref
//                                 //           .read(isLandlineVisibleProvider
//                                 //               .notifier)
//                                 //           .state = !isLandlineVisible;
//                                 //     },
//                                 //     child: const Row(
//                                 //       mainAxisAlignment: MainAxisAlignment.end,
//                                 //       children: [
//                                 //         Text(
//                                 //           'Add more',
//                                 //           style: TextStyle(
//                                 //               color: Color(0xFF004797),
//                                 //               fontWeight: FontWeight.w600,
//                                 //               fontSize: 15),
//                                 //         ),
//                                 //         Icon(
//                                 //           Icons.add,
//                                 //           color: Color(0xFF004797),
//                                 //           size: 18,
//                                 //         ),
//                                 //       ],
//                                 //     ),
//                                 //   ),
//                                 // ),
//                                 // if (isPhoneNumberVisible && isLandlineVisible)
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 20,
//                                       right: 20,
//                                       top: 10,
//                                       bottom: 20),
//                                   child: CustomTextFormField(
//                                     textController: landlineController,
//                                     labelText: 'Enter landline number',
//                                     prefixIcon: const Icon(
//                                         Icons.phone_in_talk,
//                                         color: Color(0xFF004797)),
//                                   ),
//                                 ),
//                                 const Padding(
//                                   padding: EdgeInsets.only(
//                                       left: 20, right: 20, bottom: 20),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         'Contact Details',
//                                         style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w600),
//                                       ),
//                                       // CustomSwitch(
//                                       //   value: ref.watch(
//                                       //       isContactDetailsVisibleProvider),
//                                       //   onChanged: (bool value) async {
//                                       //     SharedPreferences switchPreference =
//                                       //         await SharedPreferences
//                                       //             .getInstance();
//                                       //     switchPreference.setBool(
//                                       //         'contactSwitch', value);
//                                       //     ref
//                                       //         .read(
//                                       //             isContactDetailsVisibleProvider
//                                       //                 .notifier)
//                                       //         .state = value;
//                                       //     if (value == false) {
//                                       //       emailController.clear();
//                                       //       ref
//                                       //           .read(userProvider.notifier)
//                                       //           .updatePhoneNumbers(
//                                       //               whatsappBusinessNumber: 0,
//                                       //               companyPhoneNumber: 0,
//                                       //               landline: int.parse(
//                                       //                   landlineController.text),
//                                       //               personal: int.parse(
//                                       //                   personalPhoneController
//                                       //                       .text),
//                                       //               whatsappNumber: 0);
      
//                                       //       whatsappBusinessController.clear();
//                                       //       whatsappController.clear();
//                                       //     }
//                                       //   },
//                                       // ),
//                                     ],
//                                   ),
//                                 ),
//                                 // if (isContactDetailsVisible)
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 20,
//                                       right: 20,
//                                       top: 0,
//                                       bottom: 10),
//                                   child: CustomTextFormField(
//                                     textController: emailController,
//                                     labelText: 'Enter Email',
//                                     prefixIcon: const Icon(Icons.email,
//                                         color: Color(0xFF004797)),
//                                   ),
//                                 ),
//                                 // if (isContactDetailsVisible)
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 20,
//                                       right: 20,
//                                       top: 20,
//                                       bottom: 10),
//                                   child: CustomTextFormField(
//                                     textController:
//                                         whatsappBusinessController,
//                                     labelText: 'Enter Business Whatsapp',
//                                     prefixIcon: const SvgIcon(
//                                       assetName:
//                                           'assets/icons/whatsapp-business.svg',
//                                       color: Color(0xFF004797),
//                                       size: 10,
//                                     ),
//                                   ),
//                                 ),
//                                 // if (isContactDetailsVisible)
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 20,
//                                       right: 20,
//                                       top: 20,
//                                       bottom: 10),
//                                   child: CustomTextFormField(
//                                     textController: whatsappController,
//                                     labelText: 'Enter Whatsapp',
//                                     prefixIcon: const SvgIcon(
//                                       assetName: 'assets/icons/whatsapp.svg',
//                                       color: Color(0xFF004797),
//                                       size: 13,
//                                     ),
//                                   ),
//                                 ),
//                                 // if (isContactDetailsVisible)
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 20,
//                                       right: 20,
//                                       top: 20,
//                                       bottom: 10),
//                                   child: CustomTextFormField(
//                                     textController: addressController,
//                                     labelText: 'Enter Address',
//                                     maxLines: 3,
//                                     prefixIcon: const Icon(Icons.location_on,
//                                         color: Color(0xFF004797)),
//                                   ),
//                                 ),
//                                 // if (isContactDetailsVisible)
//                                 const Padding(
//                                   padding:
//                                       EdgeInsets.only(right: 20, bottom: 50),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       // Text(
//                                       //   'Add more',
//                                       //   style: TextStyle(
//                                       //       color: Color(0xFF004797),
//                                       //       fontWeight: FontWeight.w600,
//                                       //       fontSize: 15),
//                                       // ),
//                                       // Icon(
//                                       //   Icons.add,
//                                       //   color: Color(0xFF004797),
//                                       //   size: 18,
//                                       // )
//                                     ],
//                                   ),
//                                 ),
//                                 if (subscription == 'premium')
//                                   Column(
//                                     children: [
//                                       const Padding(
//                                         padding: EdgeInsets.only(
//                                             left: 20, right: 20),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               'Social Media',
//                                               style: TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight:
//                                                       FontWeight.w600),
//                                             ),
//                                             // CustomSwitch(
//                                             //   value: ref.watch(
//                                             //       isSocialDetailsVisibleProvider),
//                                             //   onChanged: (bool value) async {
//                                             //     SharedPreferences switchPreference =
//                                             //         await SharedPreferences
//                                             //             .getInstance();
//                                             //     switchPreference.setBool(
//                                             //         'socialSwitch', value);
//                                             //     ref
//                                             //         .read(isSocialDetailsVisibleProvider
//                                             //             .notifier)
//                                             //         .state = value;
//                                             //     if (value == false) {
//                                             //       ref
//                                             //           .read(userProvider.notifier)
//                                             //           .updateSocialMedia([], '', '');
//                                             //       log(user.socialMedia.toString());
//                                             //     }
//                                             //   },
//                                             // ),
//                                           ],
//                                         ),
//                                       ),
//                                       // if (isSocialDetailsVisible)
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 20,
//                                             right: 20,
//                                             top: 20,
//                                             bottom: 10),
//                                         child: CustomTextFormField(
//                                           validator: (value) =>
//                                               isValidUri(igController.text),
//                                           textController: igController,
//                                           labelText: 'Enter Instagram',
//                                           prefixIcon: const SvgIcon(
//                                             assetName:
//                                                 'assets/icons/instagram.svg',
//                                             size: 10,
//                                             color: Color(0xFF004797),
//                                           ),
//                                         ),
//                                       ),
//                                       // if (isSocialDetailsVisible)
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 20,
//                                             right: 20,
//                                             top: 20,
//                                             bottom: 10),
//                                         child: CustomTextFormField(
//                                           validator: (value) => isValidUri(
//                                               linkedinController.text),
//                                           textController: linkedinController,
//                                           labelText: 'Enter Linkedin',
//                                           prefixIcon: const SvgIcon(
//                                             assetName:
//                                                 'assets/icons/linkedin.svg',
//                                             color: Color(0xFF004797),
//                                             size: 10,
//                                           ),
//                                         ),
//                                       ),
//                                       // if (isSocialDetailsVisible)
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 20,
//                                             right: 20,
//                                             top: 20,
//                                             bottom: 10),
//                                         child: CustomTextFormField(
//                                           validator: (value) => isValidUri(
//                                               twtitterController.text),
//                                           textController: twtitterController,
//                                           labelText: 'Enter Twitter',
//                                           prefixIcon: const SvgIcon(
//                                             assetName:
//                                                 'assets/icons/twitter.svg',
//                                             color: Color(0xFF004797),
//                                             size: 13,
//                                           ),
//                                         ),
//                                       ),
//                                       // if (isSocialDetailsVisible)
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 20,
//                                             right: 20,
//                                             top: 20,
//                                             bottom: 10),
//                                         child: CustomTextFormField(
//                                           validator: (value) => isValidUri(
//                                               facebookController.text),
//                                           textController: facebookController,
//                                           labelText: 'Enter Facebook',
//                                           prefixIcon: const Icon(
//                                             Icons.facebook,
//                                             color: Color(0xFF004797),
//                                             size: 28,
//                                           ),
//                                         ),
//                                       ),
//                                       // if (isSocialDetailsVisible)
//                                       const Padding(
//                                         padding: EdgeInsets.only(
//                                             right: 20, bottom: 50),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.end,
//                                           children: [
//                                             // Text(
//                                             //   'Add more',
//                                             //   style: TextStyle(
//                                             //       color: Color(0xFF004797),
//                                             //       fontWeight: FontWeight.w600,
//                                             //       fontSize: 15),
//                                             // ),
//                                             // Icon(
//                                             //   Icons.add,
//                                             //   color: Color(0xFF004797),
//                                             //   size: 18,
//                                             // )
//                                           ],
//                                         ),
//                                       ),
//                                       const Padding(
//                                         padding: EdgeInsets.all(20),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               'Add Website Link',
//                                               style: TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight:
//                                                       FontWeight.w600),
//                                             ),
//                                             // CustomSwitch(
//                                             //   value: false,
//                                             //   onChanged: (bool value) {
//                                             //     setState(() {
//                                             //       // ref
//                                             //       // .read(isVideoDetailsVisibleProvider
//                                             //       //     .notifier)
//                                             //       // .state = value;
//                                             //     });
//                                             //   },
//                                             // ),
//                                           ],
//                                         ),
//                                       ),
//                                       ListView.builder(
//                                         shrinkWrap:
//                                             true, // Let ListView take up only as much space as it needs
//                                         physics:
//                                             const NeverScrollableScrollPhysics(), // Disable ListView's internal scrolling
//                                         itemCount: user.websites?.length,
//                                         itemBuilder: (context, index) {
//                                           log('Websites count: ${user.websites?.length}');
//                                           return Padding(
//                                             padding: const EdgeInsets
//                                                 .symmetric(
//                                                 vertical:
//                                                     4.0), // Space between items
//                                             child: customWebsiteCard(
//                                                 onRemove: () =>
//                                                     _removeWebsite(index),
//                                                 website:
//                                                     user.websites?[index]),
//                                           );
//                                         },
//                                       ),
//                                       // if (isWebsiteDetailsVisible)
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                           left: 20,
//                                           right: 20,
//                                         ),
//                                         child: CustomTextFormField(
//                                           textController:
//                                               websiteLinkController,
//                                           readOnly: true,
//                                           labelText: 'Enter Website Link',
//                                           suffixIcon: const Icon(
//                                             Icons.add,
//                                             color: Color(0xFF004797),
//                                           ),
//                                           onTap: () {
//                                             showWebsiteSheet(
//                                                 addWebsite: _addNewWebsite,
//                                                 textController1:
//                                                     websiteNameController,
//                                                 textController2:
//                                                     websiteLinkController,
//                                                 fieldName: 'Add Website Link',
//                                                 title: 'Add Website',
//                                                 context: context);
//                                           },
//                                         ),
//                                       ),
//                                       const Padding(
//                                         padding: EdgeInsets.all(20),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               'Add Video Link',
//                                               style: TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight:
//                                                       FontWeight.w600),
//                                             ),
//                                             // CustomSwitch(
//                                             //   value:
//                                             //       ref.watch(isVideoDetailsVisibleProvider),
//                                             //   onChanged: (bool value) {
//                                             //     setState(() {
//                                             //       ref
//                                             //           .read(isVideoDetailsVisibleProvider
//                                             //               .notifier)
//                                             //           .state = value;
//                                             //     });
//                                             //   },
//                                             // ),
//                                           ],
//                                         ),
//                                       ),
//                                       ListView.builder(
//                                         shrinkWrap:
//                                             true, // Let ListView take up only as much space as it needs
//                                         physics:
//                                             const NeverScrollableScrollPhysics(), // Disable ListView's internal scrolling
//                                         itemCount: user.video?.length,
//                                         itemBuilder: (context, index) {
//                                           log('video count: ${user.video?.length}');
//                                           return Padding(
//                                             padding: const EdgeInsets
//                                                 .symmetric(
//                                                 vertical:
//                                                     4.0), // Space between items
//                                             child: customVideoCard(
//                                                 onRemove: () =>
//                                                     _removeVideo(index),
//                                                 video: user.video?[index]),
//                                           );
//                                         },
//                                       ),
//                                       // if (isVideoDetailsVisible)
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 20, right: 20, bottom: 70),
//                                         child: CustomTextFormField(
//                                           textController: videoLinkController,
//                                           readOnly: true,
//                                           onTap: () {
//                                             showVideoLinkSheet(
//                                                 addVideo: _addNewVideo,
//                                                 textController1:
//                                                     videoNameController,
//                                                 textController2:
//                                                     videoLinkController,
//                                                 fieldName: 'Add Youtube Link',
//                                                 title: 'Add Video Link',
//                                                 context: context);
//                                           },
//                                           labelText: 'Enter Video Link',
//                                           suffixIcon: const Icon(
//                                             Icons.add,
//                                             color: Color(0xFF004797),
//                                           ),
//                                         ),
//                                       ),
      
//                                       // if (isVideoDetailsVisible)
      
//                                       const Padding(
//                                         padding: EdgeInsets.only(
//                                             left: 20,
//                                             right: 20,
//                                             top: 10,
//                                             bottom: 20),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               'Enter Awards',
//                                               style: TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight:
//                                                       FontWeight.w600),
//                                             ),
//                                             // CustomSwitch(
//                                             //   value: ref.watch(
//                                             //       isAwardsDetailsVisibleProvider),
//                                             //   onChanged: (bool value) async {
//                                             //     SharedPreferences switchPreference =
//                                             //         await SharedPreferences
//                                             //             .getInstance();
//                                             //     switchPreference.setBool(
//                                             //         'awardSwitch', value);
//                                             //     ref
//                                             //         .read(isAwardsDetailsVisibleProvider
//                                             //             .notifier)
//                                             //         .state = value;
      
//                                             //     // if (value == false) {
//                                             //     //   setState(
//                                             //     //     () {
//                                             //     //       awards = [];
//                                             //     //     },
//                                             //     //   );
//                                             //     // }
//                                             //   },
//                                             // ),
//                                           ],
//                                         ),
//                                       ),
//                                       // if (isAwardsDetailsVisible)
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 10, bottom: 10, right: 10),
//                                         child: GridView.builder(
//                                           shrinkWrap:
//                                               true, // Let GridView take up only as much space as it needs
//                                           physics:
//                                               const NeverScrollableScrollPhysics(), // Disable GridView's internal scrolling
//                                           gridDelegate:
//                                               const SliverGridDelegateWithFixedCrossAxisCount(
//                                             crossAxisCount:
//                                                 2, // Number of columns
//                                             crossAxisSpacing:
//                                                 8.0, // Space between columns
//                                             mainAxisSpacing:
//                                                 8.0, // Space between rows
//                                           ),
//                                           itemCount: user.awards!.length,
//                                           itemBuilder: (context, index) {
//                                             return AwardCard(
//                                               award: user.awards![index],
//                                               onRemove: () =>
//                                                   _removeAward(index),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       // if (isAwardsDetailsVisible)
//                                       GestureDetector(
//                                         onTap: () {
//                                           FocusManager.instance.primaryFocus
//                                               ?.unfocus();
      
//                                           Future.delayed(
//                                               const Duration(
//                                                   milliseconds: 50), () {
//                                             _openModalSheet(sheet: 'award');
//                                           });
//                                         },
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 25,
//                                               right: 25,
//                                               bottom: 60),
//                                           child: Container(
//                                             height: 120,
//                                             decoration: BoxDecoration(
//                                                 color:
//                                                     const Color(0xFFF2F2F2),
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                         10)),
//                                             child: const Center(
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Icon(
//                                                     Icons.add,
//                                                     color: Color(0xFF004797),
//                                                   ),
//                                                   SizedBox(
//                                                     height: 10,
//                                                   ),
//                                                   Text(
//                                                     'Enter Awards',
//                                                     style: TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 17),
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       const Padding(
//                                         padding: EdgeInsets.only(
//                                             left: 20,
//                                             right: 20,
//                                             top: 10,
//                                             bottom: 20),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               'Enter Products',
//                                               style: TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight:
//                                                       FontWeight.w600),
//                                             ),
//                                             // CustomSwitch(
//                                             //   value: ref.watch(
//                                             //       isProductsDetailsVisibleProvider),
//                                             //   onChanged: (bool value) async {
//                                             //     SharedPreferences switchPreference =
//                                             //         await SharedPreferences
//                                             //             .getInstance();
//                                             //     switchPreference.setBool(
//                                             //         'productSwitch', value);
//                                             //     ref
//                                             //         .read(
//                                             //             isProductsDetailsVisibleProvider
//                                             //                 .notifier)
//                                             //         .state = value;
//                                             //   },
//                                             // ),
//                                           ],
//                                         ),
//                                       ),
//                                       // if (user.products != null &&
//                                       //     isProductsDetailsVisible)
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 10, bottom: 10, right: 10),
//                                         child: GridView.builder(
//                                           shrinkWrap:
//                                               true, // Let GridView take up only as much space as it needs
//                                           physics:
//                                               const NeverScrollableScrollPhysics(), // Disable GridView's internal scrolling
//                                           gridDelegate:
//                                               const SliverGridDelegateWithFixedCrossAxisCount(
//                                             mainAxisExtent: 212,
//                                             crossAxisCount: 2,
//                                             crossAxisSpacing: 0.0,
//                                             mainAxisSpacing: 20.0,
//                                           ),
//                                           itemCount: user.products!.length,
//                                           itemBuilder: (context, index) {
//                                             return ProductCard(
//                                                 product:
//                                                     user.products![index],
//                                                 onRemove: () =>
//                                                     _removeProduct(index));
//                                           },
//                                         ),
//                                       ),
//                                       // if (isProductsDetailsVisible)
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 25, right: 25, bottom: 60),
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             FocusManager.instance.primaryFocus
//                                                 ?.unfocus();
      
//                                             _openModalSheet(
//                                               sheet: 'product',
//                                             );
//                                           },
//                                           child: Container(
//                                             height: 120,
//                                             decoration: BoxDecoration(
//                                                 color:
//                                                     const Color(0xFFF2F2F2),
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                         10)),
//                                             child: const Center(
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Icon(
//                                                     Icons.add,
//                                                     color: Color(0xFF004797),
//                                                   ),
//                                                   SizedBox(
//                                                     height: 10,
//                                                   ),
//                                                   Text(
//                                                     'Enter Products',
//                                                     style: TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 17),
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       const Padding(
//                                         padding: EdgeInsets.only(
//                                             left: 20,
//                                             right: 20,
//                                             top: 10,
//                                             bottom: 20),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               'Enter Certificates',
//                                               style: TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight:
//                                                       FontWeight.w600),
//                                             ),
//                                             // CustomSwitch(
//                                             //   value: ref.watch(
//                                             //       isCertificateDetailsVisibleProvider),
//                                             //   onChanged: (bool value) async {
//                                             //     SharedPreferences switchPreference =
//                                             //         await SharedPreferences
//                                             //             .getInstance();
//                                             //     switchPreference.setBool(
//                                             //         'certificateSwitch', value);
//                                             //     ref
//                                             //         .read(
//                                             //             isCertificateDetailsVisibleProvider
//                                             //                 .notifier)
//                                             //         .state = value;
//                                             //   },
//                                             // ),
//                                           ],
//                                         ),
//                                       ),
//                                       // if (user.certificates!.isNotEmpty &&
//                                       //     isCertificateDetailsVisible)
//                                       ListView.builder(
//                                         shrinkWrap:
//                                             true, // Let ListView take up only as much space as it needs
//                                         physics:
//                                             const NeverScrollableScrollPhysics(), // Disable ListView's internal scrolling
//                                         itemCount: user.certificates!.length,
//                                         itemBuilder: (context, index) {
//                                           return Padding(
//                                             padding: const EdgeInsets
//                                                 .symmetric(
//                                                 vertical:
//                                                     4.0), // Space between items
//                                             child: CertificateCard(
//                                               certificate:
//                                                   user.certificates![index],
//                                               onRemove: () =>
//                                                   _removeCertificate(index),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                       // if (isCertificateDetailsVisible)
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 25, right: 25, bottom: 60),
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             FocusManager.instance.primaryFocus
//                                                 ?.unfocus();
//                                             _openModalSheet(
//                                                 sheet: 'certificate');
//                                           },
//                                           child: Container(
//                                             height: 120,
//                                             decoration: BoxDecoration(
//                                                 color:
//                                                     const Color(0xFFF2F2F2),
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                         10)),
//                                             child: const Center(
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Icon(
//                                                     Icons.add,
//                                                     color: Color(0xFF004797),
//                                                   ),
//                                                   SizedBox(
//                                                     height: 10,
//                                                   ),
//                                                   Text(
//                                                     'Enter Certificates',
//                                                     style: TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 17),
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       const Padding(
//                                         padding: EdgeInsets.only(
//                                             left: 20,
//                                             right: 20,
//                                             top: 10,
//                                             bottom: 20),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               'Enter Brochure',
//                                               style: TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight:
//                                                       FontWeight.w600),
//                                             ),
//                                             // CustomSwitch(
//                                             //   value: ref.watch(
//                                             //       isBrochureDetailsVisibleProvider),
//                                             //   onChanged: (bool value) async {
//                                             //     SharedPreferences switchPreference =
//                                             //         await SharedPreferences
//                                             //             .getInstance();
//                                             //     switchPreference.setBool(
//                                             //         'brochureSwitch', value);
//                                             //     ref
//                                             //         .read(
//                                             //             isBrochureDetailsVisibleProvider
//                                             //                 .notifier)
//                                             //         .state = value;
//                                             //   },
//                                             // ),
//                                           ],
//                                         ),
//                                       ),
//                                       // if (user.brochure!.isNotEmpty &&
//                                       //     isBrochureDetailsVisible)
//                                       ListView.builder(
//                                         shrinkWrap:
//                                             true, // Let ListView take up only as much space as it needs
//                                         physics:
//                                             const NeverScrollableScrollPhysics(), // Disable ListView's internal scrolling
//                                         itemCount: user.brochure!.length,
//                                         itemBuilder: (context, index) {
//                                           return Padding(
//                                             padding: const EdgeInsets
//                                                 .symmetric(
//                                                 vertical:
//                                                     4.0), // Space between items
//                                             child: BrochureCard(
//                                               brochure: user.brochure![index],
//                                               onRemove: () =>
//                                                   _removeBrochure(index),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                       // if (isBrochureDetailsVisible)
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 25, right: 25, bottom: 60),
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             FocusManager.instance.primaryFocus
//                                                 ?.unfocus();
//                                             _openModalSheet(
//                                                 sheet: 'brochure');
//                                           },
//                                           child: Container(
//                                             height: 120,
//                                             decoration: BoxDecoration(
//                                                 color:
//                                                     const Color(0xFFF2F2F2),
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                         10)),
//                                             child: const Center(
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Icon(
//                                                     Icons.add,
//                                                     color: Color(0xFF004797),
//                                                   ),
//                                                   SizedBox(
//                                                     height: 10,
//                                                   ),
//                                                   Text(
//                                                     'Enter Brochure',
//                                                     style: TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 17),
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(height: 60),
//                                     ],
//                                   ),
//                                 if (subscription != 'premium')
//                                   Stack(
//                                     alignment: Alignment.center,
//                                     children: [
//                                       Container(
//                                         color: const Color(0xFFF2F2F2),
//                                         child: Column(
//                                           children: [
//                                             const SizedBox(
//                                               height: 30,
//                                             ),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 20, right: 20),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   const Text(
//                                                     'Social Media',
//                                                     style: TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.w600),
//                                                   ),
//                                                   CustomSwitch(
//                                                     value: false,
//                                                     onChanged:
//                                                         (bool value) async {},
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 20,
//                                                   right: 20,
//                                                   top: 20),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   const Text(
//                                                     'Add Website',
//                                                     style: TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.w600),
//                                                   ),
//                                                   CustomSwitch(
//                                                     value: false,
//                                                     onChanged:
//                                                         (bool value) async {},
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 20,
//                                                   right: 20,
//                                                   top: 20),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   const Text(
//                                                     'Add Video Link',
//                                                     style: TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.w600),
//                                                   ),
//                                                   CustomSwitch(
//                                                     value: false,
//                                                     onChanged:
//                                                         (bool value) async {},
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 20,
//                                                   right: 20,
//                                                   top: 20),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   const Text(
//                                                     'Enter Awards',
//                                                     style: TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.w600),
//                                                   ),
//                                                   CustomSwitch(
//                                                     value: false,
//                                                     onChanged:
//                                                         (bool value) async {},
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 20,
//                                                   right: 20,
//                                                   top: 20),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   const Text(
//                                                     'Enter Products',
//                                                     style: TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.w600),
//                                                   ),
//                                                   CustomSwitch(
//                                                     value: false,
//                                                     onChanged:
//                                                         (bool value) async {},
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 20,
//                                                   right: 20,
//                                                   top: 20),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   const Text(
//                                                     'Enter Certicates',
//                                                     style: TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.w600),
//                                                   ),
//                                                   CustomSwitch(
//                                                     value: false,
//                                                     onChanged:
//                                                         (bool value) async {},
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 20,
//                                                   right: 20,
//                                                   top: 20),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   const Text(
//                                                     'Enter Borchure',
//                                                     style: TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.w600),
//                                                   ),
//                                                   CustomSwitch(
//                                                     value: false,
//                                                     onChanged:
//                                                         (bool value) async {},
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             const SizedBox(
//                                               height: 80,
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                       GestureDetector(
//                                         onTap: () => showDialog(
//                                           context: context,
//                                           builder: (context) =>
//                                               const UpgradeDialog(),
//                                         ),
//                                         child: Container(
//                                           padding: const EdgeInsets.all(16),
//                                           decoration: BoxDecoration(
//                                             color: Colors.white,
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                             boxShadow: [
//                                               BoxShadow(
//                                                 color: Colors.black
//                                                     .withOpacity(0.1),
//                                                 blurRadius: 10,
//                                                 spreadRadius: 2,
//                                                 offset: const Offset(0, 4),
//                                               ),
//                                             ],
//                                           ),
//                                           child: Column(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               SvgPicture.asset(
//                                                   'assets/icons/lock_person.svg'),
//                                               const SizedBox(height: 8),
//                                               const Text(
//                                                 "Upgrade to",
//                                                 style: TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w500,
//                                                 ),
//                                               ),
//                                               const Text(
//                                                 "unlock",
//                                                 style: TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w500,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       )
//                                     ],
//                                   )
//                               ],
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                             bottom: 20,
//                             left: 20,
//                             right: 20,
//                             child: SizedBox(
//                                 height: 50,
//                                 child: customButton(
//                                     fontSize: 16,
//                                     label: 'Save & Proceed',
//                                     onPressed: () async {
//                                       if (_formKey.currentState!.validate()) {
//                                         log('Updating social media: ${user.socialMedia.toString()}');
//                                         String response =
//                                             await _submitData(user: user);
//                                         ApiRoutes api = ApiRoutes();
//                                         // for (var files in filesToBeDeleted) {
//                                         //   api.deleteFile(token, files);
//                                         // }
//                                         if (response.contains('success')) {
//                                           ref.invalidate(userProvider);
//                                           // CustomSnackbar.showSnackbar(
//                                           //     context, response);
//                                           navigateBasedOnPreviousPage();
//                                         } else {
//                                           CustomSnackbar.showSnackbar(
//                                               context, response);
//                                         }
//                                       }
//                                     }))),
//                       ],
//                     );
//                   },
//                 );
//               },
//             )),
//       ),
//     );
//   }

//   Widget _buildImagePickerOptions(BuildContext context, String imageType) {
//     return Wrap(
//       children: [
//         ListTile(
//           leading: const Icon(Icons.photo_library),
//           title: const Text('Choose from Gallery'),
//           onTap: () {
//             Navigator.pop(context);
//             _pickImage(ImageSource.gallery, imageType);
//           },
//         ),
//         // ListTile(
//         //   leading: const Icon(Icons.camera_alt),
//         //   title: const Text('Take a Photo'),
//         //   onTap: () {
//         //     Navigator.pop(context);
//         //     _pickImage(ImageSource.camera, imageType);
//         //   },
//         // ),
//       ],
//     );
//   }
// }
