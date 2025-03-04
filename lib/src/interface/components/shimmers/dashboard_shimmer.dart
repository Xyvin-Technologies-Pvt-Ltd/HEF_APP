import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildDashboardShimmer() {
  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 20),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildShimmerCard(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildShimmerCard(),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildShimmerCard(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildShimmerCard(),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildShimmerCard(),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildShimmerCard() {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 0,
          blurRadius: 5,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 50,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    ),
  );
} 