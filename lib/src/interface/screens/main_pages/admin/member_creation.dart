import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/services/image_upload.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/custom_widgets/member_creation_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:path/path.dart' as Path;

class MemberCreationPage extends StatefulWidget {
  @override
  State<MemberCreationPage> createState() => _MemberCreationPageState();
}

class _MemberCreationPageState extends State<MemberCreationPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController phoneCountryController = TextEditingController();
  TextEditingController bloodController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController adressController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController companyPhoneController = TextEditingController();
  TextEditingController companyPhoneCountryController = TextEditingController();
  TextEditingController companyDesignationController = TextEditingController();
  TextEditingController companyEmailController = TextEditingController();
  TextEditingController companyWebsiteController = TextEditingController();
  String? selectedStatus;
  String? selectedBusinessCategory;
  String? selectedSubCategory;
  File? _profileImage;

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              MemberCreationTextfield(
                textEditingController: nameController,
                label: 'Full Name',
                hintText: 'Enter full name',
                validator: (value) =>
                    value!.isEmpty ? 'This field is required' : null,
              ),
              MemberCreationTextfield(
                textEditingController: bloodController,
                label: 'Blood Group',
                hintText: 'Blood Group',
                validator: (value) => null,
              ),
              UploadPhotoWidget(
                onPhotoChanged: (File? photo) {
                  setState(() {
                    _profileImage = photo;
                  });
                },
              ),
              MemberCreationTextfield(
                textEditingController: bioController,
                label: 'Bio',
                hintText: 'Add description',
                maxLines: 5,
                validator: (value) => null,
              ),
              MemberCreationTextfield(
                textEditingController: emailController,
                label: 'Email ID',
                hintText: 'Email ID',
                validator: (value) => null,
              ),
              Container(
                width: double.infinity,
                child: IntlPhoneField(
                  validator: (phone) {
                    if (phone == null || phone.number.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    if (phone.number.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  controller: phoneController,
                  disableLengthCheck: true,
                  showCountryFlag: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: kWhite,
                    hintText: 'Enter phone number',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: kGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: kGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: kGrey),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 10.0,
                    ),
                  ),
                  onCountryChanged: (value) {
                    phoneCountryController.text = value.dialCode;
                  },
                  initialCountryCode: 'IN',
                  onChanged: (PhoneNumber phone) {
                    print(phone.completeNumber);
                  },
                  flagsButtonPadding: const EdgeInsets.only(left: 10),
                  showDropdownIcon: true,
                  dropdownIconPosition: IconPosition.trailing,
                  dropdownTextStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              MemberCreationTextfield(
                textEditingController: adressController,
                label: 'Personal Address',
                hintText: 'Personal Address',
                validator: (value) => null,
              ),
              MemberCreationTextfield(
                label: 'Company Name',
                hintText: 'Name',
                textEditingController: companyNameController,
                validator: (value) => null,
              ),
              Container(
                width: double.infinity,
                child: IntlPhoneField(
                  validator: (phone) => null,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  controller: companyPhoneController,
                  disableLengthCheck: true,
                  showCountryFlag: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: kWhite,
                    hintText: 'Enter company phone number',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: kGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: kGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: kGrey),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 10.0,
                    ),
                  ),
                  onCountryChanged: (value) {
                    companyPhoneCountryController.text = value.dialCode;
                  },
                  initialCountryCode: 'IN',
                  onChanged: (PhoneNumber phone) {
                    print(phone.completeNumber);
                  },
                  flagsButtonPadding: const EdgeInsets.only(left: 10),
                  showDropdownIcon: true,
                  dropdownIconPosition: IconPosition.trailing,
                  dropdownTextStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MemberCreationTextfield(
                textEditingController: companyDesignationController,
                label: 'Designation',
                hintText: 'Designation',
                validator: (value) => null,
              ),
              MemberCreationTextfield(
                label: 'Company Email',
                hintText: 'email',
                textEditingController: companyEmailController,
                validator: (value) => null,
              ),
              MemberCreationTextfield(
                label: 'Website',
                hintText: 'Link',
                textEditingController: companyWebsiteController,
                validator: (value) => null,
              ),
              CustomDropdown(
                label: 'Business Category',
                items: ['IT', 'Finance', 'Education'],
                value: selectedBusinessCategory,
                onChanged: (value) {
                  setState(() {
                    selectedBusinessCategory = value;
                  });
                },
              ),
              CustomDropdown(
                label: 'Sub category',
                items: ['Software', 'Hardware'],
                value: selectedSubCategory,
                onChanged: (value) {
                  setState(() {
                    selectedSubCategory = value;
                  });
                },
              ),
              CustomDropdown(
                label: 'Status',
                items: ['active', 'inactive', 'suspended'],
                value: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
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
                  const SizedBox(width: 30),
                  Flexible(
                    child: customButton(
                      label: 'Save',
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            selectedStatus != null) {
                          String profileImageUrl = _profileImage != null
                              ? await imageUpload(_profileImage!.path)
                              : '';
                          navigationService.pushNamed('MemberAllocation',
                              arguments: UserModel(
                                  name: nameController.text,
                                  bloodgroup: bloodController.text,
                                  image: profileImageUrl,
                                  bio: bioController.text,
                                  email: emailController.text,
                                  phone:
                                      '${phoneCountryController.text}${phoneController.text}',
                                  address: adressController.text,
                                  company: [
                                    Company(
                                        name: companyNameController.text,
                                        designation:
                                            companyDesignationController.text,
                                        email: companyEmailController.text,
                                        phone:
                                            '+${companyPhoneCountryController.text}${companyPhoneController.text}',
                                        websites:
                                            companyWebsiteController.text),
                                  ],
                                  businessCategory: selectedBusinessCategory,
                                  businessSubCategory: selectedSubCategory,
                                  status: selectedStatus));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please fill all required fields (Name, Phone, Status)'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    required this.label,
    this.items = const ['Option 1', 'Option 2', 'Option 3'],
    this.value,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              fillColor: kWhite,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kGreyLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kGreyLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kGreyLight),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
            iconSize: 16,
          ),
        ],
      ),
    );
  }
}

class UploadPhotoWidget extends StatefulWidget {
  final Function(File?) onPhotoChanged;

  const UploadPhotoWidget({Key? key, required this.onPhotoChanged})
      : super(key: key);

  @override
  State<UploadPhotoWidget> createState() => _UploadPhotoWidgetState();
}

class _UploadPhotoWidgetState extends State<UploadPhotoWidget> {
  File? _profileImage;

  Future<void> _pickFile() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      widget.onPhotoChanged(_profileImage); // Notify the parent
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Photo', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kGreyLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_profileImage != null)
                  Text(
                    'Photo Added',
                    style: kBodyTitleB.copyWith(color: kPrimaryColor),
                  ),
                if (_profileImage == null)
                  Text(
                    'Upload photo',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                InkWell(
                  onTap: () async {
                    if (_profileImage == null) {
                      await _pickFile();
                    } else {
                      setState(() {
                        _profileImage = null;
                      });
                      widget.onPhotoChanged(null); // Notify the parent
                    }
                  },
                  child: Icon(
                    _profileImage == null
                        ? Icons.cloud_upload_outlined
                        : Icons.close,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
