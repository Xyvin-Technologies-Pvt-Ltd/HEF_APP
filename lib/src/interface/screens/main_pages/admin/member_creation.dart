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

class CompanyFormData {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController phoneCountryController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController websiteController = TextEditingController();

  String get phoneCountryCode => phoneCountryController.text;

  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    phoneCountryController.dispose();
    designationController.dispose();
    emailController.dispose();
    websiteController.dispose();
  }
}

class _MemberCreationPageState extends State<MemberCreationPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController phoneCountryController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  TextEditingController whatsappCountryController = TextEditingController();
  TextEditingController secondaryPhoneController = TextEditingController();
  TextEditingController secondaryPhoneCountryController =
      TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController adressController = TextEditingController();
  TextEditingController businessCategoryController = TextEditingController();
  TextEditingController businessSubCategoryController = TextEditingController();
  TextEditingController generaldesignationController = TextEditingController();
  String? selectedStatus;
  File? _profileImage;

  // Multiple companies support
  List<CompanyFormData> companies = [CompanyFormData()];

  @override
  void dispose() {
    // Dispose all controllers
    nameController.dispose();
    phoneController.dispose();
    phoneCountryController.dispose();
    whatsappController.dispose();
    whatsappCountryController.dispose();
    secondaryPhoneController.dispose();
    secondaryPhoneCountryController.dispose();
    bioController.dispose();
    emailController.dispose();
    adressController.dispose();
    businessCategoryController.dispose();
    businessSubCategoryController.dispose();

    // Dispose company controllers
    for (var company in companies) {
      company.dispose();
    }

    super.dispose();
  }

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
                label: 'Full Name *',
                hintText: 'Enter full name',
                validator: (value) =>
                    value!.isEmpty ? 'This field is required' : null,
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
                label: 'Bio *',
                hintText: 'Add description',
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Bio is required' : null,
              ),
              MemberCreationTextfield(
                textEditingController: emailController,
                label: 'Email ID *',
                hintText: 'Email ID',
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                      .hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              Text('Phone *',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(
                height: 5,
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
              Text('WhatsApp Number',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                child: IntlPhoneField(
                  validator: (phone) {
                    if (phone != null && phone.number.isNotEmpty) {
                      if (phone.number.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                    }
                    return null;
                  },
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  controller: whatsappController,
                  disableLengthCheck: true,
                  showCountryFlag: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: kWhite,
                    hintText: 'Enter WhatsApp number',
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
                    whatsappCountryController.text = value.dialCode;
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
              Text('Secondary Phone Number',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                child: IntlPhoneField(
                  validator: (phone) {
                    if (phone != null && phone.number.isNotEmpty) {
                      if (phone.number.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                    }
                    return null;
                  },
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  controller: secondaryPhoneController,
                  disableLengthCheck: true,
                  showCountryFlag: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: kWhite,
                    hintText: 'Enter secondary phone number',
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
                    secondaryPhoneCountryController.text = value.dialCode;
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
                label: 'Personal Address ',
                hintText: 'Personal Address',
                validator: (value) => null,
              ),
              // Companies Section
              _buildCompaniesSection(),
              MemberCreationTextfield(
                textEditingController: businessCategoryController,
                label: 'Business Category *',
                hintText: 'Enter business category',
                validator: (value) =>
                    value!.isEmpty ? 'Business category is required' : null,
              ),
              MemberCreationTextfield(
                textEditingController: businessSubCategoryController,
                label: 'Sub Category *',
                hintText: 'Enter sub category',
                validator: (value) =>
                    value!.isEmpty ? 'Sub category is required' : null,
              ),

              MemberCreationTextfield(
                textEditingController: generaldesignationController,
                label: 'Designation *',
                hintText: 'Enter Designation',
                validator: (value) =>
                    value!.isEmpty ? 'This field is required' : null,
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
                            selectedStatus != null &&
                            _validateCompanies()) {
                          String profileImageUrl = _profileImage != null
                              ? await imageUpload(_profileImage!.path)
                              : '';

                          // Set joining date to current time
                          DateTime dateOfJoining = DateTime.now();

                          print('=== USER MODEL CREATION ===');
                          print('Member Name: ${nameController.text}');
                          print(
                              'Joining Date: ${dateOfJoining.toIso8601String()}');
                          print('===========================');

                          navigationService.pushNamed('MemberAllocation',
                              arguments: UserModel(
                                  name: nameController.text,
                                  image: profileImageUrl,
                                  bio: bioController.text,
                                  email: emailController.text,
                                  phone:
                                      '${phoneCountryController.text}${phoneController.text}',
                                  secondaryPhone: SecondaryPhone(
                                      whatsapp: whatsappController
                                              .text.isNotEmpty
                                          ? '${whatsappCountryController.text}${whatsappController.text}'
                                          : null,
                                      business: secondaryPhoneController
                                              .text.isNotEmpty
                                          ? '${secondaryPhoneCountryController.text}${secondaryPhoneController.text}'
                                          : null),
                                  address: adressController.text,
                                  company: companies
                                      .where((c) =>
                                          c.nameController.text.isNotEmpty)
                                      .map((c) => Company(
                                            name: c.nameController.text,
                                            designation:
                                                c.designationController.text,
                                            email: c.emailController.text,
                                            phone: c.phoneController.text
                                                    .isNotEmpty
                                                ? '+${c.phoneCountryCode}${c.phoneController.text}'
                                                : null,
                                            websites: c.websiteController.text,
                                          ))
                                      .toList(),
                                  businessCategory:
                                      businessCategoryController.text,
                                  businessSubCategory:
                                      businessSubCategoryController.text,
                                  status: selectedStatus,
                                  designation: generaldesignationController.text,
                                  dateOfJoining: dateOfJoining));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please fill all required fields (Name, Bio, Email, Phone, at least one Company with name, designation, and email, Business Category, Sub Category, Status)'),
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

  Widget _buildCompaniesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Companies *',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  companies.add(CompanyFormData());
                });
              },
              icon: const Icon(Icons.add_circle, color: kPrimaryColor),
              tooltip: 'Add Company',
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...companies.asMap().entries.map((entry) {
          int index = entry.key;
          CompanyFormData company = entry.value;
          return _buildCompanyCard(company, index);
        }).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCompanyCard(CompanyFormData company, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Company ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (companies.length > 1)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        companies.removeAt(index);
                      });
                    },
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                    tooltip: 'Remove Company',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            MemberCreationTextfield(
              textEditingController: company.nameController,
              label: 'Company Name *',
              hintText: 'Enter company name',
              validator: (value) =>
                  value!.isEmpty ? 'Company name is required' : null,
            ),
            const SizedBox(height: 12),
            MemberCreationTextfield(
              textEditingController: company.designationController,
              label: 'Designation *',
              hintText: 'Your role/designation',
              validator: (value) =>
                  value!.isEmpty ? 'Designation is required' : null,
            ),
            const SizedBox(height: 12),
            MemberCreationTextfield(
              textEditingController: company.emailController,
              label: 'Company Email *',
              hintText: 'company@email.com',
              validator: (value) {
                if (value!.isEmpty) return 'Company email is required';
                if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                    .hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Company Phone',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Container(
              width: double.infinity,
              child: IntlPhoneField(
                validator: (phone) {
                  if (phone != null && phone.number.isNotEmpty) {
                    if (phone.number.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                  }
                  return null;
                },
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                controller: company.phoneController,
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
                  company.phoneCountryController.text = value.dialCode;
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
            const SizedBox(height: 12),
            MemberCreationTextfield(
              textEditingController: company.websiteController,
              label: 'Website',
              hintText: 'https://company.com',
              validator: (value) => null, // Website is optional
            ),
          ],
        ),
      ),
    );
  }

  bool _validateCompanies() {
    // Check if at least one company has a name
    return companies.any((company) => company.nameController.text.isNotEmpty);
  }

  String? _validateCompaniesRequired() {
    if (!_validateCompanies()) {
      return 'At least one company is required';
    }
    return null;
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
