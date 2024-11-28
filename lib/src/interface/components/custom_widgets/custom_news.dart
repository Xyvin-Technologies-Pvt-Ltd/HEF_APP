import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:shimmer/shimmer.dart';

Widget newsCard({
  required String? imageUrl,
  required String title,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return shimmerPlaceholder(); 
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return shimmerPlaceholder();
                    },
                  )
                : shimmerPlaceholder(), 
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: kBodyTitleR,
              maxLines: 2, // Limit to 2 lines
              overflow: TextOverflow.ellipsis, // Show ellipsis for overflow
            ),
          ),
        ],
      ),
    ),
  );
}

Widget shimmerPlaceholder() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      height: 100,
      width: double.infinity,
      color: Colors.grey[300],
    ),
  );
}
