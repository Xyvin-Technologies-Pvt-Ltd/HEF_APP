import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hef/src/data/api_routes/review_api/review_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/review_model.dart';
import 'package:hef/src/data/models/user_model.dart';

Map<int, int> getRatingDistribution(List<ReviewModel> reviews) {
  Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  for (var review in reviews) {
    distribution[review.rating!] = (distribution[review.rating] ?? 0) + 1;
  }
  return distribution;
}

double getAverageRating(List<ReviewModel> reviews) {
  if (reviews.isEmpty) return 0.0;
  int totalRating = reviews.fold(0, (sum, review) => sum + review.rating!);
  return totalRating / reviews.length;
}

class ReviewBarChart extends StatelessWidget {
  final List<ReviewModel> reviews;
  const ReviewBarChart({
    super.key,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final ratingDistribution = getRatingDistribution(reviews);
        final averageRating = getAverageRating(reviews);
        final totalReviews = reviews.length;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Container(
                      height: 60,
                      width: 80,
                      color: const Color(0xFFFFFCF2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Color(0xFFF5B358)),
                          const SizedBox(width: 4),
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                                color: Color(0xFFF5B358),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalReviews Reviews',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 16), // Space between left and right side

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(5, (index) {
                    int starCount = 5 - index;
                    int reviewCount = ratingDistribution[starCount] ?? 0;
                    double percentage =
                        totalReviews > 0 ? reviewCount / totalReviews : 0;

                    return Row(
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            minHeight: 4.5,
                            borderRadius: BorderRadius.circular(10),
                            value: percentage,
                            backgroundColor: Colors.grey[300],
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$starCount',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ReviewsCard extends StatelessWidget {
  final Map<int, int> ratingDistribution;
  final double averageRating;
  final int totalReviews;
  final ReviewModel review;

  const ReviewsCard({
    super.key,
    required this.ratingDistribution,
    required this.averageRating,
    required this.totalReviews,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start, // Align at the top
        children: [
          Column(
            children: [
              review.reviewer?.image != null
                  ? CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(review.reviewer!.image!),
                    )
                  : SvgPicture.asset(
                                  'assets/svg/icons/dummy_person_small.svg')
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            // Ensures the content stays within the available width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${review.reviewer?.name ?? ''}',
                        style: kSmallerTitleR.copyWith(
                          color: kBlack54,
                        )),
                    // Spacer(),
                    // Text(review.createdAt)
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  review.comment ?? '',
                  style: kBodyTitleR,
                  maxLines: null,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
