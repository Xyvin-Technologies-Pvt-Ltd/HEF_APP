import 'dart:developer';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hef/src/data/api_routes/analytics_api/analytics_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/analytics_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/notifiers/people_notifier.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/custom_widgets/custom_textFormField.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:shimmer/shimmer.dart';

class EditAnalyticRequestPage extends ConsumerStatefulWidget {
  final AnalyticsModel analytic;

  const EditAnalyticRequestPage({Key? key, required this.analytic})
      : super(key: key);

  @override
  _EditAnalyticRequestPageState createState() =>
      _EditAnalyticRequestPageState();
}

class _EditAnalyticRequestPageState
    extends ConsumerState<EditAnalyticRequestPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController referralNameController = TextEditingController();
  final TextEditingController referralEmailController = TextEditingController();
  final TextEditingController referralAddressController =
      TextEditingController();
  final TextEditingController referralInfoController = TextEditingController();
  final TextEditingController referralPhoneController = TextEditingController();
  final TextEditingController memberSearchController = TextEditingController();

  String? selectedRequestType;
  String? selectedMember;
  String? selectedMemberName;
  String? selectedMeetingType;
  bool? isReceived = false;
  bool _isSearchFieldFocused = false;
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _memberListScrollController = ScrollController();

  Timer? _debounce;

  final countryCodeProvider = StateProvider<String?>((ref) => '91');

  @override
  void initState() {
    super.initState();
    _populateFields();
    // Initialize people notifier
    ref.read(peopleNotifierProvider.notifier).fetchMoreUsers();
    memberSearchController.addListener(_onMemberSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _memberListScrollController.addListener(_onMemberListScroll);
  }

  void _onSearchFocusChanged() {
    setState(() {
      _isSearchFieldFocused = _searchFocusNode.hasFocus;
    });
  }

  void _onMemberSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref
          .read(peopleNotifierProvider.notifier)
          .searchUsers(memberSearchController.text);
    });
  }

  void _populateFields() {
    // Populate fields with existing data
    selectedRequestType = widget.analytic.type;
    titleController.text = widget.analytic.title ?? '';
    descriptionController.text = widget.analytic.description ?? '';

    // Pre-fill member field based on who is editing the request
    if (widget.analytic.user_id != null && widget.analytic.username != null) {
      // Check if the current user is the sender or receiver
      bool currentUserIsSender = widget.analytic.user_id == id;
      isReceived =
          !currentUserIsSender; // If current user is not the sender, then they are receiving

      if (currentUserIsSender) {
        // Current user is the sender - they are editing a request they sent
        // In this case, the selectedMember should be the recipient (we don't have this info in the model)
        // So we'll leave it empty and let them choose
        selectedMember = null;
        selectedMemberName = null;
        memberSearchController.clear();
      } else {
        // Current user is the receiver - they are editing a request they received
        // Pre-fill with the sender information
        selectedMember = widget.analytic.user_id;
        selectedMemberName = widget.analytic.username;
        memberSearchController.text = widget.analytic.username ?? '';
      }
    }

    if (widget.analytic.amount != null) {
      amountController.text = widget.analytic.amount.toString();
    }

    if (widget.analytic.date != null) {
      dateController.text =
          DateFormat('yyyy-MM-dd').format(widget.analytic.date!);
    }

    if (widget.analytic.time != null) {
      timeController.text = widget.analytic.time!;
    }

    if (widget.analytic.meetingLink != null) {
      linkController.text = widget.analytic.meetingLink!;
      selectedMeetingType = 'Online';
    }

    if (widget.analytic.location != null) {
      locationController.text = widget.analytic.location!;
      selectedMeetingType = 'Offline';
    }

    // Populate referral data if exists
    if (widget.analytic.referral != null) {
      referralNameController.text = widget.analytic.referral?.name ?? '';
      referralEmailController.text = widget.analytic.referral?.email ?? '';
      referralAddressController.text = widget.analytic.referral?.address ?? '';
      referralInfoController.text = widget.analytic.referral?.info ?? '';

      // Extract phone number without country code
      String? phone = widget.analytic.referral?.phone;
      if (phone != null && phone.isNotEmpty) {
        // Remove '+' and country code, keeping only the number
        String cleanPhone = phone.replaceAll('+', '');
        if (cleanPhone.length > 10) {
          referralPhoneController.text =
              cleanPhone.substring(cleanPhone.length - 10);
        } else {
          referralPhoneController.text = cleanPhone;
        }
      }
    }
  }

  Future<String?> updateAnalytic(String countryCode) async {
    final Map<String, dynamic> analytictData = {
      "type": selectedRequestType,
      "member": isReceived! ? id : selectedMember,
      "sender": isReceived! ? selectedMember : id,
      if (amountController.text != '')
        "amount": double.parse(amountController.text),
      "title": titleController.text,
      if (descriptionController.text != '')
        "description": descriptionController.text,
      if (selectedRequestType == 'Referral')
        "referral": {
          if (referralNameController.text != '')
            "name": referralNameController.text,
          if (referralEmailController.text != '')
            "email": referralEmailController.text,
          if (referralPhoneController.text != '')
            "phone": '+$countryCode${referralPhoneController.text}',
          if (referralAddressController.text != '')
            "address": referralAddressController.text,
          if (referralInfoController.text != '')
            "info": referralInfoController.text,
        },
      if (dateController.text != '') "date": dateController.text,
      if (timeController.text != '') "time": timeController.text,
      if (selectedMeetingType == 'Online' && linkController.text != '')
        "meetingLink": linkController.text,
      if (selectedMeetingType == 'Offline' && locationController.text != '')
        "location": locationController.text,
    };
    log(analytictData.toString(), name: "analytic to be updated:");
    AnalyticsApiService analyticsApiService = AnalyticsApiService();
    String? response = await analyticsApiService.updateAnalytic(
        analyticId: widget.analytic.id ?? '', data: analytictData);
    return response;
  }

  Widget _buildRequiredLabel(String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final countryCode = ref.watch(countryCodeProvider);
    final users = ref.watch(peopleNotifierProvider);
    final isLoading = ref.read(peopleNotifierProvider.notifier).isLoading;
    final isFirstLoad = ref.read(peopleNotifierProvider.notifier).isFirstLoad;

    // Sort users alphabetically by name (case-insensitive)
    final sortedUsers = users.where((user) => user.uid != id).toList()
      ..sort((a, b) {
        // Handle null/empty names by treating them as empty strings
        final nameA = (a.name ?? '').trim().toLowerCase();
        final nameB = (b.name ?? '').trim().toLowerCase();

        // If both names are empty, they are equal
        if (nameA.isEmpty && nameB.isEmpty) return 0;

        // Empty names should come last
        if (nameA.isEmpty) return 1;
        if (nameB.isEmpty) return -1;

        return nameA.compareTo(nameB);
      });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Edit Request",
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRequiredLabel('Request Type'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                hint: const Text('Choose Type'),
                value: selectedRequestType,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a request type';
                  }
                  return null;
                },
                items: ['Business', 'One v One Meeting', 'Referral']
                    .map((reqType) => DropdownMenuItem(
                          value: reqType,
                          child: Text(reqType),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRequestType = value;
                  });
                },
                decoration: InputDecoration(
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 212, 209, 209)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 223, 220, 220)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 212, 209, 209)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 223, 220, 220)),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
              const SizedBox(height: 10),

              // Direct Member Selection
              _buildRequiredLabel(isReceived! ? 'Sender' : 'Member'),
              const SizedBox(height: 10),

              // Search Field
              Focus(
                focusNode: _searchFocusNode,
                child: TextFormField(
                  controller: memberSearchController,
                  decoration: InputDecoration(
                    hintText: selectedMember != null
                        ? 'Tap to change member'
                        : 'Search Members',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    suffixIcon: selectedMember != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedMemberName ?? '',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    selectedMember = null;
                                    selectedMemberName = null;
                                    memberSearchController.clear();
                                  });
                                },
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Member List (Only show when search field is focused)
              if (_isSearchFieldFocused)
                if (isFirstLoad)
                  const Center(child: CircularProgressIndicator())
                else if (sortedUsers.isNotEmpty)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      controller: _memberListScrollController,
                      itemCount: sortedUsers.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == sortedUsers.length) {
                          return const Center(
                              child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ));
                        }

                        final user = sortedUsers[index];
                        final isSelected = selectedMember == user.uid;

                        return ListTile(
                          leading: SizedBox(
                            height: 40,
                            width: 40,
                            child: ClipOval(
                              child: user.image != null &&
                                      user.image!.isNotEmpty
                                  ? Image.network(
                                      user.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return SvgPicture.asset(
                                            'assets/svg/icons/dummy_person_small.svg');
                                      },
                                    )
                                  : SvgPicture.asset(
                                      'assets/svg/icons/dummy_person_small.svg'),
                            ),
                          ),
                          title: Text(
                            user.name ?? '',
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.blue : Colors.black,
                            ),
                          ),
                          subtitle: Text('${user.chapter?.name ?? ''}',
                              style: const TextStyle(color: Colors.grey)),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: Colors.blue)
                              : null,
                          onTap: () {
                            setState(() {
                              selectedMember = user.uid;
                              selectedMemberName = user.name;
                              memberSearchController.text = user.name ?? '';
                            });
                            // Clear focus to hide the list
                            _searchFocusNode.unfocus();
                          },
                        );
                      },
                    ),
                  )
                else
                  const Text('No members found')
              else
                const SizedBox.shrink(),

              const SizedBox(height: 16.0),

              _buildRequiredLabel('Title'),
              CustomTextFormField(
                textController: titleController,
                labelText: 'Eg - Construction related',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              if (selectedRequestType == 'Business' ||
                  selectedRequestType == 'Referral')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10.0),
                    if (selectedRequestType != 'Referral')
                      _buildRequiredLabel('Amount'),
                    if (selectedRequestType != 'Referral')
                      CustomTextFormField(
                        textInputType: const TextInputType.numberWithOptions(),
                        textController: amountController,
                        labelText: 'Eg - 50000',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          return null;
                        },
                      ),
                  ],
                ),

              if (selectedRequestType != 'Referral')
                const SizedBox(height: 10.0),

              Text(
                'Description',
                style: kSmallTitleB,
              ),
              CustomTextFormField(
                textController: descriptionController,
                labelText: 'Eg - Business closed for purchase of materials',
                maxLines: 4,
              ),

              const SizedBox(height: 10),

              if (selectedRequestType == 'Business') ...[
                _buildRequiredLabel('Date'),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 212, 209, 209)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 223, 220, 220)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 212, 209, 209)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 223, 220, 220)),
                    ),
                    labelText: 'Date',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            dateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20.0),

              if (selectedRequestType == 'One v One Meeting')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequiredLabel('Meeting Type'),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      hint: const Text('Choose Meeting Type'),
                      value: selectedMeetingType,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a meeting type';
                        }
                        return null;
                      },
                      items: ['Online', 'Offline']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMeetingType = value;
                          // Clear the fields when switching types
                          if (value == 'Online') {
                            locationController.clear();
                          } else {
                            linkController.clear();
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    _buildRequiredLabel('Date'),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 212, 209, 209)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 223, 220, 220)),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 212, 209, 209)),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 223, 220, 220)),
                        ),
                        labelText: 'Date',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2025),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dateController.text =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    _buildRequiredLabel('Time'),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: timeController,
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a time';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 212, 209, 209)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 223, 220, 220)),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 212, 209, 209)),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 223, 220, 220)),
                        ),
                        labelText: 'Time',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                timeController.text =
                                    pickedTime.format(context);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    if (selectedMeetingType == 'Online') ...[
                      const Text('Meeting Link',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10.0),
                      CustomTextFormField(
                          textController: linkController,
                          labelText: 'Meeting Link'),
                    ],
                    if (selectedMeetingType == 'Offline') ...[
                      const Text('Location',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10.0),
                      CustomTextFormField(
                          textController: locationController,
                          labelText: 'Location'),
                    ],
                  ],
                ),

              if (selectedRequestType == 'Referral')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    const Text('Referral Details',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10.0),
                    _buildRequiredLabel('Name'),
                    CustomTextFormField(
                      textController: referralNameController,
                      labelText: 'Enter referral name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter referral name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    const Text('Email',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    CustomTextFormField(
                      textController: referralEmailController,
                      labelText: 'Enter referral email',
                    ),
                    const SizedBox(height: 10.0),
                    _buildRequiredLabel('Phone'),
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
                            fontSize: 14, fontWeight: FontWeight.w400),
                        controller: referralPhoneController,
                        disableLengthCheck: true,
                        showCountryFlag: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: kWhite,
                          hintText: 'Enter referral phone number',
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: kGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: kGrey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: kGrey),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 10.0),
                        ),
                        onCountryChanged: (value) {
                          ref.read(countryCodeProvider.notifier).state =
                              value.dialCode;
                        },
                        initialCountryCode: 'IN',
                        onChanged: (PhoneNumber phone) {
                          print(phone.completeNumber);
                        },
                        flagsButtonPadding: const EdgeInsets.only(left: 10),
                        showDropdownIcon: true,
                        dropdownIconPosition: IconPosition.trailing,
                        dropdownTextStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text('Address',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    CustomTextFormField(
                      textController: referralAddressController,
                      labelText: 'Enter referral address',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10.0),
                    const Text('Additional Information',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    CustomTextFormField(
                      textController: referralInfoController,
                      labelText:
                          'I have a reference for you, Name, Number, purpose',
                      maxLines: 3,
                    ),
                  ],
                ),

              const SizedBox(height: 20.0),
              customButton(
                label: 'Update Request',
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      selectedMember != null) {
                    String? response =
                        await updateAnalytic(countryCode ?? '91');
                    if (response != null && response.contains('success')) {
                      Navigator.pop(context);
                    } else {
                      SnackbarService service = SnackbarService();
                      service.showSnackBar(response ?? 'Error');
                    }
                  } else if (selectedMember == null) {
                    SnackbarService service = SnackbarService();
                    service.showSnackBar('Please select a member');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onMemberListScroll() {
    if (_memberListScrollController.position.pixels >=
        _memberListScrollController.position.maxScrollExtent - 100) {
      // Load more users when scrolling near the bottom
      ref.read(peopleNotifierProvider.notifier).fetchMoreUsers();
    }
  }

  @override
  void dispose() {
    memberSearchController.removeListener(_onMemberSearchChanged);
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _memberListScrollController.removeListener(_onMemberListScroll);
    memberSearchController.dispose();
    _searchFocusNode.dispose();
    _memberListScrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
