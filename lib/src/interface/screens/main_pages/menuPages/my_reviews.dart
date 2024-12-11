import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hef/src/data/api_routes/review_api/review_api.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/interface/components/common/review_barchart.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';


class ReviewsState extends StateNotifier<int> {
  ReviewsState() : super(1);

  void showMoreReviews(int totalReviews) {
    state = (state + 2).clamp(0, totalReviews);
  }
}

final reviewsProvider = StateNotifierProvider<ReviewsState, int>((ref) {
  return ReviewsState();
});

class MyReviewsPage extends ConsumerStatefulWidget {
  const MyReviewsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends ConsumerState<MyReviewsPage> {
  @override
  void initState() {
    super.initState();
    // Move invalidate call to initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(fetchReviewsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final reviewsToShow = ref.watch(reviewsProvider);
        final asyncReviews = ref.watch(fetchReviewsProvider(userId: id));
        if (reviewsToShow == 0) {
          return const Center(
            child: Text('No Reviews'),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                'My Reviews',
                style: TextStyle(fontSize: 17),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0,
            ),
            body: asyncReviews.when(
              loading: () => Center(child: LoadingAnimation()),
              error: (error, stackTrace) {
                return Center(
                  child:Text('No Reviews')
                );
              },
              data: (reviews) {
                final ratingDistribution = getRatingDistribution(reviews);
                final averageRating = getAverageRating(reviews);
                final totalReviews = reviews.length;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 1.0,
                        color: Colors.grey[300], // Divider color
                      ),
                      if (totalReviews != 0)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ReviewBarChart(reviews: reviews,
                          ),
                        ),
                      if (reviews.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: reviewsToShow,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ReviewsCard(
                                  review: reviews[index],
                                  ratingDistribution: ratingDistribution,
                                  averageRating: averageRating,
                                  totalReviews: totalReviews,
                                ),
                              );
                            },
                          ),
                        ),
                      if (reviewsToShow < reviews.length)
                        TextButton(
                          onPressed: () {
                            ref
                                .read(reviewsProvider.notifier)
                                .showMoreReviews(reviews.length);
                          },
                          child: Text('View More'),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
