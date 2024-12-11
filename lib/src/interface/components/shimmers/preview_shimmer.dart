import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Top action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildShimmerCircle(),
                const SizedBox(width: 10),
                _buildShimmerCircle(),
              ],
            ),
            const SizedBox(height: 20),
            // Profile picture and name
            Column(
              children: [
                _buildShimmerCircle(radius: 45),
                const SizedBox(height: 10),
                _buildShimmerLine(width: 120, height: 20),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildShimmerCircle(radius: 16),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerLine(width: 100, height: 16),
                        const SizedBox(height: 5),
                        _buildShimmerLine(width: 80, height: 14),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Member info
            _buildShimmerContainer(width: double.infinity, height: 40),
            const SizedBox(height: 20),
            // Contact details
            Column(
              children: [
                Row(
                  children: [
                    _buildShimmerCircle(radius: 12),
                    const SizedBox(width: 10),
                    _buildShimmerLine(width: 150, height: 16),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildShimmerCircle(radius: 12),
                    const SizedBox(width: 10),
                    _buildShimmerLine(width: 200, height: 16),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildShimmerCircle(radius: 12),
                    const SizedBox(width: 10),
                    Expanded(child: _buildShimmerLine(height: 16)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildShimmerCircle(radius: 12),
                    const SizedBox(width: 10),
                    _buildShimmerLine(width: 150, height: 16),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildShimmerCircle(radius: 12),
                    const SizedBox(width: 10),
                    _buildShimmerLine(width: 150, height: 16),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCircle({double radius = 25}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildShimmerLine({double width = double.infinity, double height = 16}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildShimmerContainer({double width = double.infinity, double height = 16}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
