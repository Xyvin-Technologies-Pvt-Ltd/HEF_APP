import 'package:flutter/material.dart';
import 'package:hef/src/data/models/promotion_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

Widget customVideo({required BuildContext context, required Promotion video}) {
  final videoUrl = video.link;
  final videoId = YoutubePlayer.convertUrlToId(videoUrl ?? '') ?? '';
  final thumbnailUrl = video.media?.isNotEmpty == true
      ? video.media!
      : 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        onTap: videoId.isEmpty
            ? null
            : () {
                final controller = YoutubePlayerController(
                  initialVideoId: videoId,
                  flags: const YoutubePlayerFlags(
                    disableDragSeek: true,
                    autoPlay: true,
                    loop: false,
                    mute: false,
                    controlsVisibleAtStart: true,
                    enableCaption: true,
                    isLive: false,
                  ),
                );
                showDialog<void>(
                  context: context,
                  barrierColor: Colors.black87,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.black,
                    insetPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 24,
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: YoutubePlayer(
                        controller: controller,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: const Color(0xFFFA6D08),
                        aspectRatio: 16 / 9,
                      ),
                    ),
                  ),
                ).whenComplete(controller.dispose);
              },
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF202833),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    const ColoredBox(color: Color(0xFF202833)),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC111820)],
                    stops: [0.4, 1],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.28),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFFFA6D08),
                    size: 40,
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFA6D08),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'CHAPTER HIGHLIGHT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if ((video.title ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        video.title!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
