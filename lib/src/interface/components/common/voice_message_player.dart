import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:hef/src/data/constants/color_constants.dart';

class VoiceMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final Color? backgroundColor;
  final Color? iconColor;

  const VoiceMessagePlayer({
    Key? key,
    required this.audioUrl,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading = false; // Remove loading state confusion
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        setState(() {
          _isLoading = true;
        });
        
        if (_position == Duration.zero) {
          await _audioPlayer.play(UrlSource(widget.audioUrl));
        } else {
          await _audioPlayer.resume();
        }
        
        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error playing audio: $e');
      setState(() {
        _isPlaying = false;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error playing audio')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? kPrimaryLightColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.iconColor ?? kPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(kWhite),
                      ),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: kWhite,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: kGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.iconColor ?? kPrimaryColor,
                  ),
                  minHeight: 3,
                ),
                const SizedBox(height: 4),
                Text(
                  _duration != Duration.zero
                      ? '${_formatDuration(_position)} / ${_formatDuration(_duration)}'
                      : 'Voice message',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kGreyDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.mic,
            color: widget.iconColor ?? kPrimaryColor,
            size: 16,
          ),
        ],
      ),
    );
  }
}