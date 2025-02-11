import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/analytics_api/analytics_api.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/custom_widgets/custom_textFormField.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/admin/allocate_member.dart';
import 'package:intl/intl.dart';

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
  TextEditingController referralContactController = TextEditingController();

  // Dropdown values
  String? selectedRequestType;
  String? selectedStateId;
  String? selectedZone;
  String? selectedDistrict;
  String? selectedChapter;
  String? selectedMember;
  String? selectedRefferalStateId;
  String? selectedRefferalZone;
  String? selectedRefferalDistrict;
  String? selectedRefferalChapter;
  String? selectedRefferalMember;
  bool isChecked = false;
  bool isReferral = false;

  Future<void> createAnalytic() async {
    final Map<String, dynamic> analytictData = {
      "type": selectedRequestType,
      "member": selectedMember,
      "sender": id,
      "amount":amountController.text,
      "title": titleController.text,
      "description": descriptionController.text,
      if (selectedRefferalMember != null) "referral": selectedRefferalMember,
      if (referralContactController.text != '')
        "contact": referralContactController.text,
      if (amountController.text != '') "amount": amountController.text,
      if (dateController.text != '') "date": "2024-12-01",
      if (timeController.text != '') "time": "14:00",
      if (linkController.text != '')
        "meetingLink": linkController.text,
      if (locationController.text != '') "location": "Conference Room A"
    };
    await postAnalytic(data: analytictData);
  }

  void onChecked() {
    print('Checkbox is checked!');
    setState(() {
      isReferral = true;
    });
  }

  void onUnchecked() {
    setState(() {
      isReferral = false;
      selectedRefferalDistrict = null;
      selectedRefferalStateId = null;
      selectedRefferalChapter = null;
      selectedRefferalZone = null;
      selectedRefferalMember = null;
    });
    print('Checkbox is unchecked!');
  }

  @override
  Widget build(BuildContext context) {
    final asyncStates = ref.watch(fetchStatesProvider);
    final asyncZones =
        ref.watch(fetchLevelDataProvider(selectedStateId ?? '', 'state'));
    final asyncDistricts =
        ref.watch(fetchLevelDataProvider(selectedZone ?? '', 'zone'));
    final asyncChapters =
        ref.watch(fetchLevelDataProvider(selectedDistrict ?? '', 'district'));
    final asyncMembers =
        ref.watch(fetchLevelDataProvider(selectedChapter ?? '', 'user'));
    final asyncReferralZones = ref
        .watch(fetchLevelDataProvider(selectedRefferalStateId ?? '', 'state'));
    final asyncReferralDistricts =
        ref.watch(fetchLevelDataProvider(selectedRefferalZone ?? '', 'zone'));
    final asyncReferralChapters = ref.watch(
        fetchLevelDataProvider(selectedRefferalDistrict ?? '', 'district'));
    final asyncReferralMembers = ref
        .watch(fetchLevelDataProvider(selectedRefferalChapter ?? '', 'user'));
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
              const Text('Request Type',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SelectionDropDown(
                hintText: 'Choose Type',
                value: selectedRequestType, // Selected state ID

                items: ['Business', 'One v One Meeting']
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
              const Text('Member',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              asyncStates.when(
                data: (states) => SelectionDropDown(
                  hintText: 'Choose State',
                  value: selectedStateId, // Selected state ID
                  label: null,
                  items: states.map((state) {
                    return DropdownMenuItem<String>(
                      value: state.id, // Use state ID as the value
                      child: Text(state.name), // Display state name
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStateId = value; // Save the selected state ID
                      selectedZone = null; // Reset dependent dropdowns
                      selectedDistrict = null;
                      selectedChapter = null;
                    });
                  },
                ),
                loading: () => const Center(child: LoadingAnimation()),
                error: (error, stackTrace) => const SizedBox(),
              ),

              // Zone Dropdown
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
                }  ,
                loading: () => const Center(child: LoadingAnimation()),
                error: (error, stackTrace) => const SizedBox(),
              ),

              const SizedBox(height: 10.0),
              const Text('Title',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              CustomTextFormField(
                  textController: titleController, labelText: 'Title'),
              if (selectedRequestType == 'Business')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10.0),
                    const Text('Amount',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    CustomTextFormField(
                        textController: amountController, labelText: 'Amount'),
                  ],
                ),
              const SizedBox(height: 10.0),
              const Text('Description',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              CustomTextFormField(
                textController: descriptionController,
                labelText: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 10.0),
              if (selectedRequestType == 'One v One Meeting')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
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
                        labelText: 'Date',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
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
                    const Text('Time',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: timeController,
                      readOnly: true,
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
                              setState(() {
                                timeController.text =
                                    pickedTime.format(context);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text('Meeting Link',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10.0),
                    CustomTextFormField(
                        textController: linkController,
                        labelText: 'Meeting Link'),
                    const SizedBox(height: 10.0),
                    const Text('Location',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10.0),
                    CustomTextFormField(
                        textController: locationController,
                        labelText: 'Loaction'),
                  ],
                ),
              if (selectedRequestType == 'Business')
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            isChecked = value;
                            if (isChecked) {
                              onChecked();
                            } else {
                              onUnchecked();
                            }
                          });
                        }
                      },
                    ),
                    Text(
                      'Referral',
                      style: kBodyTitleR,
                    )
                  ],
                ),
              if (isChecked)
                Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Text('Referred Person',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    asyncStates.when(
                      data: (states) => SelectionDropDown(
                        hintText: 'Choose State',
                        value: selectedRefferalStateId, // Selected state ID
                        label: null,
                        items: states.map((state) {
                          return DropdownMenuItem<String>(
                            value: state.id, // Use state ID as the value
                            child: Text(state.name), // Display state name
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRefferalStateId =
                                value; // Save the selected state ID
                            selectedRefferalZone =
                                null; // Reset dependent dropdowns
                            selectedRefferalDistrict = null;
                            selectedRefferalChapter = null;
                          });
                        },
                      ),
                      loading: () => const Center(child: LoadingAnimation()),
                      error: (error, stackTrace) => const SizedBox(),
                    ),

                    // Zone Dropdown
                    asyncReferralZones.when(
                      data: (zones) => SelectionDropDown(
                        hintText: 'Choose Zone',
                        value: selectedRefferalZone,
                        label: null,
                        items: zones.map((zone) {
                          return DropdownMenuItem<String>(
                            value: zone.id,
                            child: Text(zone.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRefferalZone = value;
                            selectedRefferalDistrict = null;
                            selectedRefferalChapter = null;
                          });
                        },
                      ),
                      loading: () => const Center(child: LoadingAnimation()),
                      error: (error, stackTrace) => const SizedBox(),
                    ),

                    asyncReferralDistricts.when(
                      data: (districts) => SelectionDropDown(
                        hintText: 'Choose District',
                        value: selectedRefferalDistrict,
                        label: null,
                        items: districts.map((district) {
                          return DropdownMenuItem<String>(
                            value: district.id,
                            child: Text(district.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRefferalDistrict = value;
                            selectedRefferalChapter = null;
                          });
                        },
                      ),
                      loading: () => const Center(child: LoadingAnimation()),
                      error: (error, stackTrace) => const SizedBox(),
                    ),

                    asyncReferralChapters.when(
                      data: (chapters) => SelectionDropDown(
                        hintText: 'Choose Chapter',
                        value: selectedRefferalChapter,
                        label: null,
                        items: chapters.map((chapter) {
                          return DropdownMenuItem<String>(
                            value: chapter.id,
                            child: Text(chapter.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRefferalChapter = value;
                          });
                        },
                      ),
                      loading: () => const Center(child: LoadingAnimation()),
                      error: (error, stackTrace) => const SizedBox(),
                    ),
 asyncReferralMembers.when(
  data: (members) {
    // Create a new list excluding the member with the matching id
    final filteredMembers = members.where((member) => member.id != id).toList();

    return SelectionDropDown(
      hintText: 'Choose Member',
      value: selectedRefferalMember,
      label: null,
      items: filteredMembers.map((member) {
        return DropdownMenuItem<String>(
          value: member.id,
          child: Text(member.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedRefferalMember = value;
        });
      },
    );
  },
  loading: () => const Center(child: LoadingAnimation()),
  error: (error, stackTrace) => const SizedBox(),
),

                    const SizedBox(height: 10.0),
                  ],
                ),
              const SizedBox(height: 20.0),
              customButton(
                label: 'Send Request',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await createAnalytic();
                    Navigator.pop(context);
                    ref.invalidate(fetchAnalyticsProvider);
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
