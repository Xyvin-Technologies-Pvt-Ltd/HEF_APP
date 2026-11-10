import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/chapter_api/chapter_details.dart';
import 'package:hef/src/data/api_routes/events_api/events_api.dart';
import 'package:hef/src/data/api_routes/news_api/news_api.dart';
import 'package:hef/src/data/api_routes/notification_api/notification_api.dart';
import 'package:hef/src/data/api_routes/promotion_api/promotion_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/models/notification_model.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/promotion_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/data/services/pdf_services.dart';
import 'package:hef/src/data/api_routes/analytics_api/analytics_api.dart';
import 'package:hef/src/interface/components/Drawer/drawer.dart';
import 'package:hef/src/interface/components/common/custom_video.dart';
import 'package:hef/src/interface/components/custom_widgets/custom_news.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/data/models/events_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hef/src/interface/components/shimmers/promotion_shimmers.dart';
import 'package:hef/src/interface/screens/main_pages/news_page.dart';
import 'package:hef/src/interface/screens/main_pages/notification_page.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/find_chapter_page.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/know_your_team_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:hef/src/interface/components/shimmers/dashboard_shimmer.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/analytics/analytics.dart';
import 'package:hef/src/interface/screens/main_pages/global_search_page.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int _currentVideoIndex = 0;
  int _currentEventIndex = 0;

  bool isDownloading = false;

  double _calculateDynamicHeight(List<Promotion> notices) {
    double maxHeight = 0.0;

    for (var notice in notices) {
      // Estimate height based on the length of title and description
      final double titleHeight =
          _estimateTextHeight(notice.title!, 18.0); // Font size 18 for title
      final double descriptionHeight = _estimateTextHeight(
          notice.description!, 14.0); // Font size 14 for description

      final double itemHeight =
          titleHeight + descriptionHeight - 20; // Adding padding
      if (itemHeight > maxHeight) {
        maxHeight = itemHeight + MediaQuery.sizeOf(context).width * 0.05;
      }
    }
    return maxHeight;
  }

  double _estimateTextHeight(String text, double fontSize) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final int numLines = (text.length / (screenWidth / fontSize)).ceil();
    return numLines * fontSize * 1.2 + 40;
  }

  /// Download and generate PDF from analytics data
  Future<void> downloadPDF() async {
    if (isDownloading) return;

    setState(() => isDownloading = true);
    try {
      // Get analytics data
      final downloadResponse = await AnalyticsApiService.downloadAnalytics();
      log('Home Page - API Response received: $downloadResponse');

      if (downloadResponse != null) {
        // Check the structure of the response
        final data = downloadResponse['data'];
        log('Home Page - Data section: $data');
        log('Home Page - Data type: ${data?.runtimeType}');

        if (data != null) {
          final headers = data['headers'];
          final body = data['body'];
          log('Home Page - Headers: $headers');
          log('Home Page - Headers count: ${headers?.length}');
          log('Home Page - Body count: ${body?.length}');

          if (headers != null &&
              body != null &&
              headers is List<dynamic> &&
              body is List<dynamic>) {
            // Show detailed info to user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Generating PDF with ${body.length} records...'),
                duration: Duration(seconds: 2),
              ),
            );

            await PdfService.generateAndOpenPDF(
              downloadResponse,
              title: 'Analytics Report',
              shareImmediately:
                  false, // Preview PDF instead of sharing immediately
            );

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PDF generated successfully!')),
            );
          } else {
            log('Home Page - Missing headers or body in API response');
            log('Headers type: ${headers?.runtimeType}');
            log('Body type: ${body?.runtimeType}');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Invalid data structure in API response')),
            );
          }
        } else {
          log('Home Page - No data section in API response');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('API response missing data section')),
          );
        }
      } else {
        log('Home Page - API response is null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data available for PDF generation')),
        );
      }
    } catch (e) {
      log('Home Page - Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    } finally {
      setState(() => isDownloading = false);
    }
  }

  CarouselController controller = CarouselController();
  String? startDate;
  String? endDate;
  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();
    return Consumer(
      builder: (context, ref, child) {
        final asyncPromotions = ref.watch(fetchPromotionsProvider);
        final asyncEvents = ref.watch(fetchEventsProvider);
        final asyncNews = ref.watch(fetchNewsProvider);
        final asyncUserDashBoardDetails = ref.watch(
            getUserDashboardProvider(startDate: startDate, endDate: endDate));
        return RefreshIndicator(
          color: kPrimaryColor,
          onRefresh: () async {
            ref.invalidate(fetchPromotionsProvider);
            ref.invalidate(fetchEventsProvider);
            ref.invalidate(fetchNewsProvider);
            ref.invalidate(getUserDashboardProvider);
          },
          child: AdvancedDrawer(
            drawer: customDrawer(user: widget.user, context: context),
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
              backgroundColor: kWhite,
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
                      .where((video) =>
                          video.link != null && video.link!.startsWith('http'))
                      .toList();
                  final videoCardHeight =
                      (MediaQuery.sizeOf(context).width - 32) * 9 / 16;

                  return SafeArea(
                    child: Container(
                      color: kWhite,
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 68,
                                  color: kWhite,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.asset(
                                            'assets/pngs/hef_logo_square.png',
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Consumer(
                                        builder: (context, ref, child) {
                                          final asyncNotifications = ref.watch(
                                              fetchNotificationsProvider);
                                          return asyncNotifications.when(
                                            data: (notifications) {
                                              // Filter out cleared notifications for the current user
                                              final visibleNotifications =
                                                  notifications
                                                      .where((notification) {
                                                final userNotification =
                                                    notification.users
                                                        ?.firstWhere(
                                                  (user) => user.userId == id,
                                                  orElse: () =>
                                                      UserNotification(
                                                          userId: '',
                                                          read: false,
                                                          cleared: false),
                                                );
                                                return !(userNotification
                                                        ?.cleared ??
                                                    false);
                                              }).toList();

                                              bool hasUnread =
                                                  visibleNotifications
                                                      .any((notification) {
                                                final userNotification =
                                                    notification.users
                                                        ?.firstWhere(
                                                  (user) => user.userId == id,
                                                  orElse: () =>
                                                      UserNotification(
                                                          userId: '',
                                                          read: false,
                                                          cleared: false),
                                                );
                                                return !(userNotification
                                                        ?.read ??
                                                    false);
                                              });

                                              return SizedBox(
                                                width: 44,
                                                height: 44,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xFFE9EAEC),
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      padding: EdgeInsets.zero,
                                                      icon: const Icon(
                                                        Icons
                                                            .notifications_none_outlined,
                                                        size: 21,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const NotificationPage(),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    if (hasUnread)
                                                      Positioned(
                                                        right: 10,
                                                        top: 10,
                                                        child: Container(
                                                          width: 7,
                                                          height: 7,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.red,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            },
                                            loading: () => const Center(
                                                child: Icon(
                                                    Icons.notifications_none)),
                                            error: (error, stackTrace) =>
                                                const SizedBox(),
                                          );
                                        },
                                      ),
                                      InkWell(
                                        onTap: () => _advancedDrawerController
                                            .showDrawer(),
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: const Color(0xFFE9EAEC)),
                                          ),
                                          child: const Icon(
                                            Icons.menu_rounded,
                                            color: kBlack,
                                            size: 23,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 10, 16, 16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const GlobalSearchPage(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: kWhite,
                                        border: Border.all(
                                            color: const Color(0xFFE4E6EA)),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.search_rounded,
                                              color: Colors.grey.shade600,
                                              size: 22),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Search by members, category, chapter, product...',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 4, 16, 2),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Welcome back,\n',
                                          style: TextStyle(
                                            color: Color(0xFF111820),
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            height: 1.25,
                                          ),
                                        ),
                                        TextSpan(
                                          text: widget.user.name ?? '',
                                          style: const TextStyle(
                                            color: Color(0xFF111820),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if ((widget.user.adminType ?? '')
                                            .isNotEmpty)
                                          TextSpan(
                                            text:
                                                ' - (${widget.user.adminType})',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 15,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                asyncUserDashBoardDetails.when(
                                  data: (userDashboard) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildStatCard(
                                                  'BUSINESS RECEIVED',
                                                  '${userDashboard.businessReceived}',
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _buildStatCard(
                                                  'BUSINESS GIVEN',
                                                  '${userDashboard.businessGiven}',
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildStatCard(
                                                  'REFERRALS RECEIVED',
                                                  '${userDashboard.referralReceived}',
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _buildStatCard(
                                                  'REFERRALS GIVEN',
                                                  '${userDashboard.referralGiven}',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  error: (error, stackTrace) {
                                    return const SizedBox.shrink();
                                  },
                                  loading: () {
                                    return buildDashboardShimmer();
                                  },
                                ),

                                // Banner Carousel
                                if (banners.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  CarouselSlider(
                                    items: banners.map((banner) {
                                      return _buildBanners(
                                          context: context, banner: banner);
                                    }).toList(),
                                    options: CarouselOptions(
                                      pauseAutoPlayOnTouch: true,
                                      height: 180,
                                      enlargeCenterPage: false,
                                      scrollPhysics: banners.length > 1
                                          ? null
                                          : const NeverScrollableScrollPhysics(),
                                      autoPlay:
                                          banners.length > 1 ? true : false,
                                      viewportFraction: 1,
                                      autoPlayInterval:
                                          const Duration(seconds: 5),
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          _currentBannerIndex = index;
                                        });
                                      },
                                    ),
                                  ),
                                  if (banners.length > 1)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: _buildDotIndicator(
                                        _currentBannerIndex,
                                        banners.length,
                                        kPrimaryColor,
                                      ),
                                    ),
                                ],

                                const SizedBox(height: 18),
                                _buildChapterFinder(),

                                // Events Carousel
                                asyncEvents.when(
                                  data: (events) {
                                    final activeEvents = events
                                        .where((event) =>
                                            event.status?.toLowerCase() !=
                                            'completed')
                                        .toList();

                                    if (activeEvents.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    return _buildEventsSection(
                                      events: activeEvents,
                                      onOpen: (event) {
                                        navigationService.pushNamed(
                                          'ViewMoreEvent',
                                          arguments: event,
                                        );
                                      },
                                    );
                                  },
                                  loading: () => const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(child: LoadingAnimation()),
                                  ),
                                  error: (_, __) => const SizedBox.shrink(),
                                ),

                                _buildChapterLeadership(),

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
                                          pauseAutoPlayOnTouch: true,
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
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: _buildDotIndicator(
                                            _currentNoticeIndex,
                                            notices.length,
                                            kPrimaryColor,
                                          ),
                                        ),
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
                                            final index = entry.key;
                                            final poster = entry.value;
                                            return KeyedSubtree(
                                              key: ValueKey(index),
                                              child: customPoster(
                                                context: context,
                                                poster: poster,
                                              ),
                                            );
                                          }).toList(),
                                          options: CarouselOptions(
                                            height: 420,
                                            scrollPhysics: posters.length > 1
                                                ? null
                                                : const NeverScrollableScrollPhysics(),
                                            autoPlay: posters.length > 1,
                                            pauseAutoPlayOnTouch: true,
                                            viewportFraction: 1,
                                            autoPlayInterval:
                                                const Duration(seconds: 6),
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                _currentPosterIndex = index;
                                              });
                                            },
                                          ),
                                        ),
                                        if (posters.length > 1)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: _buildDotIndicator(
                                              _currentPosterIndex,
                                              posters.length,
                                              kPrimaryColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                const SizedBox(height: 8),

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
                                                        style: kSubHeadingB.copyWith(
                                                            color: const Color(
                                                                0xFF111820))),
                                                    const Spacer(),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (_) =>
                                                                const NewsPage(),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                        'See all',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF111820),
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                height: 186,
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
                                                                .read(currentNewsIndexProvider
                                                                    .notifier)
                                                                .state = index;
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    const NewsPage(),
                                                              ),
                                                            );
                                                          },
                                                          imageUrl:
                                                              individualNews
                                                                      .media ??
                                                                  '',
                                                          createdAt:
                                                              individualNews
                                                                  .createdAt,
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
                                const SizedBox(height: 20),
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
                                          height: videoCardHeight,
                                          scrollPhysics:
                                              filteredVideos.length > 1
                                                  ? null
                                                  : const NeverScrollableScrollPhysics(),
                                          viewportFraction: 1,
                                          pauseAutoPlayOnTouch: true,
                                          onPageChanged: (index, reason) {
                                            setState(() {
                                              _currentVideoIndex = index;
                                            });
                                          },
                                        ),
                                      ),
                                      if (filteredVideos.length > 1)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: _buildDotIndicator(
                                            _currentVideoIndex,
                                            filteredVideos.length,
                                            kPrimaryColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                SizedBox(
                                  height: 28 +
                                      MediaQuery.paddingOf(context).bottom,
                                ),
                              ],
                            ),
                          ),
                          if (widget.user.isAdmin ?? false)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Material(
                                  color: kPrimaryColor,
                                  shape: const CircleBorder(),
                                  elevation: 4,
                                  shadowColor: kPrimaryColor.withOpacity(0.4),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () {
                                      navigationService
                                          .pushNamed('MemberCreation');
                                    },
                                    child: const SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: Icon(
                                        Icons.person_add_alt_1,
                                        color: kWhite,
                                        size: 26,
                                      ),
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

  Widget _buildStatCard(String title, String value) {
    final presentation = switch (title) {
      'BUSINESS RECEIVED' => (
          'Business Received',
          'assets/pngs/dashboard_business_received.png',
          const Color(0xFF12B3A8),
          true,
          'vs LM',
        ),
      'BUSINESS GIVEN' => (
          'Business Given',
          'assets/pngs/dashboard_business_given.png',
          const Color(0xFFFA6D08),
          true,
          'vs LM',
        ),
      'REFERRALS RECEIVED' => (
          'Ref. Received',
          'assets/pngs/dashboard_referral_received.png',
          const Color(0xFF8A9199),
          false,
          'All active logs',
        ),
      'REFERRALS GIVEN' => (
          'Ref. Given',
          'assets/pngs/dashboard_referral_given.png',
          const Color(0xFF8A9199),
          false,
          'Awaiting input',
        ),
      _ => (title, '', kPrimaryColor, false, ''),
    };
    final numericValue = int.tryParse(value);
    final displayValue = numericValue == null
        ? value
        : NumberFormat.decimalPattern().format(numericValue);

    return InkWell(
      onTap: () {
        String? initialTab;
        String? requestType;

        switch (title) {
          case 'BUSINESS GIVEN':
            initialTab = 'sent';
            requestType = 'Business';
            break;
          case 'BUSINESS RECEIVED':
            initialTab = 'received';
            requestType = 'Business';
            break;
          case 'REFERRALS GIVEN':
            initialTab = 'sent';
            requestType = 'Referral';
            break;
          case 'REFERRALS RECEIVED':
            initialTab = 'received';
            requestType = 'Referral';
            break;
          case 'ONE V ONE MEETINGS':
            initialTab = 'sent';
            requestType = 'One v One Meeting';
            break;
        }

        if (initialTab != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalyticsPage(
                initialTab: initialTab,
                requestType: requestType,
                startDate: startDate?.toString().split(' ')[0],
                endDate: endDate?.toString().split(' ')[0],
              ),
            ),
          );
        }
      },
      child: Container(
        height: 112,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9EAEC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    presentation.$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                presentation.$2.isEmpty
                    ? Icon(Icons.swap_horiz_rounded,
                        color: presentation.$3, size: 28)
                    : Image.asset(
                        presentation.$2,
                        width: 34,
                        height: 34,
                        fit: BoxFit.contain,
                      ),
              ],
            ),
            const Spacer(),
            Text(
              displayValue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF151D28),
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            if (presentation.$4)
              Row(
                children: [
                  Icon(Icons.arrow_drop_up, color: presentation.$3, size: 18),
                  Flexible(
                    child: Text(
                      presentation.$5,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: presentation.$3,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                presentation.$5,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: presentation.$3,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openChapterFinder() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const FindChapterPage(),
      ),
    );
  }

  Widget _buildEventsSection({
    required List<Event> events,
    required void Function(Event event) onOpen,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Latest Events',
              style: TextStyle(
                color: Color(0xFF202833),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          CarouselSlider.builder(
            itemCount: events.length,
            itemBuilder: (context, index, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _HomeEventCard(
                  event: events[index],
                  onTap: () => onOpen(events[index]),
                ),
              );
            },
            options: CarouselOptions(
              height: 286,
              viewportFraction: 1,
              enableInfiniteScroll: events.length > 1,
              autoPlay: events.length > 1,
              autoPlayInterval: const Duration(seconds: 4),
              pauseAutoPlayOnTouch: true,
              scrollPhysics: events.length > 1
                  ? null
                  : const NeverScrollableScrollPhysics(),
              onPageChanged: (index, reason) {
                setState(() => _currentEventIndex = index);
              },
            ),
          ),
          if (events.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: _buildDotIndicator(
                  _currentEventIndex,
                  events.length,
                  kPrimaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChapterFinder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _openChapterFinder,
        child: Container(
          constraints: const BoxConstraints(minHeight: 150),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF9F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4F1F1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Find A Chapter',
                          style: TextStyle(
                            color: Color(0xFF1E2937),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.info_outline,
                            color: Color(0xFF8A9AAA), size: 18),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Connect with members in your and outside of the Chapter.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.blueGrey.shade600,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _openChapterFinder,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF009E91),
                        side: const BorderSide(color: Color(0xFF8FE5E2)),
                        backgroundColor: kWhite,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 9),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text(
                        'Find a Chapter',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 66,
                height: 66,
                decoration: const BoxDecoration(
                  color: Color(0xFFD3F4F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.map_outlined,
                    color: Color(0xFF079B91), size: 34),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminInitials(String initials) {
    return Container(
      color: const Color(0xFFFFEEE2),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: kPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildChapterLeadership() {
    final chapterId = widget.user.chapter?.id;
    if (chapterId == null || chapterId.isEmpty) {
      return const SizedBox.shrink();
    }

    return ref.watch(fetchChapterDetailsProvider(chapterId)).when(
          data: (chapter) {
            if (chapter.admins.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE9EAEC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      final chapterId = widget.user.chapter?.id;
                      if (chapterId == null || chapterId.isEmpty) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => KnowYourTeamPage(chapterId: chapterId),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            'assets/pngs/hef_logo_square.png',
                            width: 22,
                            height: 22,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${widget.user.chapter?.name ?? 'HEF'} District Committee',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF202833),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Color(0xFF9AA0A6), size: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: chapter.admins.map((admin) {
                        final name = admin.user.name.trim();
                        final imageUrl = admin.user.image;
                        final initials = name.isEmpty
                            ? '?'
                            : name
                                .split(RegExp(r'\s+'))
                                .take(2)
                                .map((part) => part[0])
                                .join()
                                .toUpperCase();
                        return SizedBox(
                          width: 86,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE9EAEC),
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: imageUrl != null &&
                                            imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    _adminInitials(initials),
                                          )
                                        : _adminInitials(initials),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  name.isEmpty ? 'Member' : name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF111820),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  admin.role,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        );
  }

  Widget _buildDotIndicator(int currentIndex, int itemCount, Color color) {
    return Center(
      child: AnimatedSmoothIndicator(
        activeIndex: currentIndex,
        count: itemCount,
        effect: ExpandingDotsEffect(
          dotHeight: 7,
          dotWidth: 7,
          expansionFactor: 3.5,
          spacing: 6,
          activeDotColor: color,
          dotColor: const Color(0xFFD0D3D8),
        ),
      ),
    );
  }
}

Widget _buildBanners(
    {required BuildContext context, required Promotion banner}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        banner.media ?? '',
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 180,
              color: Colors.grey[300],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 180,
              color: Colors.grey[300],
            ),
          );
        },
      ),
    ),
  );
}

Widget customPoster({
  required BuildContext context,
  required Promotion poster,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 19 / 20,
        child: Image.network(
          poster.media ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(color: Colors.grey[300]),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(color: Colors.grey[300]),
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
  final message = notice.description?.trim().isNotEmpty == true
      ? notice.description!.trim()
      : notice.title ?? '';

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        final link = notice.link;
        final url = link == null ? null : Uri.tryParse(link);
        if (url == null || !await canLaunchUrl(url)) return;
        await launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: Container(
        width: MediaQuery.of(context).size.width - 32,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFD8C2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE9DA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.campaign_outlined,
                color: kPrimaryColor,
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notice',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFF536477),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HomeEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _HomeEventCard({
    required this.event,
    required this.onTap,
  });

  String get _statusLabel {
    final status = event.status?.toLowerCase() ?? '';
    if (status == 'pending') return 'Upcoming';
    if (status.isEmpty) return 'Event';
    return status[0].toUpperCase() + status.substring(1);
  }

  Color get _statusColor {
    switch (event.status?.toLowerCase()) {
      case 'live':
        return const Color(0xFF2D8D00);
      case 'completed':
        return const Color(0xFF6B7280);
      case 'cancelled':
        return const Color(0xFFE4483E);
      default:
        return kPrimaryColor;
    }
  }

  String get _dateText {
    final raw = event.eventDate ?? event.startDate ?? event.startTime;
    if (raw == null) return 'Date TBA';
    return DateFormat('MMM d, yyyy').format(raw.toLocal());
  }

  String get _timeText {
    final raw = event.startTime ?? event.eventDate ?? event.startDate;
    if (raw == null) return 'Time TBA';
    return DateFormat('hh:mm a').format(raw.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final venue = event.venue?.trim() ?? '';

    return Material(
      color: kWhite,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE9EAEC)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: event.image ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.grey[300]),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFFFF4EA),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.event_outlined,
                          color: kPrimaryColor,
                          size: 36,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.eventName?.trim().isNotEmpty == true
                          ? event.eventName!
                          : 'Untitled Event',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1E2937),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: kPrimaryColor),
                        const SizedBox(width: 6),
                        Text(
                          _dateText,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.access_time,
                            size: 14, color: kPrimaryColor),
                        const SizedBox(width: 6),
                        Text(
                          _timeText,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (venue.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: kPrimaryColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              venue,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
