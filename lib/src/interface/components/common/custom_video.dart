
import 'package:flutter/material.dart';
import 'package:hef/src/data/models/promotion_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

Widget customVideo({required BuildContext context, required Promotion video}) {
  final videoUrl = video.link;
  final videoId = YoutubePlayer.convertUrlToId(videoUrl ?? '');

  final controller = YoutubePlayerController(
    initialVideoId: videoId ?? '',
    flags: const YoutubePlayerFlags(disableDragSeek: true,
      autoPlay: false,
      loop: true,
      mute: false,
      enableCaption: true,
      isLive: false,
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
              controller: controller,
              aspectRatio: 16 / 9,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.red,
              progressColors: const ProgressBarColors(
                playedColor: Colors.red,
                handleColor: Colors.redAccent,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
