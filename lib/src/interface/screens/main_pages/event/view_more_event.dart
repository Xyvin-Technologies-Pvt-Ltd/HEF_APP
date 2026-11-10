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
    if (widget.event.registrationEnabled == false) return 'REGISTRATION CLOSED';

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
    if (registered ||
        widget.event.status?.toLowerCase() == 'cancelled' ||
        widget.event.registrationEnabled == false) return false;

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

  String get _formattedDate {
    final raw = widget.event.eventDate ?? widget.event.startDate;
    if (raw == null) return 'Date TBA';
    return DateFormat('MMM d, yyyy').format(raw.toLocal());
  }

  String get _formattedTime {
    final raw = widget.event.startTime ?? widget.event.eventDate;
    if (raw == null) return 'Time TBA';
    return DateFormat('hh:mm a').format(raw.toLocal());
  }

  String get _statusLabel {
    final status = widget.event.status?.toLowerCase() ?? '';
    if (status == 'pending') return 'Upcoming';
    if (status.isEmpty) return 'Event';
    return status[0].toUpperCase() + status.substring(1);
  }

  Color get _statusColor {
    switch (widget.event.status?.toLowerCase()) {
      case 'live':
        return const Color(0xFF2D8D00);
      case 'completed':
        return const Color(0xFF6B7280);
      case 'cancelled':
        return const Color(0xFFE4483E);
      default:
        return kPrimaryColor;
    }
  }

  Future<void> _registerForEvent() async {
    if (registered || widget.event.status?.toLowerCase() == 'cancelled') {
      return;
    }
    setState(() => isRegistering = true);
    try {
      await EventApiService.markEventAsRSVP(widget.event.id!);
      setState(() {
        widget.event.rsvpnew!.add(id);
        registered = true;
      });
      ref.invalidate(fetchEventsProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();
    final venue = widget.event.venue?.trim() ?? '';
    final description = widget.event.description?.trim() ?? '';
    final isCoordinator = widget.event.coordinator?.contains(id) ?? false;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    log('rsvp : ${widget.event.rsvp}');
    log('my id : $id');
    log('event registered?:$registered');

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C1C), size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Event Details',
          style: TextStyle(
            color: Color(0xFF1C1C1C),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1)),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 140 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          widget.event.image ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFFFF4EA),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.event_outlined,
                                color: kPrimaryColor,
                                size: 40,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(color: Colors.grey[300]),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  widget.event.eventName?.trim().isNotEmpty == true
                      ? widget.event.eventName!
                      : 'Untitled Event',
                  style: const TextStyle(
                    color: Color(0xFF1E2937),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                if (widget.event.type?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.event.type!,
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _infoCard(
                  children: [
                    _infoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: _formattedDate,
                    ),
                    const SizedBox(height: 14),
                    _infoRow(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: _formattedTime,
                    ),
                    if (venue.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _infoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Venue',
                        value: venue,
                      ),
                    ],
                    if (widget.event.organiserName?.trim().isNotEmpty ==
                        true) ...[
                      const SizedBox(height: 14),
                      _infoRow(
                        icon: Icons.person_outline,
                        label: 'Organiser',
                        value: widget.event.organiserName!,
                      ),
                    ],
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'About',
                    style: TextStyle(
                      color: Color(0xFF202833),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF536477),
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
                if (venue.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Location',
                    style: TextStyle(
                      color: Color(0xFF202833),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => openGoogleMaps(venue),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/pngs/eventlocation.png',
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.near_me_outlined,
                                      size: 18, color: kPrimaryColor),
                                  SizedBox(width: 8),
                                  Text(
                                    'Get Directions',
                                    style: TextStyle(
                                      color: Color(0xFF1E2937),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (isCoordinator) ...[
                  const SizedBox(height: 16),
                  if (widget.event.limit != null && widget.event.limit! > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _getRegistrationCountText(),
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  Material(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        navigationService.pushNamed(
                          'EventMemberList',
                          arguments: widget.event,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE9EAEC)),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xFFFFF1E6),
                              child: Icon(Icons.groups_outlined,
                                  color: kPrimaryColor, size: 20),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Member List',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E2937),
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                size: 22, color: Color(0xFF9AA0A6)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isCoordinator &&
              widget.event.status?.toLowerCase() != 'completed')
            Consumer(
              builder: (context, ref, child) {
                final canRegister = _canRegister();
                final buttonLabel = _getRegistrationButtonLabel();
                final userChapterId =
                    ref.watch(userProvider).valueOrNull?.chapter?.id;
                final eventChapters = widget.event.chapters ?? [];
                final isExclusiveEvent = eventChapters.isNotEmpty;
                final isUserChapterAllowed = userChapterId != null &&
                    eventChapters.contains(userChapterId);

                if (isExclusiveEvent && !isUserChapterAllowed) {
                  return Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24 + bottomInset,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4EA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFD8C2)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline,
                              color: kPrimaryColor, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'This is an exclusive event',
                            style: TextStyle(
                              color: Color(0xFF9A3412),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
                    decoration: const BoxDecoration(
                      color: kWhite,
                      border: Border(
                        top: BorderSide(color: Color(0xFFF1F1F1)),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.event.limit != null &&
                            widget.event.limit! > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _getRegistrationCountText(),
                              style: TextStyle(
                                color: canRegister
                                    ? const Color(0xFF6B7280)
                                    : const Color(0xFFC9300E),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        customButton(
                          sideColor: registered
                              ? Colors.green
                              : widget.event.registrationEnabled == false
                                  ? kRed
                                  : canRegister
                                      ? kPrimaryColor
                                      : Colors.grey[400]!,
                          buttonColor: registered
                              ? Colors.green
                              : widget.event.registrationEnabled == false
                                  ? kRed
                                  : canRegister
                                      ? kPrimaryColor
                                      : Colors.grey[400]!,
                          label: buttonLabel,
                          isLoading: isRegistering,
                          onPressed: canRegister ? _registerForEvent : null,
                          fontSize: 16,
                        ),
                        if (widget.event.allowGuestResgistration == true) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: showAddGuestSheet,
                              style: TextButton.styleFrom(
                                foregroundColor: kPrimaryColor,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Add guest',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          if (isCoordinator && widget.event.type != 'online')
            Positioned(
              right: 20,
              bottom: 24 + bottomInset,
              child: FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRScannerPage(
                      eventId: widget.event.id ?? '',
                    ),
                  ),
                ),
                backgroundColor: kPrimaryColor,
                elevation: 4,
                child: const Icon(Icons.qr_code_scanner, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EAEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF1E6),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: kPrimaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8A9AAA),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1E2937),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
