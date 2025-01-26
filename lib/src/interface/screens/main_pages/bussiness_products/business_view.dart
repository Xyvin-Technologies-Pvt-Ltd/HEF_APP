import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/business_model.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/notifiers/business_notifier.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/interface/components/ModalSheets/addBusinessSheet.dart';
import 'package:hef/src/interface/components/ModalSheets/business_details.dart';
import 'package:hef/src/interface/components/animations/widget_animations.dart';
import 'package:hef/src/interface/components/custom_widgets/user_tile.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shimmer/shimmer.dart';
import 'package:image_cropper/image_cropper.dart';

class BusinessView extends ConsumerStatefulWidget {
  BusinessView({super.key});

  @override
  ConsumerState<BusinessView> createState() => _BusinessViewState();
}

class _BusinessViewState extends ConsumerState<BusinessView> {
  final TextEditingController feedContentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    _fetchInitialFeed();
  }

  Future<void> _fetchInitialFeed() async {
    await ref.read(businessNotifierProvider.notifier).fetchMoreFeed();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(businessNotifierProvider.notifier).fetchMoreFeed();
    }
  }

  File? _feedImage;
  ImageSource? _feedImageSource;

  Future<File?> _pickFile() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 5),
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            activeControlsWidgetColor: kPrimaryColor,
            toolbarTitle: 'Crop Image',
            toolbarColor: kPrimaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );

      if (croppedImage != null) {
        setState(() {
          _feedImage = File(croppedImage.path);
          _feedImageSource = ImageSource.gallery;
        });
        return _feedImage;
      }
    }
    return null;
  }

  void _openModalSheet() {
    feedContentController.clear();
    _feedImage = null;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return ShowAdddBusinessSheet(
            pickImage: _pickFile,
            textController: feedContentController,
          );
        });
  }

  // String selectedFilter = 'All';

  // List<Business> filterFeeds(List<Business> feeds) {
  //   if (selectedFilter == 'All') {
  //     return feeds;
  //   } else {
  //     return feeds.where((feed) => feed.type == selectedFilter).toList();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final feeds = ref.watch(businessNotifierProvider);
    final isLoading = ref.read(businessNotifierProvider.notifier).isLoading;

    // List<Business> filteredFeeds = filterFeeds(feeds);

    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: kPrimaryColor,
      onRefresh: () =>
          ref.read(businessNotifierProvider.notifier).refreshFeed(),
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Row(
                //       children: [
                //         _buildChoiceChip('All'),
                //         _buildChoiceChip('Information'),
                //         _buildChoiceChip('Job'),
                //         _buildChoiceChip('Funding'),
                //         _buildChoiceChip('Requirement'),
                //       ],
                //     ),
                //   ),
                // ),
                // Feed list
                Expanded(
                  child: feeds.isEmpty
                      ? const Center(child: Text('No FEEDS'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: feeds.length + 2, // +2 for Ad and spacer
                          itemBuilder: (context, index) {
                            if (index == feeds.length) {
                              return isLoading
                                  ? const ReusableFeedPostSkeleton()
                                  : const SizedBox.shrink();
                            }

                            if (index == feeds.length + 1) {
                              // SizedBox to add space at the bottom
                              return const SizedBox(
                                  height: 80); // Adjust height as needed
                            }

                            final feed = feeds[index];
                            if (feed.status == 'published') {
                              return _buildPost(
                                withImage: feed.media != null &&
                                    feed.media!.isNotEmpty,
                                business: feed,
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                ),
              ],
            ),
            Positioned(
              right: 30,
              bottom: 30,
              child: GestureDetector(
                onTap: () => _openModalSheet(),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: kPrimaryColor,
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
              ),
            ),
          ],
        ),
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: () => _openModalSheet(sheet: 'post'),
        //   label: const Text(
        //     '',
        //     style: TextStyle(color: Colors.white),
        //   ),
        //   icon: const Icon(
        //     Icons.add,
        //     color: Colors.white,
        //     size: 27,
        //   ),
        //   backgroundColor: const kPrimaryColor,
        // ),
      ),
    );
  }

  // // Method to build individual Choice Chips
  // Widget _buildChoiceChip(String label) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 4.0),
  //     child: ChoiceChip(
  //       label: Text(label),
  //       selected: selectedFilter == label,
  //       onSelected: (selected) {
  //         setState(() {
  //           selectedFilter = label;
  //         });
  //       },
  //       backgroundColor: Colors.white, // Light green background color
  //       selectedColor: const Color(0xFFD3EDCA), // When selected

  //       shape: RoundedRectangleBorder(
  //         side: const BorderSide(color: Color.fromARGB(255, 214, 210, 210)),
  //         borderRadius: BorderRadius.circular(20.0), // Circular border
  //       ),
  //       showCheckmark: false, // Remove tick icon
  //     ),
  //   );
  // }

  Widget _buildPost({bool withImage = false, required Business business}) {
    return Consumer(
      builder: (context, ref, child) {
        final asynPostOwner =
            ref.watch(fetchUserDetailsProvider(business.author ?? ''));
        final asyncUser = ref.watch(userProvider);
        return asynPostOwner.when(
          data: (postOwner) {
            var receiver = Participant(
              id: business.author,
              name: postOwner.name,
              image: postOwner.image,
            );
            log('receiver:${receiver.id}\n${receiver.image}\n${receiver.name}');

            return asyncUser.when(
              data: (user) {
                var sender = Participant(
                    id: user.uid, image: user.image, name: user.name);
                log('sender:${sender.id}\n${sender.image}\n${sender.name}');

                return GestureDetector(
                  onTap: () => showBusinessModalSheet(
                      business: business,
                      buttonText: 'Message',
                      context: context,
                      onButtonPressed: () {},
                      receiver: receiver,
                      sender: sender),
                  child: ReusableBusinessPost(
                    withImage: business.media != null ? true : false,
                    business: business,
                    user: postOwner,
                  ),
                );
              },
              loading: () => const ReusableFeedPostSkeleton(),
              error: (error, stackTrace) {
                return Center(
                  child: Text('$error'),
                );
              },
            );
          },
          loading: () => const ReusableFeedPostSkeleton(),
          error: (error, stackTrace) {
            return const ReusableFeedPostSkeleton();
          },
        );
      },
    );
  }
}

class ReusableBusinessPost extends ConsumerStatefulWidget {
  final Business business;
  final bool withImage;
  final UserModel user;

  const ReusableBusinessPost({
    Key? key,
    required this.business,
    this.withImage = false,
    required this.user,
  }) : super(key: key);

  @override
  _ReusableBusinessPostState createState() => _ReusableBusinessPostState();
}

class _ReusableBusinessPostState extends ConsumerState<ReusableBusinessPost> {
  bool _isExpanded = false;
  bool _isContentOverflowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkContentOverflow();
    });
  }

  void _checkContentOverflow() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.business.content,
        style: const TextStyle(fontSize: 14),
      ),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    )..layout(
        maxWidth: MediaQuery.of(context).size.width - 64); // Padding + margins
    setState(() {
      _isContentOverflowing = textPainter.didExceedMaxLines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color.fromARGB(255, 213, 208, 208)),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: buildUserInfo(widget.user, widget.business),
          ),
          if (widget.withImage)
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: _buildPostImage(widget.business.media ?? ''),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Text(
                    widget.business.content!,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3, // Limit to 3 lines when collapsed
                    overflow: TextOverflow.ellipsis,
                  ),
                  secondChild: Text(
                    widget.business.content!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (_isContentOverflowing) const SizedBox(height: 8),
                if (_isContentOverflowing)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? 'Show less' : 'Read more',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(String imageUrl) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(10), // Ensure border radius is applied
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[200],
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit
                .cover, // Changed to BoxFit.cover for better rendering inside the border
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child; // Image fully loaded
              }
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      10), // Shimmer respects border radius
                  child: Container(
                    color: Colors.grey[300],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ReusableFeedPostSkeleton extends StatelessWidget {
  const ReusableFeedPostSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeInTransition(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      child: Card(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color.fromARGB(255, 213, 208, 208)),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // User Avatar
                  ClipOval(
                    child: _buildShimmerContainer(height: 30, width: 30),
                  ),
                  const SizedBox(width: 8),
                  // User Info (Name, Company)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerContainer(height: 12, width: 100),
                      const SizedBox(height: 4),
                      _buildShimmerContainer(height: 12, width: 60),
                    ],
                  ),
                  const Spacer(),
                  // Post Date Skeleton
                  _buildShimmerContainer(height: 12, width: 80),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 20,
              ),
              // Image Skeleton
              _buildShimmerContainer(height: 300.0, width: double.infinity),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerContainer(
      {required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildShimmerCircle({required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
