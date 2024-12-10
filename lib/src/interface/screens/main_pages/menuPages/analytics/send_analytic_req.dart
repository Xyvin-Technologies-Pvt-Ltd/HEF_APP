import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
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

  // Dropdown values
  String? selectedRequestType;
  String? selectedStateId;
  String? selectedZone;
  String? selectedDistrict;
  String? selectedChapter;
  String? selectedMember;

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

                items: ['Business', 'One v one meeting']
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
                data: (members) => SelectionDropDown(
                  hintText: 'Choose Member',
                  value: selectedMember,
                  label: null,
                  items: members.map((member) {
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
                ),
                loading: () => const Center(child: LoadingAnimation()),
                error: (error, stackTrace) => const SizedBox(),
              ),

              const SizedBox(height: 10.0),
              const Text('Title',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              CustomTextFormField(
                  textController: titleController, labelText: 'Title'),
              const SizedBox(height: 10.0),
              const Text('Description',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              CustomTextFormField(
                textController: descriptionController,
                labelText: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 10.0),
              const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        color: Color.fromARGB(
                            255, 212, 209, 209)), // Same as enabled border
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(
                            255, 223, 220, 220)), // Same as focused border
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
              const Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        color: Color.fromARGB(
                            255, 212, 209, 209)), // Same as enabled border
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(
                            255, 223, 220, 220)), // Same as focused border
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
                          timeController.text = pickedTime.format(context);
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
                  textController: linkController, labelText: 'Meeting Link'),
              const SizedBox(height: 10.0),
              const Text('Location',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10.0),
              CustomTextFormField(
                  textController: locationController, labelText: 'Loaction'),
              const SizedBox(height: 20.0),
              customButton(
                label: 'Send Request',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print('Form Submitted');
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
