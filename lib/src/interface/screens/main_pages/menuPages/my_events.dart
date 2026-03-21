import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/events_api/events_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/events_model.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class MyEventsPage extends StatelessWidget {
  const MyEventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final asyncEvents = ref.watch(fetchMyEventsProvider);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              "My Events",
              style: TextStyle(fontSize: 17),
            ),
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: asyncEvents.when(
            data: (registeredEvents) {
              print(registeredEvents);

              // Filter out completed events
              final activeEvents = registeredEvents
                  .where((event) => event.status?.toLowerCase() != 'completed')
                  .toList();

              return ListView.builder(
                itemCount: activeEvents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child:
                        eventCard(context: context, event: activeEvents[index]),
                  );
                },
              );
            },
            loading: () => Center(child: LoadingAnimation()),
            error: (error, stackTrace) {
              // Handle error state
              return Center(
                child: Text('NO EVENTS REGISTERED'),
              );
            },
          ),
        );
      },
    );
  }

  Widget eventCard({required BuildContext context, required Event event}) {
    String startTime = DateFormat('hh:mm a').format(event.startTime!.toLocal());
    String startDate =
        DateFormat('yyyy-MM-dd').format(event.startDate!.toLocal());
    String endDate = DateFormat('hh:mm a').format(event.endDate!.toLocal());
    String endTime = DateFormat('yyyy-MM-dd').format(event.endTime!.toLocal());
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.grey[300]),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network('https://placehold.co/600x400');
                  },
                  event.image ?? 'https://via.placeholder.com/400x200',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (event.status != null && event.status != '')
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4483E),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.status?.toLowerCase() == "pending"
                              ? "UPCOMING"
                              : event.status?.toUpperCase() ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.circle,
                          color: Colors.white,
                          size: 8,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: Text(event.type!),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              event.eventName!,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 15, color: kPrimaryColor),
                    const SizedBox(width: 8),
                    Text(
                      startDate,
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
                      startTime,
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
          if (event.type == 'offline' && event.venue != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                event.venue!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          if (event.link != null && event.link != '')
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  launchUrl(Uri.parse(event.link ?? ''));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  minimumSize: const Size(120, 36),
                ),
                child:
                    const Text('JOIN', style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
