import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildShimmerPromotionsColumn({
  required BuildContext context,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 90,
      ),
      shimmerTop(
        context: context,
      ),
      SizedBox(
        height: 20,
      ),
      shimmerBanner(context: context),
      const SizedBox(height: 16),
      shimmerNotice(context: context),
      const SizedBox(height: 16),
      shimmerPoster(context: context),
      const SizedBox(height: 16),
    ],
  );
}

Widget shimmerTop({
  required BuildContext context,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Toolbar with shimmer for the small circle (Image.asset)

      const SizedBox(height: 20),
      // Shimmer for the welcome text
      Padding(
        padding: const EdgeInsets.only(left: 15, top: 10),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 25, // Approximate height for the text
            width: 150, // Width for "Welcome,"
            color: Colors.grey,
          ),
        ),
      ),
      // Conditional shimmer for the admin type
      Padding(
        padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 20, // Approximate height for the text
            width: 250, // Width for "user.name - (adminType)"
            color: Colors.grey,
          ),
        ),
      ),
    ],
  );
}

Widget shimmerBanner({
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: MediaQuery.of(context).size.width - 32,
        height: 175,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  );
}

Widget shimmerNotice({
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: MediaQuery.of(context).size.width - 32,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  );
}

Widget shimmerPoster({
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: MediaQuery.of(context).size.width - 32,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  );
}
