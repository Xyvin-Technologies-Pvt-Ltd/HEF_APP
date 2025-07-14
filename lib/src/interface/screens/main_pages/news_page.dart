import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/news_api/news_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/news_model.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shimmer/shimmer.dart';

final currentNewsIndexProvider = StateProvider<int>((ref) => 0);

class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNews = ref.watch(fetchNewsProvider);

    return Scaffold(
        backgroundColor: kScaffoldColor,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "News",
            style: TextStyle(fontSize: 17),
          ),
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
        ),
        body: asyncNews.when(
          data: (news) {
            return news.isNotEmpty
                ? NewsPageView(news: news)
                : Center(
                    child: Text('Not News'),
                  );
          },
          loading: () => const Center(child: LoadingAnimation()),
          error: (error, stackTrace) => const Center(child: Text('No news')),
        ));
  }
}

class NewsPageView extends ConsumerStatefulWidget {
  final List<News> news;

  const NewsPageView({Key? key, required this.news}) : super(key: key);

  @override
  _NewsPageViewState createState() => _NewsPageViewState();
}

class _NewsPageViewState extends ConsumerState<NewsPageView> {
  late final PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(currentNewsIndexProvider),
    );

    // Adding listener to update current page value for transitions
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to index changes in the provider and update PageController
    ref.listen<int>(currentNewsIndexProvider, (_, nextIndex) {
      _pageController.jumpToPage(nextIndex);
    });

    return Stack(
      children: [
        Column(
          children: [
            // PageView Section
            Expanded(
                child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.news.length,
                    onPageChanged: (index) {
                      ref.read(currentNewsIndexProvider.notifier).state = index;
                    },
                    itemBuilder: (context, index) {
                      return ClipRect(
                        child: NewsContent(
                          key: PageStorageKey<int>(
                              index), // Unique key for the page
                          newsItem: widget.news[index],
                        ),
                      );
                    })),
            // Navigation Buttons Section

            Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, bottom: 10, top: 10),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: (1 - (_currentPage - _currentPage.round()).abs())
                    .clamp(0.0, 1.0), // Smooth transition for buttons too
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color.fromARGB(255, 224, 219, 219)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                      ),
                      onPressed: () {
                        int currentIndex = ref.read(currentNewsIndexProvider);
                        if (currentIndex > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      // Button styling remains unchanged
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back, color: kPrimaryColor),
                          SizedBox(width: 8),
                          Text('Previous',
                              style: TextStyle(color: kPrimaryColor)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color.fromARGB(255, 224, 219, 219)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                      ),
                      onPressed: () {
                        int currentIndex = ref.read(currentNewsIndexProvider);
                        if (currentIndex < widget.news.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      // Button styling remains unchanged
                      child: const Row(
                        children: [
                          Text('Next', style: TextStyle(color: kPrimaryColor)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: kPrimaryColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Widget for displaying individual news contentimport 'package:flutter/material.dart';

class NewsContent extends StatelessWidget {
  final News newsItem;

  const NewsContent({
    Key? key,
    required this.newsItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('MMM dd, yyyy, hh:mm a').format(newsItem.updatedAt!);
    final minsToRead = calculateReadingTimeAndWordCount(newsItem.content ?? '');

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'news_image_${newsItem.updatedAt}',
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    newsItem.media ?? '',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return ShimmerLoadingEffect(
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return ShimmerLoadingEffect(
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: const Color.fromARGB(255, 192, 252, 194),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 10,
                        ),
                        child: Text(
                          newsItem.category ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (newsItem.pdf != null)
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final pdfUrl = newsItem.pdf;
                            if (pdfUrl == null || pdfUrl.isEmpty) {
                              print('PDF URL is null or empty');
                              return;
                            }

                            try {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(
                                      title: const Text(
                                        "Back",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      backgroundColor: Colors.white,
                                      scrolledUnderElevation: 0,
                                      leading: IconButton(
                                        icon: const Icon(Icons.arrow_back),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                    body: SfPdfViewer.network(pdfUrl),
                                  ),
                                ),
                              );
                            } catch (e) {
                              print('Error loading PDF: $e');
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: kPrimaryColor),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View PDF',
                                    style: TextStyle(color: kPrimaryColor),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.remove_red_eye_outlined,
                                      color: kPrimaryColor)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 15),
                    Text(
                      newsItem.title ?? '',
                      style: kHeadTitleB.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          minsToRead,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      newsItem.content ?? '',
                      strutStyle: const StrutStyle(height: 1.5),
                      style: kBodyTitleR.copyWith(
                        fontSize: 16,
                        color: const Color(0xFF4F4F4F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom Shimmer Loading Effect

String calculateReadingTimeAndWordCount(String text) {
  // Count the number of words by splitting the string on whitespace
  List<String> words = text.trim().split(RegExp(r'\s+'));
  int wordCount = words.length;

  // Average reading speed in words per minute (WPM)
  const int averageWPM = 250;

  double readingTimeMinutes = wordCount / averageWPM;

  int minutes = readingTimeMinutes.floor();
  int seconds = ((readingTimeMinutes - minutes) * 60).round();

  String formattedTime;
  if (minutes > 0) {
    formattedTime = '$minutes min ${seconds > 0 ? '$seconds sec' : ''}';
  } else {
    formattedTime = '$seconds sec';
  }

  return '$formattedTime read';
}

class ShimmerLoadingEffect extends StatelessWidget {
  final Widget child;

  const ShimmerLoadingEffect({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }
}
