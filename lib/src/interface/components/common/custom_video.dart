
import 'package:flutter/material.dart';
import 'package:hef/src/data/models/promotion_model.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
Widget customVideo({required BuildContext context, required Promotion video}) {
  final videoUrl = video.link;

  final ytController = YoutubePlayerController.fromVideoId(
    videoId: YoutubePlayerController.convertUrlToId(videoUrl ?? '')!,
    autoPlay: false,
    params: const YoutubePlayerParams(
      enableJavaScript: true,
      loop: true,
      mute: false,
      showControls: true,
      showFullscreenButton: true,
    ),
  );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Auto-scrolling marquee for the video title
      // Padding(
      //   padding: const EdgeInsets.only(top: 10),
      //   child: AutoScrollText(
      //     text: video.title ?? '',
      //     width: MediaQuery.of(context).size.width *
      //         0.9, // Set width to avoid taking full screen
      //   ),
      // ),
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          width: MediaQuery.of(context).size.width, // Full-screen width
          height: 200,
          decoration: BoxDecoration(
            color: Colors.transparent, // Transparent background
          ),
          child: ClipRRect(
            child: YoutubePlayer(
              controller: ytController,
              aspectRatio: 16 / 9,
            ),
          ),
        ),
      ),
    ],
  );
}
