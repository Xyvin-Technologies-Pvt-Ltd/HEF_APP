import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/events_api/events_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/events_model.dart';
import 'package:hef/src/data/services/launch_url.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
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
  bool registered = false;
  @override
  void initState() {
    super.initState();
    registered = widget.event.rsvp?.contains(id) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();
    DateTime dateTime =
        DateTime.parse(widget.event.startTime.toString()).toLocal();
    String formattedTime = DateFormat('hh:mm a').format(dateTime);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

    log('rsvp : ${widget.event.rsvp}');
    log('my id : ${id}');
    bool registered = widget.event.rsvp?.contains(id) ?? false;
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
                                    widget.event.status?.toUpperCase() ?? '',
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
                const Divider(color: Color.fromARGB(255, 229, 220, 220)),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  child: const Text('Organiser'),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  child: Text(
                    widget.event.organiserName ?? '',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Text(
                    widget.event.description ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),

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
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Speakers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.event.speakers!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildSpeakerCard(
                          widget.event.speakers?[index].image,
                          widget.event.speakers?[index].name ?? '',
                          widget.event.speakers?[index].designation ?? ''),
                    );
                  },
                ),
                if (widget.event.venue != null) const SizedBox(height: 24),
                // Venue Section
                if (widget.event.venue != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                    ),
                    child: const Text(
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
                SizedBox(height: 20),
                if (widget.event.coordinator!.contains(id))
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
                        leading: CircleAvatar(
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
                SizedBox(height: 50),
              ],
            ),
          ),
          if (!widget.event.coordinator!.contains(id))
            Consumer(
              builder: (context, ref, child) {
                return Positioned(
                  bottom: 36,
                  left: 16,
                  right: 16,
                  child: customButton(
                    sideColor: registered ? Colors.green : kPrimaryColor,
                    buttonColor: registered ? Colors.green : kPrimaryColor,
                    label: widget.event.status == 'cancelled'
                        ? 'CANCELLED'
                        : registered
                            ? 'REGISTERED'
                            : 'REGISTER EVENT',
                    onPressed: () async {
                      if (!registered && widget.event.status != 'cancelled') {
                        await markEventAsRSVP(widget.event.id!);

                        setState(() {
                          widget.event.rsvp?.add(id); // Add the user to RSVP
                          registered = widget.event.rsvp?.contains(id) ?? false;
                        });

                        ref.invalidate(fetchEventsProvider);
                      }
                    },
                    fontSize: 16,
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
                // onTap: () => Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => QRScannerPage(
                //             eventId: widget.event.id ?? '',
                //           )),
                // ),
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
