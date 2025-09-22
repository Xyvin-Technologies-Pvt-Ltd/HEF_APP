import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
class VoiceRecorderWidget extends StatefulWidget {
  final bool isRecording;
  final bool isLocked;
  final Duration duration;
  final VoidCallback onCancel;
  final VoidCallback onSend;
  final VoidCallback onLock;
  final VoidCallback onUnlock;

  const VoiceRecorderWidget({
    Key? key,
    required this.isRecording,
    required this.isLocked,
    required this.duration,
    required this.onCancel,
    required this.onSend,
    required this.onLock,
    required this.onUnlock,
  }) : super(key: key);

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with TickerProviderStateMixin {
  late AnimationController _lockAnimationController;
  late AnimationController _cancelAnimationController;
  late Animation<double> _lockScaleAnimation;
  late Animation<double> _cancelScaleAnimation;
  bool _showLockHint = false;
  bool _showCancelHint = false;

  @override
  void initState() {
    super.initState();
    
    _lockAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _cancelAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _lockScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _lockAnimationController,
      curve: Curves.elasticOut,
    ));

    _cancelScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _cancelAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _lockAnimationController.dispose();
    _cancelAnimationController.dispose();
    super.dispose();
  }

  void _showLockAnimation() {
    setState(() {
      _showLockHint = true;
    });
    _lockAnimationController.forward().then((_) {
      _lockAnimationController.reverse();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showLockHint = false;
        });
      }
    });
  }

  void _showCancelAnimation() {
    setState(() {
      _showCancelHint = true;
    });
    _cancelAnimationController.forward().then((_) {
      _cancelAnimationController.reverse();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showCancelHint = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('VoiceRecorderWidget build called, isRecording: ${widget.isRecording}');
    if (!widget.isRecording) return const SizedBox.shrink();
    
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
          decoration: BoxDecoration(
            color: kGreyDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isLocked ? kPrimaryColor : kGrey,
              width: widget.isLocked ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: kBlack.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Recording indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: kRed,
                  shape: BoxShape.circle,
                ),
                child: widget.isLocked 
                  ? const Icon(Icons.lock, color: kWhite, size: 8)
                  : null,
              ),
              const SizedBox(width: 12),
              
              // Duration
              Expanded(
                child: Text(
                  _formatDuration(widget.duration),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber,
                  ),
                ),
              ),
              
              // Lock status indicator
              if (widget.isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, color: kPrimaryColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Locked',
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(width: 8),
              
                             // Cancel button
               Container(
                 width: 48,
                 height: 48,
                 decoration: BoxDecoration(
                   color: kRed,
                   shape: BoxShape.circle,
                 ),
                 child: Material(
                   color: Colors.transparent,
                   child: InkWell(
                     borderRadius: BorderRadius.circular(24),
                     onTap: () {
                       print('Cancel button pressed');
                       widget.onCancel();
                     },
                     child: const Icon(Icons.close, color: kWhite, size: 24),
                   ),
                 ),
               ),
              
              const SizedBox(width: 8),
              
                             // Send button
               Container(
                 width: 48,
                 height: 48,
                 decoration: BoxDecoration(
                   color: kPrimaryColor,
                   shape: BoxShape.circle,
                 ),
                 child: Material(
                   color: Colors.transparent,
                   child: InkWell(
                     borderRadius: BorderRadius.circular(24),
                     onTap: () {
                       print('Send button pressed');
                       widget.onSend();
                     },
                     child: const Icon(Icons.send, color: kWhite, size: 24),
                   ),
                 ),
               ),
            ],
          ),
        ),
        
        // Lock hint animation
        if (_showLockHint)
          Positioned(
            top: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _lockScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _lockScaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, color: kWhite, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.isLocked ? 'Unlocked!' : 'Locked!',
                          style: const TextStyle(
                            color: kWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        
        // Cancel hint animation
        if (_showCancelHint)
          Positioned(
            top: 20,
            left: 20,
            child: AnimatedBuilder(
              animation: _cancelScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _cancelScaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: kRed,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cancel, color: kWhite, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Cancelled!',
                          style: TextStyle(
                            color: kWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
} 