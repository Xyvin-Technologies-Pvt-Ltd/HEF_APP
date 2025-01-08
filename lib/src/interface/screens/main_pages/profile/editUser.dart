import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/edit_user.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/data/services/image_upload.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/Cards/award_card.dart';
import 'package:hef/src/interface/components/Cards/certificate_card.dart';
import 'package:hef/src/interface/components/ModalSheets/add_award.dart';
import 'package:hef/src/interface/components/ModalSheets/add_certificate.dart';
import 'package:hef/src/interface/components/ModalSheets/add_website_video.dart';
import 'package:hef/src/interface/components/custom_widgets/custom_textFormField.dart';
import 'package:hef/src/interface/components/custom_widgets/custom_websiteVideo_card.dart';
import 'package:hef/src/interface/components/edit_user/contact_editor.dart';
import 'package:hef/src/interface/components/edit_user/social_media_editor.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/components/shimmers/edit_user_shimmer.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as Path;
import 'package:permission_handler/permission_handler.dart';

class EditUser extends ConsumerStatefulWidget {
  const EditUser({super.key});

  @override
  ConsumerState<EditUser> createState() => _EditUserState();
}

class _EditUserState extends ConsumerState<EditUser> {
  // final isPhoneNumberVisibleProvider = StateProvider<bool>((ref) => false);

  // final isLandlineVisibleProvider = StateProvider<bool>((ref) => false);

  // final isContactDetailsVisibleProvider = StateProvider<bool>((ref) => false);
  // final isSocialDetailsVisibleProvider = StateProvider<bool>((ref) => false);
  // final isWebsiteDetailsVisibleProvider = StateProvider<bool>((ref) => false);
  // final isVideoDetailsVisibleProvider = StateProvider<bool>((ref) => false);
  // final isAwardsDetailsVisibleProvider = StateProvider<bool>((ref) => false);
  // final isProductsDetailsVisibleProvider = StateProvider<bool>((ref) => false);
  // final isCertificateDetailsVisibleProvider =
  //     StateProvider<bool>((ref) => false);
  // final isBrochureDetailsVisibleProvider = StateProvider<bool>((ref) => false);

  final TextEditingController nameController = TextEditingController();

  final TextEditingController landlineController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController profilePictureController =
      TextEditingController();
  final TextEditingController personalPhoneController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController companyPhoneController = TextEditingController();

  final TextEditingController designationController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyEmailController = TextEditingController();
  final TextEditingController companyWebsiteController =
      TextEditingController();
  final TextEditingController companyAddressController =
      TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController igController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();
  final TextEditingController twtitterController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController websiteNameController = TextEditingController();
  final TextEditingController websiteLinkController = TextEditingController();
  final TextEditingController videoNameController = TextEditingController();
  final TextEditingController videoLinkController = TextEditingController();
  final TextEditingController awardNameController = TextEditingController();
  final TextEditingController awardAuthorityController =
      TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productDescriptionController =
      TextEditingController();
  final TextEditingController productMoqController = TextEditingController();
  final TextEditingController productActualPriceController =
      TextEditingController();
  final TextEditingController productOfferPriceController =
      TextEditingController();
  final TextEditingController certificateNameController =
      TextEditingController();
  final TextEditingController brochureNameController = TextEditingController();
  File? _profileImageFile;
  File? _companyImageFile;
  File? _awardImageFIle;
  File? _certificateImageFIle;
  File? _brochurePdfFile;
  ImageSource? _profileImageSource;
  ImageSource? _companyImageSource;
  ImageSource? _awardImageSource;
  ImageSource? _certificateSource;
  NavigationService navigationService = NavigationService();
  final _formKey = GlobalKey<FormState>();

  String productUrl = '';

  Future<void> _pickImage(ImageSource source, String imageType) async {
    PermissionStatus status;

    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else if (source == ImageSource.gallery) {
      status = await Permission.photos.request();
    } else {
      return;
    }

    if (status.isGranted) {
      _pickFile(imageType: imageType);
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(true);
    } else {
      _showPermissionDeniedDialog(false);
    }
  }

  Future<File?> _pickFile({required String imageType}) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (imageType == 'profile') {
        setState(() {
          _profileImageFile = File(image.path);
          imageUpload(Path.basename(_profileImageFile!.path),
                  _profileImageFile!.path)
              .then((url) {
            String profileUrl = url;
            _profileImageSource = ImageSource.gallery;
            ref.read(userProvider.notifier).updateProfilePicture(profileUrl);
            print((profileUrl));
          });
        });
        return _profileImageFile;
      } else if (imageType == 'award') {
        _awardImageFIle = File(image.path);
        _awardImageSource = ImageSource.gallery;
        return _awardImageFIle;
      } else if (imageType == 'certificate') {
        _certificateImageFIle = File(image.path);
        _certificateSource = ImageSource.gallery;
        return _certificateImageFIle;
      } else {
        _brochurePdfFile = File(image.path);
        return _brochurePdfFile;
      }
    }
    return null;
  }

  // void _addAwardCard() async {
  // await api.createFileUrl(file: _awardImageFIle!).then((url) {
  //   awardUrl = url;
  //   print((awardUrl));
  // });
  //   ref.read(userProvider.notifier).updateAwards([...?ref.read(userProvider).value?.awards, newAward]);
  // }

  Future<void> _addNewAward() async {
    await imageUpload(
            Path.basename(_awardImageFIle!.path), _awardImageFIle!.path)
        .then((url) {
      final String awardUrl = url;
      final newAward = Award(
        name: awardNameController.text,
        image: awardUrl,
        authority: awardAuthorityController.text,
      );

      ref
          .read(userProvider.notifier)
          .updateAwards([...?ref.read(userProvider).value?.awards, newAward]);
    });
  }

  void _removeAward(int index) async {
    ref
        .read(userProvider.notifier)
        .removeAward(ref.read(userProvider).value!.awards![index]);
  }

  void _addNewWebsite() async {
    Link newWebsite = Link(
        link: websiteLinkController.text.toString(),
        name: websiteNameController.text.toString());
    log('Hello im in website bug:${ref.read(userProvider).value?.websites}');
    ref.read(userProvider.notifier).updateWebsite(
        [...?ref.read(userProvider).value?.websites, newWebsite]);
    websiteLinkController.clear();
    websiteNameController.clear();
  }

  void _removeWebsite(int index) async {
    ref
        .read(userProvider.notifier)
        .removeWebsite(ref.read(userProvider).value!.websites![index]);
  }

  void _addNewVideo() async {
    Link newVideo = Link(
        link: videoLinkController.text.toString(),
        name: videoNameController.text.toString());
    log('Hello im in website bug:${ref.read(userProvider).value?.videos}');
    ref
        .read(userProvider.notifier)
        .updateVideos([...?ref.read(userProvider).value?.videos, newVideo]);
    videoLinkController.clear();
    videoNameController.clear();
  }

  void _removeVideo(int index) async {
    ref
        .read(userProvider.notifier)
        .removeVideo(ref.read(userProvider).value!.videos![index]);
  }

  Future<void> _addNewCertificate() async {
    await imageUpload(Path.basename(_certificateImageFIle!.path),
            _certificateImageFIle!.path)
        .then((url) {
      final String certificateUrl = url;
      final newCertificate =
          Link(name: certificateNameController.text, link: certificateUrl);

      ref.read(userProvider.notifier).updateCertificate(
          [...?ref.read(userProvider).value?.certificates, newCertificate]);
    });
  }

  void _removeCertificate(int index) async {
    ref
        .read(userProvider.notifier)
        .removeCertificate(ref.read(userProvider).value!.certificates![index]);
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    nameController.dispose();

    bloodGroupController.dispose();
    emailController.dispose();
    profilePictureController.dispose();
    personalPhoneController.dispose();
    landlineController.dispose();
    companyPhoneController.dispose();
    designationController.dispose();
    companyNameController.dispose();
    companyEmailController.dispose();
    bioController.dispose();
    addressController.dispose();

    super.dispose();
  }

  Future<String> _submitData({required UserModel user}) async {
    // String fullName =
    //     '${user.name!.first} ${user.name!.middle} ${user.name!.last}';

    // List<String> nameParts = fullName.split(' ');

    // String firstName = nameParts[0];
    // String middleName = nameParts.length > 2 ? nameParts[1] : ' ';
    // String lastName = nameParts.length > 1 ? nameParts.last : ' ';

    final Map<String, dynamic> profileData = {
      "name": user.name ?? '',
      "email": user.email,
      "phone": user.phone,
      if (user.image != null) "image": user.image ?? '',
      if (user.address != null) "address": user.address ?? '',
      if (user.bio != null) "bio": user.bio ?? '',
      "chapter": user.chapter,
      if (user.secondaryPhone != null)
        "secondaryPhone": {
          if (user.secondaryPhone?.whatsapp != null)
            "whatsapp": user.secondaryPhone?.whatsapp ?? '',
          if (user.secondaryPhone?.business != null)
            "business": user.secondaryPhone?.business ?? '',
        },
      if (user.company != null)
        "company": {
          if (user.company?.name != null) "name": user.company?.name ?? '',
          if (user.company?.designation != null)
            "designation": user.company?.designation ?? '',
          if (user.company?.phone != null) "phone": user.company?.phone ?? '',
          if (user.company?.email != null) "email": user.company?.email ?? '',
          if (user.company?.websites != null)
            "websites": user.company?.websites ?? '',
        },
      "social": [
        for (var i in user.social!) {"name": "${i.name}", "link": i.link}
      ],
      "websites": [
        for (var i in user.websites!)
          {"name": i.name.toString(), "link": i.link}
      ],
      "videos": [
        for (var i in user.videos!) {"name": i.name, "link": i.link}
      ],
      "awards": [
        for (var i in user.awards!)
          {"name": i.name, "image": i.image, "authority": i.authority}
      ],
      "certificates": [
        for (var i in user.certificates!) {"name": i.name, "link": i.link}
      ],
    };
    String response = await editUser(profileData);
    log(profileData.toString());
    return response;
  }

  // Future<void> _selectImageFile(ImageSource source, String imageType) async {
  //   final XFile? image = await _picker.pickImage(source: source);
  //   print('$image');
  //   if (image != null && imageType == 'profile') {
  //     setState(() {
  //       _profileImageFile = _pickFile()
  //     });
  //   } else if (image != null && imageType == 'company') {
  //     setState(() {
  //       _companyImageFile = File(image.path);
  //     });
  //   }
  // }

  void _showPermissionDeniedDialog(bool isPermanentlyDenied) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content: Text(isPermanentlyDenied
              ? 'Permission is permanently denied. Please enable it from the app settings.'
              : 'Permission is denied. Please grant the permission to proceed.'),
          actions: [
            TextButton(
              onPressed: () {
                navigationService.pop();
                if (isPermanentlyDenied) {
                  openAppSettings();
                }
              },
              child: Text(isPermanentlyDenied ? 'Open Settings' : 'OK'),
            ),
          ],
        );
      },
    );
  }

  void _openModalSheet({required String sheet}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        if (sheet == 'award') {
          return ShowEnterAwardSheet(
            pickImage: _pickFile,
            addAwardCard: _addNewAward,
            imageType: sheet,
            textController1: awardNameController,
            textController2: awardAuthorityController,
          );
        } else {
          return ShowAddCertificateSheet(
              addCertificateCard: _addNewCertificate,
              textController: certificateNameController,
              imageType: sheet,
              pickImage: _pickFile);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(userProvider);
    void navigateBasedOnPreviousPage() {
      final previousPage = ModalRoute.of(context)?.settings.name;
      log('previousPage: $previousPage');
      if (previousPage == 'ProfileCompletion') {
        navigationService.pushNamedReplacement('MainPage');
      } else {
        navigationService.pop();
        ref.read(userProvider.notifier).refreshUser();
      }
    }
    // final isSocialDetailsVisible = ref.watch(isSocialDetailsVisibleProvider);
    // final isWebsiteDetailsVisible = ref.watch(isWebsiteDetailsVisibleProvider);
    // final isVideoDetailsVisible = ref.watch(isVideoDetailsVisibleProvider);
    // final isAwardsDetailsVisible = ref.watch(isAwardsDetailsVisibleProvider);

    // final isCertificateDetailsVisible =
    //     ref.watch(isCertificateDetailsVisibleProvider);

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            backgroundColor: kScaffoldColor,
            body: asyncUser.when(
              loading: () {
                return const EditUserShimmer();
              },
              error: (error, stackTrace) {
                return Center(
                  child: Text('Error loading User: $error '),
                );
              },
              data: (user) {
                if (nameController.text.isEmpty) {
                  nameController.text = user.name ?? '';
                }

                if (designationController.text.isEmpty) {
                  designationController.text = user.company?.designation ?? '';
                }
                if (bioController.text.isEmpty) {
                  bioController.text = user.bio ?? '';
                }
                if (companyPhoneController.text.isEmpty) {
                  companyPhoneController.text = user.company?.phone ?? '';
                }
                if (companyNameController.text.isEmpty) {
                  companyNameController.text = user.company?.name ?? '';
                }
                if (companyAddressController.text.isEmpty) {
                  companyAddressController.text = user.company?.email ?? '';
                }
                if (companyWebsiteController.text.isEmpty) {
                  companyWebsiteController.text = user.company?.websites ?? '';
                }
                if (personalPhoneController.text.isEmpty) {
                  personalPhoneController.text = user.phone ?? '';
                }
                if (emailController.text.isEmpty) {
                  emailController.text = user.email ?? '';
                }
                if (addressController.text.isEmpty) {
                  addressController.text = user.address ?? '';
                }

                // List<TextEditingController> socialLinkControllers = [
                //   igController,
                //   linkedinController,
                //   twtitterController,
                //   facebookController
                // ];
                for (Link social in user.social ?? []) {
                  if (social.name == 'instagram' && igController.text.isEmpty) {
                    igController.text = social.link ?? '';
                  } else if (social.name == 'linkedin' &&
                      linkedinController.text.isEmpty) {
                    linkedinController.text = social.link ?? '';
                  } else if (social.name == 'twitter' &&
                      twtitterController.text.isEmpty) {
                    twtitterController.text = social.link ?? '';
                  } else if (social.name == 'facebook' &&
                      facebookController.text.isEmpty) {
                    facebookController.text = social.link ?? '';
                  }
                }

                // for (int i = 0; i < socialLinkControllers.length; i++) {
                //   if (i < user.social!.length) {
                //     socialLinkControllers[i].text = user.social![i].link ?? '';
                //     log('social : ${socialLinkControllers[i].text}');
                //   }
                // else {
                //   socialLinkControllers[i].clear();
                // }
                // }

                // List<TextEditingController> websiteLinkControllers = [
                //   websiteLinkController
                // ];
                // List<TextEditingController> websiteNameControllers = [
                //   websiteNameController
                // ];

                // for (int i = 0; i < websiteLinkControllers.length; i++) {
                //   if (i < user.websites!.length) {
                //     websiteLinkControllers[i].text = user.websites![i].link ?? '';
                //     websiteNameControllers[i].text = user.websites![i].name ?? '';
                //   } else {
                //     websiteLinkControllers[i].clear();
                //     websiteNameControllers[i].clear();
                //   }
                // }

                // List<TextEditingController> videoLinkControllers = [
                //   videoLinkController
                // ];
                // List<TextEditingController> videoNameControllers = [
                //   videoNameController
                // ];

                // for (int i = 0; i < videoLinkControllers.length; i++) {
                //   if (i < user.videos!.length) {
                //     videoLinkControllers[i].text = user.videos![i].link ?? '';
                //     videoNameControllers[i].text = user.videos![i].name ?? '';
                //   } else {
                //     videoLinkControllers[i].clear();
                //     videoNameControllers[i].clear();
                //   }
                // }

                return PopScope(
                  onPopInvoked: (didPop) {
                    if (didPop) {
                      ref.read(userProvider.notifier).refreshUser();
                    }
                  },
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                child: AppBar(
                                  scrolledUnderElevation: 0,
                                  backgroundColor: kScaffoldColor,
                                  elevation: 0,
                                  leadingWidth: 50,
                                  leading: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Image.asset(
                                        'assets/pngs/hef_logo.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          ref
                                              .read(userProvider.notifier)
                                              .refreshUser();
                                          navigateBasedOnPreviousPage();
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        )),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 35),
                              FormField<File>(
                                // validator: (value) {
                                //   if (user.image == null) {
                                //     return 'Please select a profile image';
                                //   }
                                //   return null;
                                // },
                                builder: (FormFieldState<File> state) {
                                  return Center(
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            DottedBorder(
                                              borderType: BorderType.Circle,
                                              dashPattern: [6, 3],
                                              color: Colors.grey,
                                              strokeWidth: 2,
                                              child: ClipOval(
                                                child: Container(
                                                  width: 120,
                                                  height: 120,
                                                  color: const Color.fromARGB(
                                                      255, 255, 255, 255),
                                                  child: Image.network(
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Image.asset(
                                                          scale: .7,
                                                          'assets/icons/dummy_person.png');
                                                    },
                                                    user.image ??
                                                        '', // Replace with your image URL
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 4,
                                              right: 4,
                                              child: InkWell(
                                                onTap: () {
                                                  _pickFile(
                                                      imageType: 'profile');
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        offset:
                                                            const Offset(2, 2),
                                                        blurRadius: 4,
                                                      ),
                                                    ],
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const CircleAvatar(
                                                    radius: 17,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Icon(
                                                      Icons.edit,
                                                      color: kPrimaryColor,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (state.hasError)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 15),
                                            child: Text(
                                              state.errorText ?? '',
                                              style: const TextStyle(
                                                  color: kPrimaryColor),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 60, left: 16, bottom: 10),
                                    child: Text('Personal Details',
                                        style: kSubHeadingB.copyWith(
                                            color: const Color(0xFF2C2829))),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 10, bottom: 10),
                                child: Column(
                                  children: [
                                    CustomTextFormField(
                                      title: 'Full Name',
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Enter Your Name';
                                        }
                                        return null;
                                      },
                                      textController: nameController,
                                      labelText: 'Enter your Name',
                                    ),
                                    const SizedBox(height: 20.0),

                                    // CustomTextFormField(
                                    //     readOnly: true,
                                    //     validator: (value) {
                                    //       if (value == null || value.isEmpty) {
                                    //         return 'Please Enter Your Phone';
                                    //       }
                                    //       return null;
                                    //     },
                                    //     textController: personalPhoneController,
                                    //     labelText: 'Enter Your Phone'),
                                    // const SizedBox(height: 20.0),
                                    // CustomTextFormField(
                                    //     readOnly: true,
                                    //     validator: (value) {
                                    //       if (value == null || value.isEmpty) {
                                    //         return 'Please Select Your College';
                                    //       }
                                    //       return null;
                                    //     },
                                    //     textController: collegeController,
                                    //     labelText: 'Select Your College'),
                                    // const SizedBox(height: 20.0),
                                    // CustomTextFormField(
                                    //     readOnly: true,
                                    //     validator: (value) {
                                    //       if (value == null || value.isEmpty) {
                                    //         return 'Please Select Your Batch';
                                    //       }
                                    //       return null;
                                    //     },
                                    //     textController: batchController,
                                    //     labelText: 'Select Your Batch'),
                                    // const SizedBox(height: 20.0),
                                    // CustomTextFormField(
                                    //     readOnly: true,
                                    //     validator: (value) {
                                    //       if (value == null || value.isEmpty) {
                                    //         return 'Please Enter Your Email';
                                    //       }
                                    //       return null;
                                    //     },
                                    //     textController: emailController,
                                    //     labelText: 'Enter Your Email'),

                                    CustomTextFormField(
                                        title: 'Description',
                                        // validator: (value) {
                                        //   if (value == null || value.isEmpty) {
                                        //     return 'Please Enter Your Bio';
                                        //   }
                                        //   return null;
                                        // },
                                        textController: bioController,
                                        labelText: 'Bio',
                                        maxLines: 5),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, left: 20, bottom: 15),
                                child: Row(
                                  children: [
                                    Text('Contact',
                                        style: kSubHeadingB.copyWith(
                                            color: const Color(0xFF2C2829))),
                                  ],
                                ),
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ContactEditor(
                                      value:
                                          user.secondaryPhone?.whatsapp ?? '',
                                      icon: FontAwesomeIcons.whatsapp,
                                      onSave: (whatsapp) {
                                        ref
                                            .read(userProvider.notifier)
                                            .updateSecondaryPhone(
                                                SecondaryPhone(
                                                    whatsapp: whatsapp));
                                      },
                                      label: 'Whatsapp'),
                                  ContactEditor(
                                      value: user.email ?? '',
                                      icon: FontAwesomeIcons.at,
                                      onSave: (email) {
                                        ref
                                            .read(userProvider.notifier)
                                            .updateEmail(email);
                                      },
                                      label: 'Email'),
                                  ContactEditor(
                                      value:
                                          user.secondaryPhone?.business ?? '',
                                      icon: FontAwesomeIcons.b,
                                      onSave: (business) {
                                        ref
                                            .read(userProvider.notifier)
                                            .updateSecondaryPhone(
                                                SecondaryPhone(
                                                    business: business));
                                      },
                                      label: 'Whatsapp Bussiness'),
                                  ContactEditor(
                                      value: user.address ?? '',
                                      icon: FontAwesomeIcons.locationDot,
                                      onSave: (address) {
                                        ref
                                            .read(userProvider.notifier)
                                            .updateAddress(address);
                                      },
                                      label: 'Address'),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, left: 20, bottom: 15),
                                child: Row(
                                  children: [
                                    Text('Social Media',
                                        style: kSubHeadingB.copyWith(
                                            color: const Color(0xFF2C2829))),
                                  ],
                                ),
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SocialMediaEditor(
                                    icon: FontAwesomeIcons.instagram,
                                    socialMedias: user.social ?? [],
                                    platform: 'Instagram',
                                    onSave: (socialMedias, platform, newUrl) {
                                      ref
                                          .read(userProvider.notifier)
                                          .updateSocialMedia(
                                              socialMedias, platform, newUrl);
                                    },
                                  ),
                                  SocialMediaEditor(
                                    icon: FontAwesomeIcons.linkedinIn,
                                    socialMedias: user.social ?? [],
                                    platform: 'Linkedin',
                                    onSave: (socialMedias, platform, newUrl) {
                                      ref
                                          .read(userProvider.notifier)
                                          .updateSocialMedia(
                                              socialMedias, platform, newUrl);
                                    },
                                  ),
                                  SocialMediaEditor(
                                    icon: FontAwesomeIcons.xTwitter,
                                    socialMedias: user.social ?? [],
                                    platform: 'Twitter',
                                    onSave: (socialMedias, platform, newUrl) {
                                      ref
                                          .read(userProvider.notifier)
                                          .updateSocialMedia(
                                              socialMedias, platform, newUrl);
                                    },
                                  ),
                                  SocialMediaEditor(
                                    icon: FontAwesomeIcons.facebookF,
                                    socialMedias: user.social ?? [],
                                    platform: 'Facebook',
                                    onSave: (socialMedias, platform, newUrl) {
                                      ref
                                          .read(userProvider.notifier)
                                          .updateSocialMedia(
                                              socialMedias, platform, newUrl);
                                    },
                                  ),
                                  // SocialMediaEditor(
                                  //   icon: FontAwesomeIcons.instagram,
                                  //   socialMedias: user.social ?? [],
                                  //   platform: 'Instagram',
                                  //   onSave: (socialMedias, platform, newUrl) {
                                  //     ref
                                  //         .read(userProvider.notifier)
                                  //         .updateSocialMedia(
                                  //             socialMedias, platform, newUrl);
                                  //   },
                                  // ),
                                ],
                              ),
                              const Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 60, left: 16, bottom: 10),
                                    child: Text(
                                      'Company Details',
                                      style: kSubHeadingB,
                                    ),
                                  ),
                                ],
                              ),

                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, left: 20, right: 20, bottom: 10),
                                child: CustomTextFormField(
                                    title: 'Designation',
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'Please Enter Your Company Designation';
                                    //   }
                                    //   return null;
                                    // },
                                    labelText: 'Enter Designation',
                                    textController: designationController),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 20, right: 20, bottom: 10),
                                child: CustomTextFormField(
                                    title: 'Company Name',
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'Please Enter Company Name';
                                    //   }
                                    //   return null;
                                    // },
                                    labelText: 'Enter Company Name',
                                    textController: companyNameController),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: CustomTextFormField(
                                  title: 'Company Phone',
                                  // validator: (value) {
                                  //   if (value == null || value.isEmpty) {
                                  //     return 'Please Enter Your Company Phone';
                                  //   }
                                  //   return null;
                                  // },
                                  labelText: 'Enter Company Phone',
                                  textController: companyPhoneController,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: CustomTextFormField(
                                  title: 'Company Email',
                                  // validator: (value) {
                                  //   if (value == null || value.isEmpty) {
                                  //     return 'Please Enter Your Company Address (street, city, state, zip)';
                                  //   }
                                  //   return null;
                                  // },
                                  labelText: 'Enter Company Email',
                                  textController: companyAddressController,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: CustomTextFormField(
                                  title: 'Company Website',
                                  // validator: (value) {
                                  //   if (value == null || value.isEmpty) {
                                  //     return 'Please Enter Your Company Address (street, city, state, zip)';
                                  //   }
                                  //   return null;
                                  // },
                                  labelText: 'Enter Company Website',
                                  textController: companyAddressController,
                                ),
                              ),
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.only(left: 20, right: 20),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       const Text(
                              //         'Social Media',
                              //         style: TextStyle(
                              //             fontSize: 16,
                              //             fontWeight: FontWeight.w600),
                              //       ),
                              //       // CustomSwitch(
                              //       //   value:
                              //       //       ref.watch(isSocialDetailsVisibleProvider),
                              //       //   onChanged: (bool value) {
                              //       //     setState(() {
                              //       //       ref
                              //       //           .read(isSocialDetailsVisibleProvider
                              //       //               .notifier)
                              //       //           .state = value;
                              //       //     });
                              //       //   },
                              //       // ),
                              //     ],
                              //   ),
                              // ),
                              // // if (isSocialDetailsVisible)
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 20, right: 20, top: 20, bottom: 10),
                              //   child: CustomTextFormField(
                              //     textController: igController,
                              //     labelText: 'Enter Instagram',
                              //     prefixIcon: SvgPicture.asset(
                              //         'assets/svg/icons/instagram.svg',
                              //         color: kPrimaryColor),
                              //   ),
                              // ),
                              // // if (isSocialDetailsVisible)
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 20, right: 20, top: 20, bottom: 10),
                              //   child: CustomTextFormField(
                              //     textController: linkedinController,
                              //     labelText: 'Enter Linkedin',
                              //     prefixIcon: SvgPicture.asset(
                              //         'assets/svg/icons/linkedin.svg',
                              //         color: kPrimaryColor),
                              //   ),
                              // ),
                              // // if (isSocialDetailsVisible)
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 20, right: 20, top: 20, bottom: 10),
                              //   child: CustomTextFormField(
                              //     textController: twtitterController,
                              //     labelText: 'Enter Twitter',
                              //     prefixIcon: SvgPicture.asset(
                              //         'assets/svg/icons/twitter.svg',
                              //         color: kPrimaryColor),
                              //   ),
                              // ),
                              // // if (isSocialDetailsVisible)
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 20, right: 20, top: 20, bottom: 10),
                              //   child: CustomTextFormField(
                              //     textController: facebookController,
                              //     labelText: 'Enter Facebook',
                              //     prefixIcon: const Icon(
                              //       Icons.facebook,
                              //       color: kPrimaryColor,
                              //       size: 28,
                              //     ),
                              //   ),
                              // ),
                              // // if (isSocialDetailsVisible)
                              // //   const Padding(
                              // //     padding: EdgeInsets.only(right: 20, bottom: 50),
                              // //     child: Row(
                              // //       mainAxisAlignment: MainAxisAlignment.end,
                              // //       children: [
                              // //         Text(
                              // //           'Add more',
                              // //           style: TextStyle(
                              // //               color: kPrimaryColor
                              // //               fontWeight: FontWeight.w600,
                              // //               fontSize: 15),
                              // //         ),
                              // //         Icon(
                              // //           Icons.add,
                              // //           color: kPrimaryColor
                              // //           size: 18,
                              // //         )
                              // //       ],
                              // //     ),
                              // //   ),
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Website',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    // CustomSwitch(
                                    //   value: ref
                                    //       .watch(isWebsiteDetailsVisibleProvider),
                                    //   onChanged: (bool value) {
                                    //     setState(() {
                                    //       ref
                                    //           .read(isWebsiteDetailsVisibleProvider
                                    //               .notifier)
                                    //           .state = value;
                                    //     });
                                    //   },
                                    // ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap:
                                    true, // Let ListView take up only as much space as it needs
                                physics:
                                    const NeverScrollableScrollPhysics(), // Disable ListView's internal scrolling
                                itemCount: user.websites?.length,
                                itemBuilder: (context, index) {
                                  log('Websites count: ${user.websites?.length}');
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0), // Space between items
                                    child: customWebsiteVideoCard(
                                        onRemove: () => _removeWebsite(index),
                                        websiteVideo: user.websites?[index]),
                                  );
                                },
                              ),
                              // if (isWebsiteDetailsVisible)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 30),
                                child: customButton(
                                    label: 'Add',
                                    onPressed: () {
                                      showWebsiteSheet(
                                          addWebsite: _addNewWebsite,
                                          textController1:
                                              websiteNameController,
                                          textController2:
                                              websiteLinkController,
                                          fieldName: 'Add Website',
                                          title: 'Add Website Link',
                                          context: context);
                                    },
                                    sideColor: kPrimaryColor,
                                    labelColor: kPrimaryColor,
                                    buttonColor: Colors.transparent),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Add Video Link',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    // CustomSwitch(
                                    //   value:
                                    //       ref.watch(isVideoDetailsVisibleProvider),
                                    //   onChanged: (bool value) {
                                    //     setState(() {
                                    //       ref
                                    //           .read(isVideoDetailsVisibleProvider
                                    //               .notifier)
                                    //           .state = value;
                                    //     });
                                    //   },
                                    // ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap:
                                    true, // Let ListView take up only as much space as it needs
                                physics:
                                    const NeverScrollableScrollPhysics(), // Disable ListView's internal scrolling
                                itemCount: user.videos?.length,
                                itemBuilder: (context, index) {
                                  log('video count: ${user.videos?.length}');
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0), // Space between items
                                    child: customWebsiteVideoCard(
                                        onRemove: () => _removeVideo(index),
                                        websiteVideo: user.videos?[index]),
                                  );
                                },
                              ),
                              // if (isVideoDetailsVisible)
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 20, right: 20, bottom: 70),
                              //   child: Row(
                              //     children: [
                              //       Expanded(
                              //         // Ensures the CustomTextFormField takes the available space
                              //         child: CustomTextFormField(
                              //           // onTap: () {
                              //           //   // showVideoLinkSheet(
                              //           //   //     addVideo: _addNewVideo,
                              //           //   //     textController1: videoNameController,
                              //           //   //     textController2: videoLinkController,
                              //           //   //     fieldName: 'Add Youtube Link',
                              //           //   //     title: 'Add Video Link',
                              //           //   //     context: context);
                              //           // },
                              //           textController: videoLinkController,
                              //           readOnly: true,
                              //           labelText: 'Enter Video Link',
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 30),
                                child: customButton(
                                    label: 'Add',
                                    onPressed: () {
                                      showVideoLinkSheet(
                                          addVideo: _addNewVideo,
                                          textController1: videoNameController,
                                          textController2: videoLinkController,
                                          fieldName: 'Add Youtube Link',
                                          title: 'Add Video Link',
                                          context: context);
                                    },
                                    sideColor: kPrimaryColor,
                                    labelColor: kPrimaryColor,
                                    buttonColor: Colors.transparent),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 10, bottom: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Enter Awards',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    // CustomSwitch(
                                    //   value:
                                    //       ref.watch(isAwardsDetailsVisibleProvider),
                                    //   onChanged: (bool value) {
                                    //     ref
                                    //         .read(isAwardsDetailsVisibleProvider
                                    //             .notifier)
                                    //         .state = value;

                                    //     // if (value == false) {
                                    //     //   setState(
                                    //     //     () {
                                    //     //       awards = [];
                                    //     //     },
                                    //     //   );
                                    //     // }
                                    //   },
                                    // ),
                                  ],
                                ),
                              ),
                              // if (isAwardsDetailsVisible)
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(), // Disable internal scrolling
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, // Two items per row
                                    crossAxisSpacing:
                                        8.0, // Space between columns
                                    mainAxisSpacing: 10.0, // Space between rows
                                    childAspectRatio: 1.0, // Square-like items
                                  ),
                                  itemCount: user.awards!.length +
                                      1, // Add one for the "Add award" button
                                  itemBuilder: (context, index) {
                                    if (index < user.awards!.length) {
                                      // Regular award cards
                                      return AwardCard(
                                        award: user.awards![index],
                                        onRemove: () => _removeAward(index),
                                      );
                                    } else {
                                      // "Add award" button
                                      return GestureDetector(
                                        onTap: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          _openModalSheet(sheet: 'award');
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 10.0),
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: kGreyLight),
                                            color: kWhite,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                FontAwesomeIcons.plus,
                                                color: kPrimaryColor,
                                                size: 40,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'Add award',
                                                style: kBodyTitleM.copyWith(
                                                    color: kPrimaryColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 10, bottom: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Enter Certificates',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    // CustomSwitch(
                                    //   value: ref.watch(
                                    //       isCertificateDetailsVisibleProvider),
                                    //   onChanged: (bool value) {
                                    //     setState(() {
                                    //       ref
                                    //           .read(
                                    //               isCertificateDetailsVisibleProvider
                                    //                   .notifier)
                                    //           .state = value;
                                    //     });
                                    //   },
                                    // ),
                                  ],
                                ),
                              ),
                              if (user.certificates!.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap:
                                      true, // Let ListView take up only as much space as it needs
                                  physics:
                                      const NeverScrollableScrollPhysics(), // Disable ListView's internal scrolling
                                  itemCount: user.certificates!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0), // Space between items
                                      child: CertificateCard(
                                        certificate: user.certificates![index],
                                        onRemove: () =>
                                            _removeCertificate(index),
                                      ),
                                    );
                                  },
                                ),
                              // if (isCertificateDetailsVisible)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 25, right: 25, bottom: 60),
                                child: GestureDetector(
                                  onTap: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    _openModalSheet(
                                      sheet: 'certificate',
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25, right: 25, bottom: 60),
                                    child: Container(
                                      width: 170,
                                      height: 170,
                                      decoration: BoxDecoration(
                                          border: Border.all(color: kGreyLight),
                                          color: kWhite,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 40,
                                            ),
                                            const Icon(
                                              FontAwesomeIcons.plus,
                                              color: kPrimaryColor,
                                              size: 60,
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Text('Add certificate',
                                                style: kBodyTitleM.copyWith(
                                                    color: kPrimaryColor))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: SizedBox(
                              height: 50,
                              child: customButton(
                                  fontSize: 16,
                                  label: 'Save & Proceed',
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      SnackbarService snackbarService =
                                          SnackbarService();
                                      String response =
                                          await _submitData(user: user);
                                      ref
                                          .read(userProvider.notifier)
                                          .refreshUser();

                                      // Navigator.pushReplacement(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (BuildContext context) =>
                                      //             MainPage()
                                      //             ));
                                      if (response.contains('success')) {
                                        snackbarService.showSnackBar(response);
                                        ref.invalidate(
                                            fetchUserDetailsProvider);
                                        navigateBasedOnPreviousPage();
                                      } else {
                                        snackbarService.showSnackBar(response);
                                      }
                                    }
                                  }))),
                    ],
                  ),
                );
              },
            )),
      ),
    );
  }

  Widget _buildImagePickerOptions(BuildContext context, String imageType) {
    return Wrap(
      children: [
        ListTile(
          leading: const Icon(Icons.photo_library),
          title: const Text('Choose from Gallery'),
          onTap: () {
            navigationService.pop();
            _pickImage(ImageSource.gallery, imageType);
          },
        ),
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text('Take a Photo'),
          onTap: () {
            navigationService.pop();
            _pickImage(ImageSource.camera, imageType);
          },
        ),
      ],
    );
  }
}
