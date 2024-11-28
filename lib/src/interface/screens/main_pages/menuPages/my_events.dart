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
              return ListView.builder(
                itemCount: registeredEvents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: eventCard(
                        context: context, event: registeredEvents[index]),
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
    String startTime = DateFormat('hh:mm a').format(event.startTime!);
    String startDate = DateFormat('yyyy-MM-dd').format(event.startDate!);
    String endDate = DateFormat('hh:mm a').format(event.endDate!);
    String endTime = DateFormat('yyyy-MM-dd').format(event.endTime!);
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    // If the image is fully loaded, show the image
                    return child;
                  }
                  // While the image is loading, show shimmer effect
                  return Container(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.network('https://placehold.co/600x400');
                },
                event.image ?? 'https://via.placeholder.com/400x200',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              const Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  color: const Color(0xFFA9F3C7),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(event.status!,
                      style: TextStyle(color: Color(0xFF0F7036), fontSize: 14)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  event.type!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3F0A9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 20, color: Color(0xFF700F0F)),
                          const SizedBox(width: 5),
                          Text(
                            startDate,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF700F0F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFAED0E9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 20, color: Color(0xFF0E1877)),
                          const SizedBox(width: 5),
                          Text(
                            startTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF0E1877),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      event.type!,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        event.description ?? '',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      launchUrl(Uri.parse(event.link ?? ''));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            4), // Adjust the value to make the edge less circular
                      ),
                      minimumSize:
                          const Size(150, 40), // Adjust the width of the button
                    ),
                    child: const Text('JOIN',
                        style: TextStyle(color: Colors.white)),
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
