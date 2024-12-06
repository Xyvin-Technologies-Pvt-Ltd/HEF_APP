import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/review_api/review_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/common/review_barchart.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';

class ProfileAnalyticsPage extends StatelessWidget {
  final UserModel user;

  const ProfileAnalyticsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Back"),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: .1,
                  offset: Offset(0, 1),
                ),
              ]),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 90, // Diameter of the avatar including the border
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kPrimaryColor,
                          width: 2.0, // Border width
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(user.image ?? ''),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      user.name ?? '',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.email ?? '',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: 190,
                      height: 40,
                      child: customButton(
                          label: 'View Profile Card',
                          onPressed: () {},
                          buttonColor: kWhite,
                          labelColor: kPrimaryColor),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Statistics Section
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                      'Business', '${user.feedCount}', kPrimaryColor),
                ),
                SizedBox(width: 8), // Optional spacing between cards
                Expanded(
                  child: _buildStatCard(
                      'Products', '${user.productCount}', Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Reviews Section
            Text(
              'Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final asyncReviews =
                    ref.watch(fetchReviewsProvider(userId: user.uid ?? ''));
                return asyncReviews.when(
                  data: (reviews) {
                    final ratingDistribution = getRatingDistribution(reviews);
                    final averageRating = getAverageRating(reviews);
                    final totalReviews = reviews.length;
                    return SizedBox(
                      height: 400,
                      child: ListView.builder(
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 0,
                                    blurRadius: 5,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, left: 20, right: 10),
                                child: ReviewsCard(
                                  ratingDistribution: ratingDistribution,
                                  averageRating: averageRating,
                                  totalReviews: totalReviews,
                                  review: reviews[index],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: LoadingAnimation()),
                  error: (error, stackTrace) => const SizedBox(),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: kSubHeadingB.copyWith(color: kBlack54),
            textAlign: TextAlign.start,
          ),
          Text(
            'Posted',
            style: kSubHeadingB.copyWith(color: kBlack54),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 8),
          Text(value,
              style: kDisplayTitleB.copyWith(color: color, fontSize: 40)),
        ],
      ),
    );
  }
}
