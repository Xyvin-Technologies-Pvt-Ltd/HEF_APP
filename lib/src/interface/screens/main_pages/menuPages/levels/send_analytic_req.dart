import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/analytics_api/analytics_api.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/DropDown/selectionDropdown.dart';
import 'package:hef/src/interface/components/custom_widgets/custom_textFormField.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/admin/allocate_member.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class SendAnalyticRequestPage extends ConsumerStatefulWidget {
  @override
  _SendAnalyticRequestPageState createState() =>
      _SendAnalyticRequestPageState();
}

class _SendAnalyticRequestPageState
    extends ConsumerState<SendAnalyticRequestPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController referralName = TextEditingController();

  TextEditingController referralNameController = TextEditingController();
  TextEditingController referralEmailController = TextEditingController();

  TextEditingController referralAddressController = TextEditingController();
  TextEditingController referralInfoController = TextEditingController();
  TextEditingController referralPhoneController = TextEditingController();

  String? selectedRequestType;
  String? selectedStateId;
  String? selectedZone;
  String? selectedDistrict;
  String? selectedChapter;
  String? selectedMember;

  String? selectedMeetingType;

  Future<String?> createAnalytic(String countryCode) async {
    final Map<String, dynamic> analytictData = {
      "type": selectedRequestType,
      "member": selectedMember,
      "sender": id,
      if (amountController.text != '')
        "amount": int.parse(amountController.text),
      "title": titleController.text,
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
    log(analytictData.toString(), name: "analytic to be created:");
    String? response = await postAnalytic(data: analytictData);
    return response;
  }

  // void onChecked() {
  //   print('Checkbox is checked!');
  //   setState(() {
  //     isReferral = true;
  //   });
  // }

  // void onUnchecked() {
  //   setState(() {
  //     isReferral = false;
  //     selectedRefferalDistrict = null;
  //     selectedRefferalStateId = null;
  //     selectedRefferalChapter = null;
  //     selectedRefferalZone = null;
  //     selectedRefferalMember = null;
  //   });
  //   print('Checkbox is unchecked!');
  // }

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

  final countryCodeProvider = StateProvider<String?>((ref) => '91');

  @override
  Widget build(BuildContext context) {
    final countryCode = ref.watch(countryCodeProvider);
    final asyncStates = ref.watch(fetchStatesProvider);
    final asyncZones =
        ref.watch(fetchLevelDataProvider(selectedStateId ?? '', 'state'));
    final asyncDistricts =
        ref.watch(fetchLevelDataProvider(selectedZone ?? '', 'zone'));
    final asyncChapters =
        ref.watch(fetchLevelDataProvider(selectedDistrict ?? '', 'district'));
    final asyncMembers =
        ref.watch(fetchLevelDataProvider(selectedChapter ?? '', 'user'));
    // final asyncReferralZones = ref
    //     .watch(fetchLevelDataProvider(selectedRefferalStateId ?? '', 'state'));
    // final asyncReferralDistricts =
    //     ref.watch(fetchLevelDataProvider(selectedRefferalZone ?? '', 'zone'));
    // final asyncReferralChapters = ref.watch(
    //     fetchLevelDataProvider(selectedRefferalDistrict ?? '', 'district'));
    // final asyncReferralMembers = ref
    //     .watch(fetchLevelDataProvider(selectedRefferalChapter ?? '', 'user'));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Send Request",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
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
              SizedBox(
                height: 10,
              ),
              SelectionDropDown(
                hintText: 'Choose Type',
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
              ),
              const SizedBox(height: 16.0),
              _buildRequiredLabel('Member'),
              SizedBox(
                height: 10,
              ),
              asyncStates.when(
                data: (states) => SelectionDropDown(
                  hintText: 'Choose State',
                  value: selectedStateId,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a state';
                    }
                    return null;
                  },
                  label: null,
                  items: states.map((state) {
                    return DropdownMenuItem<String>(
                      value: state.id,
                      child: Text(state.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStateId = value;
                      selectedZone = null;
                      selectedDistrict = null;
                      selectedChapter = null;
                    });
                  },
                ),
                loading: () => const Center(child: LoadingAnimation()),
                error: (error, stackTrace) => const SizedBox(),
              ),
              asyncZones.when(
                data: (zones) => SelectionDropDown(
                  hintText: 'Choose Zone',
                  value: selectedZone,
                  label: null,
                  items: zones.map((zone) {
                    return DropdownMenuItem<String>(
                      value: zone.id,
                      child: Text(zone.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedZone = value;
                      selectedDistrict = null;
                      selectedChapter = null;
                    });
                  },
                ),
                loading: () => const Center(child: LoadingAnimation()),
                error: (error, stackTrace) => const SizedBox(),
              ),
              asyncDistricts.when(
                data: (districts) => SelectionDropDown(
                  hintText: 'Choose District',
                  value: selectedDistrict,
                  label: null,
                  items: districts.map((district) {
                    return DropdownMenuItem<String>(
                      value: district.id,
                      child: Text(district.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value;
                      selectedChapter = null;
                    });
                  },
                ),
                loading: () => const Center(child: LoadingAnimation()),
                error: (error, stackTrace) => const SizedBox(),
              ),
              asyncChapters.when(
                data: (chapters) => SelectionDropDown(
                  hintText: 'Choose Chapter',
                  value: selectedChapter,
                  label: null,
                  items: chapters.map((chapter) {
                    return DropdownMenuItem<String>(
                      value: chapter.id,
                      child: Text(chapter.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedChapter = value;
                    });
                  },
                ),
                loading: () => const Center(child: LoadingAnimation()),
                error: (error, stackTrace) => const SizedBox(),
              ),
              asyncMembers.when(
                data: (members) {
                  final filteredMembers =
                      members.where((member) => member.id != id).toList();
                  return SelectionDropDown(
                    hintText: 'Choose Member',
                    value: selectedMember,
                    label: null,
                    items: filteredMembers.map((member) {
                      return DropdownMenuItem<String>(
                        value: member.id,
                        child: Text(member.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMember = value;
                      });
                    },
                  );
                },
                loading: () => const Center(child: LoadingAnimation()),
                error: (error, stackTrace) => const SizedBox(),
              ),
              const SizedBox(height: 10.0),
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
                        textInputType: TextInputType.numberWithOptions(),
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
              SizedBox(
                height: 10,
              ),
              if (selectedRequestType == 'Business')
                _buildRequiredLabel('Date'),
              if (selectedRequestType == 'Business')
                const SizedBox(height: 10.0),
              if (selectedRequestType == 'Business')
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
                          color: Color.fromARGB(
                              255, 212, 209, 209)), // Unfocused border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(
                              255, 223, 220, 220)), // Focused border color
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
              const SizedBox(height: 20.0),
              if (selectedRequestType == 'One v One Meeting')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequiredLabel('Meeting Type'),
                    SizedBox(
                      height: 10,
                    ),
                    SelectionDropDown(
                      hintText: 'Choose Meeting Type',
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
                              color: Color.fromARGB(255, 212, 209,
                                  209)), // Unfocused border color
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(
                                  255, 223, 220, 220)), // Focused border color
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
                              color: Color.fromARGB(255, 212, 209,
                                  209)), // Unfocused border color
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(
                                  255, 223, 220, 220)), // Focused border color
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 212, 209,
                                  209)), // Same as enabled border
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 223, 220,
                                  220)), // Same as focused border
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
                                final localizations =
                                    MaterialLocalizations.of(context);
                                final formattedTime =
                                    localizations.formatTimeOfDay(pickedTime,
                                        alwaysUse24HourFormat: false);

                                setState(() {
                                  timeController.text =
                                      formattedTime; // This will show time in "hh:mm AM/PM" format
                                });
                              }
                            }),
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
                      width: double.infinity, // Full width container
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
                        controller: referralPhoneController,
                        disableLengthCheck: true,
                        showCountryFlag: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: kWhite,
                          hintText: 'Enter referral phone number',
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
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
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
                      labelText: 'I have a reference for you, Name, Number, purpose',
                      maxLines: 3,
                    ),
                  ],
                ),
              const SizedBox(height: 20.0),
              customButton(
                label: 'Send Request',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String? response =
                        await createAnalytic(countryCode ?? '91');
                    if (response != null && response.contains('success')) {
                      Navigator.pop(context);
                      ref.invalidate(fetchAnalyticsProvider);
                    } else {
                      SnackbarService service = SnackbarService();

                      service.showSnackBar(response ?? 'Error');
                    }
                    print('Form Submitted');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
