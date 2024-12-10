import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/attendance_user_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';

class EventAttendanceSuccessPage extends StatefulWidget {
  final AttendanceUserModel user;

  const EventAttendanceSuccessPage({super.key, required this.user});
  @override
  _EventAttendanceSuccessPageState createState() =>
      _EventAttendanceSuccessPageState();
}

class _EventAttendanceSuccessPageState extends State<EventAttendanceSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _checkmarkScaleAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _contentScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Define the fill animation
    _fillAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Define the checkmark position animation
    _positionAnimation = Tween<Offset>(
      begin: Offset(0, 0), // Center
      end: Offset(0, -2.5), // Move to top
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Define the checkmark scaling animation
    _checkmarkScaleAnimation = Tween<double>(begin: 1, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Define content fade and scale animations
    _contentFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    _contentScaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Background fill animation
              Container(
                color: kPrimaryColor.withOpacity(_fillAnimation.value),
                child: CustomPaint(
                  painter: FillPainter(progress: _fillAnimation.value),
                  size: MediaQuery.of(context).size,
                ),
              ),

              // Checkmark animation
              Center(
                child: SlideTransition(
                  position: _positionAnimation,
                  child: ScaleTransition(
                    scale: _checkmarkScaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        size: 80,
                        color: Color(0xFFD1661B),
                      ),
                    ),
                  ),
                ),
              ),

              // Center container with text and button
              FadeTransition(
                opacity: _contentFadeAnimation,
                child: ScaleTransition(
                  scale: _contentScaleAnimation,
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80, // Diameter + border width
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: kPrimaryColor,
                                  width: 2.0, // Border width
                                ),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  widget.user.image ?? '',
                                  width:
                                      60, // Diameter of the circle (excluding border)
                                  height: 60,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('${widget.user.username}',
                                textAlign: TextAlign.center,
                                style: kSubHeadingR),
                            Text(
                              '${widget.user.email}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              '${widget.user.state} > ${widget.user.zone} > ${widget.user.district} > ${widget.user.chapter}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 30),
                            customButton(
                              label: 'Done',
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class FillPainter extends CustomPainter {
  final double progress;

  FillPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = kPrimaryColor;

    // Radius expands from the center
    final double radius = size.shortestSide * progress * 2;

    canvas.drawCircle(
      size.center(Offset.zero),
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
