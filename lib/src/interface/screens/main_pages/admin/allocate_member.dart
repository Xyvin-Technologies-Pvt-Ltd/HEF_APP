import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/api_routes/user_api/admin/admin_activities_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/admin/member_creation.dart';

class AllocateMember extends StatefulWidget {
  final UserModel newUser;
  const AllocateMember({super.key, required this.newUser});

  @override
  State<AllocateMember> createState() => _AllocateMemberState();
}

class _AllocateMemberState extends State<AllocateMember> {
  String? selectedStateId;
  String? selectedZone;
  String? selectedDistrict;
  String? selectedChapter;

  Future<void> _createUser() async {
    final Map<String, dynamic> profileData = {
      "name": widget.newUser.name,
      "bloodgroup": widget.newUser.bloodgroup,
      "chapter": selectedChapter,
      "image": widget.newUser.image,
      "email": widget.newUser.email,
      "phone": widget.newUser.phone!.startsWith('+91')
          ? widget.newUser.phone
          : '+91${widget.newUser.phone}',
      "bio": widget.newUser.bio,
      "status": widget.newUser.status,
      "address": widget.newUser.address,
      "businessCatogary": widget.newUser.businessCategory,
      "businessSubCatogary": widget.newUser.businessSubCategory,
      "company": [
        {
          "name": widget.newUser.company?[0].name ?? '',
          "designation": widget.newUser.company?[0].designation ?? '',
          "email": widget.newUser.company?[0].email ?? '',
          "websites": widget.newUser.company?[0].websites ?? '',
          "phone": widget.newUser.company?[0].phone ?? '',
        }
      ]
    };
    String response = await createUser(data: profileData);
    if (response.contains('success')) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();
    return Consumer(
      builder: (context, ref, child) {
        final asyncStates = ref.watch(fetchStatesProvider);
        final asyncZones =
            ref.watch(fetchLevelDataProvider(selectedStateId ?? '', 'state'));
        final asyncDistricts =
            ref.watch(fetchLevelDataProvider(selectedZone ?? '', 'zone'));
        final asyncChapters = ref
            .watch(fetchLevelDataProvider(selectedDistrict ?? '', 'district'));

        return Scaffold(
          appBar: AppBar(
            backgroundColor: kWhite,
            scrolledUnderElevation: 0,
            title: const Text(
              'Allocate member',
              style: kBodyTitleR,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => navigationService.pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // State Dropdown
                asyncStates.when(
                  data: (states) => SelectionDropDown(
                    value: selectedStateId, // Selected state ID
                    label: 'State',
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
                    value: selectedZone,
                    label: 'Zone',
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
                    value: selectedDistrict,
                    label: 'District',
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
                    value: selectedChapter,
                    label: 'Chapter',
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
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          _createUser();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SelectionDropDown extends StatefulWidget {
  final String? hintText;
  final String? label;
  final List<DropdownMenuItem<String>> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  const SelectionDropDown({
    this.label,
    required this.items,
    this.value,
    required this.onChanged,
    Key? key,
    this.hintText,
  }) : super(key: key);

  @override
  _SelectionDropDownState createState() => _SelectionDropDownState();
}

class _SelectionDropDownState extends State<SelectionDropDown>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Define fade animation
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Define slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null)
                Text(
                  widget.label ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                hint: Text(widget.hintText ?? ''),
                value: widget.value,
                items: widget.items,
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  fillColor: Colors.white,
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
        ),
      ),
    );
  }
}
