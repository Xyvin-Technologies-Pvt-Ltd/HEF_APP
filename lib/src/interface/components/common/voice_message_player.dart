import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:hef/src/data/constants/color_constants.dart';

class VoiceMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final Color? backgroundColor;
  final Color? iconColor;

  /// Waveform row used inside chat bubbles (play, bars, duration, speed).
  final bool useWaveform;

  const VoiceMessagePlayer({
    Key? key,
    required this.audioUrl,
    this.backgroundColor,
    this.iconColor,
    this.useWaveform = false,
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
  double _playbackRate = 1.0;

  static const List<double> _waveform = [
    0.35, 0.62, 0.48, 0.9, 0.55, 1.0, 0.42, 0.78, 0.5, 0.88,
    0.46, 0.72, 0.38, 0.66, 0.52, 0.84, 0.44, 0.7, 0.32, 0.58,
    0.4, 0.76, 0.48, 0.64, 0.3, 0.5, 0.36, 0.62,
  ];

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
        await _audioPlayer.setPlaybackRate(_playbackRate);
        
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

  String _formatDuration(Duration duration, {bool padded = false}) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final minuteText =
        padded ? minutes.toString().padLeft(2, '0') : '$minutes';
    return '$minuteText:$seconds';
  }

  String get _speedLabel {
    if (_playbackRate == 2.0) return '2x';
    if (_playbackRate == 1.5) return '1.5x';
    return '1x';
  }

  Future<void> _cycleSpeed() async {
    final next = _playbackRate == 1.0
        ? 1.5
        : _playbackRate == 1.5
            ? 2.0
            : 1.0;
    setState(() => _playbackRate = next);
    if (_isPlaying) {
      try {
        await _audioPlayer.setPlaybackRate(next);
      } catch (_) {}
    }
  }

  Widget _buildWaveform() {
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final playedCount = (progress * _waveform.length).round();
    const played = Color(0xFFFA6D08);
    const pending = Color(0xFFD5D5D5);

    return SizedBox(
      height: 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < _waveform.length; i++)
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 2.5,
                  height: 6 + (22 * _waveform[i]),
                  decoration: BoxDecoration(
                    color: i < playedCount ? played : pending,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWaveformPlayer() {
    final shown = _duration == Duration.zero ? Duration.zero : _duration;

    return Row(
      children: [
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFA6D08),
              shape: BoxShape.circle,
            ),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kWhite),
                    ),
                  )
                : Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: kWhite,
                    size: 28,
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: _buildWaveform()),
        const SizedBox(width: 8),
        Text(
          _formatDuration(shown),
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF56575B),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _cycleSpeed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _speedLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6E7176),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useWaveform) return _buildWaveformPlayer();

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
                      ? '${_formatDuration(_position, padded: true)} / ${_formatDuration(_duration, padded: true)}'
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