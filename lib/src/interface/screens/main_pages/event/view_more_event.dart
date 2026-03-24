import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/events_api/events_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/events_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/data/services/launch_url.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:hef/src/interface/screens/main_pages/event/qr_scanner_page.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../components/Buttons/primary_button.dart';

class ViewMoreEventPage extends ConsumerStatefulWidget {
  final Event event;
  const ViewMoreEventPage({super.key, required this.event});

  @override
  ConsumerState<ViewMoreEventPage> createState() => _ViewMoreEventPageState();
}

class _ViewMoreEventPageState extends ConsumerState<ViewMoreEventPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  bool registered = false;
  bool isRegistering = false;

  /// Check if current user is registered (same strategy as ipaconnect).
  /// HEF backend stores registrations in both rsvp (legacy) and rsvpnew.
  bool _isUserRegistered() {
    if (id.isEmpty) return false;
    final inRsvp = widget.event.rsvp?.contains(id) ?? false;
    final inRsvpnew = widget.event.rsvpnew!.contains(id);
    return inRsvp || inRsvpnew;
  }

  /// Total registered count from both rsvp and rsvpnew.
  int get _registeredCount =>
      (widget.event.rsvp?.length ?? 0) + widget.event.rsvpnew!.length;

  @override
  void initState() {
    super.initState();
    registered = _isUserRegistered();
  }

  String _getRegistrationButtonLabel() {
    if (widget.event.status?.toLowerCase() == 'cancelled') return 'CANCELLED';
    if (registered) return 'REGISTERED';

    final int limit = widget.event.limit ?? 0;
    final int count = _registeredCount;

    if (limit > 0) {
      final spotsLeft = limit - count;
      if (spotsLeft <= 0) return 'REGISTRATION FULL';

      // More user-friendly messages for remaining spots
      if (spotsLeft == 1) {
        return 'REGISTER (Last seat!)';
      } else if (spotsLeft <= 5) {
        return 'REGISTER (Only $spotsLeft seats left!)';
      }
      return 'REGISTER ($spotsLeft seats left)';
    }

    return 'REGISTER EVENT';
  }

  bool _canRegister() {
    if (registered || widget.event.status?.toLowerCase() == 'cancelled')
      return false;

    final int limit = widget.event.limit ?? 0;
    if (limit == 0) return true; // No limit set

    return _registeredCount < limit;
  }

  String _getRegistrationCountText() {
    final count = _registeredCount;
    final limit = widget.event.limit!;
    final remaining = limit - count;

    if (remaining == 0) {
      return 'All seats taken ($count/$limit)';
    } else if (remaining == 1) {
      return 'Last seat remaining ($count/$limit)';
    } else if (remaining <= 10) {
      return 'Only $remaining seats left ($count/$limit)';
    }
    return '$count/$limit registered';
  }

  void showAddGuestSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add Guest',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: _nameController,

                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.person),
                          hintText: 'Enter name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 216, 211, 211),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 216, 211, 211),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 216, 211, 211),
                            ),
                          ),
                        ),
                        // Trigger search on submit
                      )),

                  Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: _categoryController,

                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.category),
                          hintText: 'Enter category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 216, 211, 211),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 216, 211, 211),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 216, 211, 211),
                            ),
                          ),
                        ),
                        // Trigger search on submit
                      )),

                  Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: _numberController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.phone),
                          hintText: 'Enter number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 216, 211, 211),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 216, 211, 211),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 216, 211, 211),
                            ),
                          ),
                        ),
                      )),

                  SizedBox(
                    height: 16,
                  ),
                  customButton(
                      label: 'ADD GUEST',
                      onPressed: () async {
                        final guestName = _nameController.text.trim();
                        final category = _categoryController.text.trim();
                        final phone = _numberController.text.trim();
                        Navigator.pop(context);

                        // Validation for name field
                        if (guestName.isEmpty) {
                          SnackbarService()
                              .showSnackBar("Guest name is required!");
                          return;
                        }
                        if (guestName.length < 2) {
                          SnackbarService().showSnackBar(
                              "Guest name must be at least 2 characters long!");
                          return;
                        }

                        // Validation for category field
                        if (category.isEmpty) {
                          SnackbarService()
                              .showSnackBar("Category is required!");
                          return;
                        }
                        if (category.length < 2) {
                          SnackbarService().showSnackBar(
                              "Category must be at least 2 characters long!");
                          return;
                        }

                        // Validation for phone field
                        if (phone.isEmpty) {
                          SnackbarService()
                              .showSnackBar("Phone number is required!");
                          return;
                        }
                        if (phone.length < 10) {
                          SnackbarService().showSnackBar(
                              "Phone number must be at least 10 digits!");
                          return;
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
                          SnackbarService().showSnackBar(
                              "Phone number must contain only digits!");
                          return;
                        }

                        try {
                          await EventApiService.addGuestToEvent(
                            eventId: widget.event.id!,
                            name: guestName,
                            contact: phone,
                            category: category,
                          );

                          ref.invalidate(fetchEventsProvider);

                          _nameController.clear();
                          _categoryController.clear();
                          _numberController.clear();

                          Navigator.pop(context);
                          SnackbarService()
                              .showSnackBar("Guest added successfully by ");
                        } catch (e) {
                          SnackbarService()
                              .showSnackBar("Failed to add guest: $e");
                        }
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();
    DateTime dateTime =
        DateTime.parse(widget.event.startTime.toString()).toLocal();
    String formattedTime = DateFormat('hh:mm a').format(dateTime);
    DateTime dateDate =
        DateTime.parse(widget.event.startDate.toString()).toLocal();
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateDate);

    log('event visibility start:     ${widget.event.startDate}');
    log('event visibility end:       ${widget.event.endDate}');
    log('event visibility event date:${widget.event.eventDate}');

    log('rsvp : ${widget.event.rsvp}');
    log('my id : ${id}');
    log('event registered?:$registered');
    return Scaffold(
      backgroundColor: kScaffoldColor,
      appBar: AppBar(
        title: Text(
          "Event Details",
          style: TextStyle(fontSize: 17),
        ),
        backgroundColor: kScaffoldColor,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9, // Set aspect ratio to 16:9
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Image.network(
                          widget.event.image ??
                              'https://placehold.co/600x400/png', // Replace with your image URL
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child; // Image loaded successfully
                            }
                            // While the image is loading, show shimmer effect
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFE4483E), // Red background color
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: widget.event.status != null &&
                                widget.event.status != ''
                            ? Row(
                                children: [
                                  Text(
                                    widget.event.status?.toLowerCase() ==
                                            "pending"
                                        ? "UPCOMING"
                                        : widget.event.status?.toUpperCase() ??
                                            '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                    size: 8,
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Event Title
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.event.eventName!,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Date and Time
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 15, color: kPrimaryColor),
                          const SizedBox(width: 8),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 15, color: kPrimaryColor),
                          const SizedBox(width: 8),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // const Divider(color: Color.fromARGB(255, 229, 220, 220)),
                // Padding(
                //   padding: const EdgeInsets.only(
                //     left: 16,
                //     right: 16,
                //   ),
                //   child: const Text('Organiser'),
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(
                //     left: 16,
                //     right: 16,
                //   ),
                //   child: Text(
                //     widget.event.organiserName ?? '',
                //     style: const TextStyle(
                //         fontSize: 20, fontWeight: FontWeight.w600),
                //   ),
                // ),
                // const SizedBox(
                //   height: 20,
                // ),
                // Padding(
                //   padding:
                //       const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                //   child: Text(
                //     widget.event.description ?? '',
                //     style: TextStyle(fontSize: 16, color: Colors.black87),
                //   ),
                // ),

                // ClipRRect(
                //                                   borderRadius:
                //                                       BorderRadius.circular(9),
                //                                   child: widget.event.o !=
                //                                               null &&
                //                                           user.companyLogo != ''
                //                                       ? Image.network(
                //                                           user.companyLogo!,
                //                                           height: 33,
                //                                           width: 40,
                //                                           fit: BoxFit.cover,
                //                                         )
                //                                       : const SizedBox())
                // const SizedBox(height: 24),
                // const Padding(
                //   padding: EdgeInsets.only(left: 10),
                //   child: Text(
                //     'Speakers',
                //     style: TextStyle(
                //       fontSize: 18,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 8),
                // ListView.builder(
                //   shrinkWrap: true,
                //   physics: const NeverScrollableScrollPhysics(),
                //   itemCount: widget.event.speakers!.length,
                //   itemBuilder: (context, index) {
                //     return Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: _buildSpeakerCard(
                //           widget.event.speakers?[index].image,
                //           widget.event.speakers?[index].name ?? '',
                //           widget.event.speakers?[index].designation ?? ''),
                //     );
                //   },
                // ),
                if (widget.event.venue != null) const SizedBox(height: 24),
                // Venue Section
                if (widget.event.venue != null)
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 8,
                    ),
                    child: Text(
                      'Venue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (widget.event.venue != null) const SizedBox(height: 8),
                if (widget.event.venue != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                    ),
                    child: Text(
                      widget.event.venue ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                if (widget.event.venue != null) const SizedBox(height: 8),
                if (widget.event.venue != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GestureDetector(
                      onTap: () {
                        openGoogleMaps(widget.event.venue ?? '');
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(5)),
                        height: 200,
                        child: Image.asset(
                          'assets/pngs/eventlocation.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 60),
                if (widget.event.coordinator!.contains(id)) ...[
                  if (widget.event.limit != null && widget.event.limit! > 0)
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 8),
                        child: Center(
                          child: Text(
                            _getRegistrationCountText(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        )),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: .1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: kWhite,
                          child: Icon(Icons.map_outlined, color: kPrimaryColor),
                        ),
                        title: Text(
                          'Member List',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                        onTap: () {
                          navigationService.pushNamed('EventMemberList',
                              arguments: widget.event);
                        },
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 90),
              ],
            ),
          ),
          if (!widget.event.coordinator!.contains(id) &&
              widget.event.status?.toLowerCase() != "completed")
            Consumer(
              builder: (context, ref, child) {
                final bool canRegister = _canRegister();
                final String buttonLabel = _getRegistrationButtonLabel();

                // Exclusive event check: if chapters list is non-empty and
                // the user's chapter is not in it, show exclusive notice.
                final userAsync = ref.watch(userProvider);
                final String? userChapterId =
                    userAsync.valueOrNull?.chapter?.id;
                final List<String> eventChapters = widget.event.chapters ?? [];
                final bool isExclusiveEvent = eventChapters.isNotEmpty;
                final bool isUserChapterAllowed = userChapterId != null &&
                    eventChapters.contains(userChapterId);

                if (isExclusiveEvent && !isUserChapterAllowed) {
                  return Positioned(
                    bottom: 36,
                    left: 16,
                    right: 16,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.orange.shade300, width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline,
                                color: Colors.orange.shade700, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'THIS IS AN EXCLUSIVE EVENT',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Positioned(
                  bottom: 36,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.event.limit != null && widget.event.limit! > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            _getRegistrationCountText(),
                            style: TextStyle(
                              color: canRegister
                                  ? Colors.grey[600]
                                  : Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      customButton(
                        sideColor: registered
                            ? Colors.green
                            : canRegister
                                ? kPrimaryColor
                                : Colors.grey[400]!,
                        buttonColor: registered
                            ? Colors.green
                            : canRegister
                                ? kPrimaryColor
                                : Colors.grey[400]!,
                        label: buttonLabel,
                        isLoading: isRegistering,
                        onPressed: canRegister
                            ? () async {
                                if (!registered &&
                                    widget.event.status?.toLowerCase() !=
                                        'cancelled') {
                                  setState(() {
                                    isRegistering = true;
                                  });

                                  try {
                                    await EventApiService.markEventAsRSVP(
                                        widget.event.id!);

                                    setState(() {
                                      // Backend stores in rsvpnew - add locally to match
                                      widget.event.rsvpnew!.add(id);
                                      registered = true;
                                    });

                                    ref.invalidate(fetchEventsProvider);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  } finally {
                                    setState(() {
                                      isRegistering = false;
                                    });
                                  }
                                }
                              }
                            : null,
                        fontSize: 16,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      if (widget.event.allowGuestResgistration == true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: showAddGuestSheet,
                              child: Text('Add guest'),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          if (widget.event.coordinator!.contains(id) &&
              widget.event.type != 'online')
            Positioned(
              right: 30,
              bottom: 30,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QRScannerPage(
                            eventId: widget.event.id ?? '',
                          )),
                ),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: kPrimaryColor,
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpeakerCard(String? imagePath, String name, String role) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: (imagePath != null && imagePath.isNotEmpty)
              ? NetworkImage(imagePath)
              : null, // Use image if available
          child: (imagePath == null || imagePath.isEmpty)
              ? const Icon(Icons.person, size: 40)
              : null, // Show icon if no image is provided
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          role,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
