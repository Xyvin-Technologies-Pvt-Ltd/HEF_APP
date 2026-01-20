import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/models/business_category_model.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/notifiers/business_category_notifier.dart';
import 'package:hef/src/data/services/image_upload.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/custom_widgets/member_creation_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class MemberCreationPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<MemberCreationPage> createState() => _MemberCreationPageState();
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

class _MemberCreationPageState extends ConsumerState<MemberCreationPage> {
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
  // Business category dropdown state - now supports multiple selections
  List<BusinessCategoryModel> selectedBusinessCategories = [];
  bool _isSearchExpanded = false;
  final TextEditingController _categorySearchController =
      TextEditingController();
  TextEditingController generaldesignationController = TextEditingController();
  String? selectedStatus;
  File? _profileImage;

  // Business tags functionality
  final TextEditingController _tagController = TextEditingController();
  List<String> businessTags = [];
  String? businessTagSearch;

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
    _tagController.dispose();

    // Dispose company controllers
    for (var company in companies) {
      company.dispose();
    }

    super.dispose();
  }

  void _addBusinessTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty) {
      // Check if tag already exists (case-insensitive comparison)
      if (!businessTags.any(
          (existingTag) => existingTag.toLowerCase() == tag.toLowerCase())) {
        setState(() {
          businessTags.add(tag);
          _tagController.clear();
          businessTagSearch = null; // Clear search when tag is added
        });
      } else {
        // Show snackbar or some indication that tag already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tag "$tag" already exists'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
        _tagController.clear();
      }
    }
  }

  void _removeBusinessTag(String tag) {
    setState(() {
      businessTags.remove(tag);
    });
  }

  // Get filtered tags using the same provider as editUser.dart
  List<String> _getFilteredTags(List<String>? allTags) {
    if (businessTagSearch?.isEmpty ?? true) {
      return [];
    }

    if (allTags == null) {
      return [];
    }

    return allTags
        .where((tag) =>
            tag.toLowerCase().contains(businessTagSearch!.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();

    // Watch business tags provider (same as editUser.dart)
    final asyncBusinessTags = ref.watch(
      searchBusinessTagsProvider(search: businessTagSearch),
    );
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
              // Business Tags Section
              _buildBusinessTagsSection(asyncBusinessTags),
              // Companies Section
              _buildCompaniesSection(),

              // Business Category Dropdown (New)
              _buildBusinessCategoryDropdown(),

              // MemberCreationTextfield(
              //   textEditingController: businessCategoryController,
              //   label: 'Business Category *',
              //   hintText: 'Enter business category',
              //   validator: (value) =>
              //       value!.isEmpty ? 'Business category is required' : null,
              // ),
              // MemberCreationTextfield(
              //   textEditingController: businessSubCategoryController,
              //   label: 'Sub Category *',
              //   hintText: 'Enter sub category',
              //   validator: (value) =>
              //       value!.isEmpty ? 'Sub category is required' : null,
              // ),

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
                                  // Send category as array (backend expects array of strings)
                                  category: selectedBusinessCategories
                                      .map((cat) => cat.id)
                                      .toList(),
                                  businessCategory:
                                      businessCategoryController.text,
                                  businessSubCategory:
                                      businessSubCategoryController.text,
                                  businessTags: businessTags.isNotEmpty
                                      ? businessTags
                                      : null,
                                  status: selectedStatus,
                                  designation:
                                      generaldesignationController.text,
                                  dateOfJoining: dateOfJoining));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please fill all required fields (Name, Bio, Email, Phone, at least one Company with name, designation, and email,Status)'),
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

  Widget _buildBusinessTagsSection(AsyncValue<List<String>> asyncBusinessTags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Tags',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: 'Add business tags (e.g., IT, Healthcare)',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    onSubmitted: (_) => _addBusinessTag(),
                    onChanged: (value) {
                      if (value.endsWith(' ')) {
                        final tag = value.trim();
                        if (tag.isNotEmpty) {
                          _addBusinessTag();
                        }
                      } else {
                        setState(() {
                          businessTagSearch = value;
                        });
                      }
                    },
                  ),
                  if (businessTagSearch?.isNotEmpty ?? false)
                    asyncBusinessTags.when(
                      data: (businessTags) {
                        final filteredTags = _getFilteredTags(businessTags);
                        if (filteredTags.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          margin: const EdgeInsets.only(top: 4),
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: filteredTags.length,
                              itemBuilder: (context, index) {
                                final tag = filteredTags[index];
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      _tagController.text = tag;
                                      _addBusinessTag();
                                      setState(() {
                                        businessTagSearch = null;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.tag,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            tag,
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addBusinessTag,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...businessTags.map((tag) {
              return Chip(
                label: Text(
                  tag,
                  style: const TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeBusinessTag(tag),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            }).toList(),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBusinessCategoryDropdown() {
    final businessCategories = ref.watch(businessCategoryNotifierProvider);
    final notifier = ref.read(businessCategoryNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Categories (Select Multiple)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        // Display selected categories as chips
        if (selectedBusinessCategories.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedBusinessCategories.map((cat) {
              return Chip(
                label: Text(
                  cat.name,
                  style: const TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    selectedBusinessCategories.remove(cat);
                  });
                },
                backgroundColor: kPrimaryColor.withOpacity(0.1),
                side: BorderSide(color: kPrimaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        // Expandable Search Section
        GestureDetector(
          onTap: () {
            setState(() {
              _isSearchExpanded = !_isSearchExpanded;
              if (_isSearchExpanded) {
                _categorySearchController.clear();
              }
            });
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isSearchExpanded ? kPrimaryColor : kGrey,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedBusinessCategories.isEmpty
                        ? 'Select business categories'
                        : '${selectedBusinessCategories.length} category(ies) selected',
                    style: TextStyle(
                      color: selectedBusinessCategories.isEmpty
                          ? Colors.grey.shade600
                          : Colors.black87,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isSearchExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
        // Search field and filtered list
        if (_isSearchExpanded) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: kPrimaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                TextFormField(
                  controller: _categorySearchController,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search business category...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    if (value.isEmpty) {
                      notifier.refreshCategories();
                    } else {
                      notifier.searchCategories(value);
                    }
                  },
                ),
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Filtered categories based on search
                        ...businessCategories.where((cat) {
                          final searchTerm =
                              _categorySearchController.text.toLowerCase();
                          return searchTerm.isEmpty ||
                              cat.name.toLowerCase().contains(searchTerm);
                        }).map((cat) {
                          final isSelected = selectedBusinessCategories
                              .any((selected) => selected.id == cat.id);
                          return ListTile(
                            dense: true,
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    // Add category if not already selected
                                    if (!selectedBusinessCategories.any(
                                        (selected) => selected.id == cat.id)) {
                                      selectedBusinessCategories.add(cat);
                                    }
                                  } else {
                                    // Remove category
                                    selectedBusinessCategories.removeWhere(
                                        (selected) => selected.id == cat.id);
                                  }
                                });
                              },
                            ),
                            title: Text(
                              cat.name,
                              style: TextStyle(
                                color:
                                    isSelected ? kPrimaryColor : Colors.black87,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: cat.companyCount != null &&
                                    cat.companyCount! > 0
                                ? Text(
                                    '${cat.companyCount} companies',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedBusinessCategories.removeWhere(
                                      (selected) => selected.id == cat.id);
                                } else {
                                  selectedBusinessCategories.add(cat);
                                }
                              });
                            },
                          );
                        }),
                        // Load more option
                        if (notifier.hasMore || notifier.isLoading)
                          ListTile(
                            dense: true,
                            leading: notifier.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Icon(Icons.more_horiz,
                                    color: Colors.grey.shade600),
                            title: Text(
                              notifier.isLoading
                                  ? 'Loading...'
                                  : 'Load more...',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            onTap: notifier.isLoading
                                ? null
                                : () {
                                    notifier.fetchMoreCategories();
                                  },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
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
