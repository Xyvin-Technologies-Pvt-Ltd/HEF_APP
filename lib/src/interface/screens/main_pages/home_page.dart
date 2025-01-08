import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hef/src/data/api_routes/events_api/events_api.dart';
import 'package:hef/src/data/api_routes/news_api/news_api.dart';
import 'package:hef/src/data/api_routes/notification_api/notification_api.dart';
import 'package:hef/src/data/api_routes/promotion_api/promotion_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/promotion_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/router/nav_router.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/Drawer/drawer.dart';
import 'package:hef/src/interface/components/common/custom_video.dart';
import 'package:hef/src/interface/components/custom_widgets/custom_news.dart';
import 'package:hef/src/interface/components/custom_widgets/event_Card.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/components/shimmers/promotion_shimmers.dart';
import 'package:hef/src/interface/screens/main_pages/news_page.dart';
import 'package:hef/src/interface/screens/main_pages/notification_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends ConsumerStatefulWidget {
  final UserModel user;
  const HomePage({super.key, required this.user});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _advancedDrawerController = AdvancedDrawerController();

  int _currentBannerIndex = 0;
  int _currentNoticeIndex = 0;
  int _currentPosterIndex = 0;
  int _currentEventIndex = 0;
  int _currentVideoIndex = 0;

  double _calculateDynamicHeight(List<Promotion> notices) {
    double maxHeight = 0.0;

    for (var notice in notices) {
      // Estimate height based on the length of title and description
      final double titleHeight =
          _estimateTextHeight(notice.title!, 18.0); // Font size 18 for title
      final double descriptionHeight = _estimateTextHeight(
          notice.description!, 14.0); // Font size 14 for description

      final double itemHeight =
          titleHeight + descriptionHeight; // Adding padding
      if (itemHeight > maxHeight) {
        maxHeight = itemHeight + MediaQuery.sizeOf(context).width * 0.05;
      }
    }
    return maxHeight;
  }

  double _estimateTextHeight(String text, double fontSize) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final int numLines = (text.length / (screenWidth / fontSize)).ceil();
    return numLines * fontSize * 1.2 + 15;
  }

  CarouselController controller = CarouselController();
  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();
    return Consumer(
      builder: (context, ref, child) {
        final asyncPromotions = ref.watch(fetchPromotionsProvider);
        final asyncEvents = ref.watch(fetchEventsProvider);
        final asyncNews = ref.watch(fetchNewsProvider);
        return RefreshIndicator(
          color: kPrimaryColor,
          onRefresh: () async {
            ref.invalidate(fetchPromotionsProvider);
            // ref.invalidate(fetchEventsProvider);
          },
          child: AdvancedDrawer(
            drawer: customDrawer(user: widget.user),
            backdrop: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(color: kWhite),
            ),
            controller: _advancedDrawerController,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 300),
            animateChildDecoration: true,
            rtlOpening: false,
            // openScale: 1.0,
            disabledGestures: false,
            childDecoration: const BoxDecoration(
              // NOTICE: Uncomment if you want to add shadow behind the page.
              // Keep in mind that it may cause animation jerks.
              // boxShadow: <BoxShadow>[
              //   BoxShadow(
              //     color: Colors.black12,
              //     blurRadius: 0.0,
              //   ),
              // ],
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: Scaffold(
              backgroundColor: kScaffoldColor,
              body: asyncPromotions.when(
                data: (promotions) {
                  final banners = promotions
                      .where((promo) => promo.type == 'banner')
                      .toList();
                  final notices = promotions
                      .where((promo) => promo.type == 'notice')
                      .toList();
                  final posters = promotions
                      .where((promo) => promo.type == 'poster')
                      .toList();
                  final videos = promotions
                      .where((promo) => promo.type == 'video')
                      .toList();
                  final filteredVideos = videos
                      .where((video) => video.link!.startsWith('http'))
                      .toList();

                  return SafeArea(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage('assets/jpgs/scaffoldBackground.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 45.0, // Match the toolbarHeight
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/jpgs/scaffoldBackground.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Leading section
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: InkWell(
                                          onTap: () => _advancedDrawerController
                                              .showDrawer(),
                                          child: SizedBox(
                                            width: 60, // Match the leadingWidth
                                            child: ValueListenableBuilder<
                                                AdvancedDrawerValue>(
                                              valueListenable:
                                                  _advancedDrawerController,
                                              builder: (_, value, __) {
                                                return AnimatedSwitcher(
                                                  duration: const Duration(
                                                      milliseconds: 250),
                                                  child: Image.asset(
                                                      'assets/pngs/hef_logo.png'),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      // Actions section
                                      Consumer(
                                        builder: (context, ref, child) {
                                          final asyncNotifications = ref.watch(
                                              fetchNotificationsProvider);
                                          return asyncNotifications.when(
                                            data: (notifications) {
                                              bool userExists = notifications
                                                  .any((notification) =>
                                                      notification.users?.any(
                                                          (user) =>
                                                              user.userId ==
                                                              id) ??
                                                      false);
                                              return IconButton(
                                                icon: userExists
                                                    ? const Icon(
                                                        Icons
                                                            .notification_add_outlined,
                                                        color: kRed)
                                                    : const Icon(Icons
                                                        .notifications_none_outlined),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const NotificationPage()),
                                                  );
                                                },
                                              );
                                            },
                                            loading: () => const Center(
                                                child: LoadingAnimation()),
                                            error: (error, stackTrace) =>
                                                const SizedBox(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 10),
                                  child: Text('Welcome, ',
                                      style: kLargeTitleB.copyWith(
                                          color: kTextHeadColor)),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 10),
                                  child: Text(
                                    '${widget.user.name ?? ''} - (${widget.user.role?.toUpperCase() ?? ''})',
                                    style: kBodyTitleR.copyWith(
                                        color: kTextHeadColor),
                                  ),
                                ),
                                // Banner Carousel
                                if (banners.isNotEmpty)
                                  Column(
                                    children: [
                                      CarouselSlider(
                                        items: banners.map((banner) {
                                          return _buildBanners(
                                              context: context, banner: banner);
                                        }).toList(),
                                        options: CarouselOptions(
                                          height: 175,
                                          scrollPhysics: banners.length > 1
                                              ? null
                                              : const NeverScrollableScrollPhysics(),
                                          autoPlay:
                                              banners.length > 1 ? true : false,
                                          viewportFraction: 1,
                                          autoPlayInterval:
                                              const Duration(seconds: 3),
                                          onPageChanged: (index, reason) {
                                            setState(() {
                                              _currentBannerIndex = index;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                const SizedBox(height: 16),

                                // Notices Carousel
                                if (notices.isNotEmpty)
                                  Column(
                                    children: [
                                      CarouselSlider(
                                        items: notices.map((notice) {
                                          return customNotice(
                                              context: context, notice: notice);
                                        }).toList(),
                                        options: CarouselOptions(
                                          scrollPhysics: notices.length > 1
                                              ? null
                                              : const NeverScrollableScrollPhysics(),
                                          autoPlay:
                                              notices.length > 1 ? true : false,
                                          viewportFraction: 1,
                                          height:
                                              _calculateDynamicHeight(notices),
                                          autoPlayInterval:
                                              const Duration(seconds: 3),
                                          onPageChanged: (index, reason) {
                                            setState(() {
                                              _currentNoticeIndex = index;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      if (notices.length > 1)
                                        _buildDotIndicator(
                                            _currentNoticeIndex,
                                            notices.length,
                                            const Color.fromARGB(
                                                255, 39, 38, 38)),
                                    ],
                                  ),

                                if (posters.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Column(
                                      children: [
                                        CarouselSlider(
                                          items: posters
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;
                                            Promotion poster = entry.value;

                                            return KeyedSubtree(
                                              key: ValueKey(index),
                                              child: customPoster(
                                                  context: context,
                                                  poster: poster),
                                            );
                                          }).toList(),
                                          options: CarouselOptions(
                                            height: 420,
                                            scrollPhysics: posters.length > 1
                                                ? null
                                                : const NeverScrollableScrollPhysics(),
                                            autoPlay: posters.length > 1,
                                            viewportFraction: 1,
                                            autoPlayInterval:
                                                const Duration(seconds: 3),
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                _currentPosterIndex = index;
                                              });
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                                // Events Carousel
                                asyncEvents.when(
                                    data: (events) {
                                      return events.isNotEmpty
                                          ? Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 15,
                                                              top: 10),
                                                      child: Text(
                                                          'Latest Events',
                                                          style: kSubHeadingB
                                                              .copyWith(
                                                                  color:
                                                                      kTextHeadColor)),
                                                    ),
                                                  ],
                                                ),
                                                CarouselSlider(
                                                  items: events.map((event) {
                                                    return Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.95,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          navigationService
                                                              .pushNamed(
                                                                  'ViewMoreEvent',
                                                                  arguments:
                                                                      event);
                                                        },
                                                        child: eventWidget(
                                                          withImage: true,
                                                          context: context,
                                                          event: event,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  options: CarouselOptions(
                                                    height: 268,
                                                    scrollPhysics: events
                                                                .length >
                                                            1
                                                        ? null
                                                        : const NeverScrollableScrollPhysics(),
                                                    autoPlay: events.length > 1
                                                        ? true
                                                        : false,
                                                    viewportFraction: 1,
                                                    autoPlayInterval:
                                                        const Duration(
                                                            seconds: 3),
                                                    onPageChanged:
                                                        (index, reason) {
                                                      setState(() {
                                                        _currentEventIndex =
                                                            index;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                // _buildDotIndicator(_currentEventIndex,
                                                //     events.length, Colors.red),
                                              ],
                                            )
                                          : const SizedBox();
                                    },
                                    loading: () =>
                                        const Center(child: LoadingAnimation()),
                                    error: (error, stackTrace) {
                                      print(error);
                                      print(stackTrace);
                                      return const SizedBox();
                                    }),

                                const SizedBox(height: 16),

                                asyncNews.when(
                                  data: (news) {
                                    return news.isNotEmpty
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15,
                                                    top: 10,
                                                    right: 15),
                                                child: Row(
                                                  children: [
                                                    Text('Latest News',
                                                        style: kSubHeadingB
                                                            .copyWith(
                                                                color:
                                                                    kTextHeadColor)),
                                                    const Spacer(),
                                                    InkWell(
                                                      onTap: () => ref
                                                          .read(
                                                              selectedIndexProvider
                                                                  .notifier)
                                                          .updateIndex(3),
                                                      child: const Text(
                                                          'see all',
                                                          style: kSmallTitleR),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                height: 180,
                                                child: ListView.builder(
                                                  controller:
                                                      ScrollController(),
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: news.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final individualNews =
                                                        news[index];
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8.0),
                                                      child: SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                        child: newsCard(
                                                          onTap: () {
                                                            ref
                                                                .read(selectedIndexProvider
                                                                    .notifier)
                                                                .updateIndex(3);
                                                          },
                                                          imageUrl:
                                                              individualNews
                                                                      .media ??
                                                                  '',
                                                          title: individualNews
                                                                  .title ??
                                                              '',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox();
                                  },
                                  loading: () =>
                                      const Center(child: LoadingAnimation()),
                                  error: (error, stackTrace) =>
                                      const SizedBox(),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                // Videos Carousel
                                if (filteredVideos.isNotEmpty)
                                  Column(
                                    children: [
                                      CarouselSlider(
                                        items: filteredVideos.map((video) {
                                          return customVideo(
                                              context: context, video: video);
                                        }).toList(),
                                        options: CarouselOptions(
                                          height: 225,
                                          scrollPhysics: videos.length > 1
                                              ? null
                                              : const NeverScrollableScrollPhysics(),
                                          viewportFraction: 1,
                                          onPageChanged: (index, reason) {
                                            setState(() {
                                              _currentVideoIndex = index;
                                            });
                                          },
                                        ),
                                      ),
                                      if (videos.length > 1)
                                        _buildDotIndicator(
                                            _currentVideoIndex,
                                            filteredVideos.length,
                                            Colors.black),
                                    ],
                                  ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: kPrimaryColor,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    navigationService
                                        .pushNamed('MemberCreation');
                                  },
                                  child: const Icon(
                                    Icons.person_add_alt_1_outlined,
                                    color: kWhite,
                                    size: 27,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => Center(
                    child: buildShimmerPromotionsColumn(context: context)),
                error: (error, stackTrace) =>
                    const Center(child: Text('NO PROMOTIONS YET')),
              ),
            ),
          ),
        );
      },
    );
  }

  // Method to build a dot indicator for carousels
  Widget _buildDotIndicator(int currentIndex, int itemCount, Color color) {
    return Center(
      child: SmoothPageIndicator(
        controller: PageController(initialPage: currentIndex),
        count: itemCount,
        effect: WormEffect(
          dotHeight: 10,
          dotWidth: 10,
          activeDotColor: color,
          dotColor: Colors.grey,
        ),
      ),
    );
  }
}

Widget _buildBanners(
    {required BuildContext context, required Promotion banner}) {
  return Container(
    width: MediaQuery.sizeOf(context).width / 1.15,
    child: AspectRatio(
      aspectRatio: 2 / 1, // Custom aspect ratio as 2:1
      child: Stack(
        clipBehavior: Clip.none, // This allows overflow
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Image.network(
                banner.media ?? '',
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget customPoster({
  required BuildContext context,
  required Promotion poster,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10), // Apply the border radius here
      child: AspectRatio(
        aspectRatio: 19 / 20,
        child: Image.network(
          poster.media ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.grey,
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child; // Image loaded successfully
            }
            // While the image is loading, show shimmer effect
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

Widget customNotice({
  required BuildContext context,
  required Promotion notice,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(
        horizontal: 16), // Adjust spacing between posters
    child: Container(
      width: MediaQuery.of(context).size.width - 32,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryLightColor,
        boxShadow: [
          BoxShadow(
            color: kBlack.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(
                0, 5), // Horizontal (0), Vertical (5) for bottom shadow
          ),
        ],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: kPrimaryColor,
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Notice',
                    style: kSubHeadingB.copyWith(color: kTextHeadColor),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                      width: 70, // Width of the line
                      height: 1, // Thickness of the line
                      color: kPrimaryColor // Line color
                      ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    notice.title!,
                    style: kSmallTitleB.copyWith(color: kBlack),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Container(
                      width: 70, // Width of the line
                      height: 1, // Thickness of the line
                      color: kPrimaryColor // Line color
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  notice.description!,
                  style: const TextStyle(color: kGreyDark // Set the font color
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
