import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:hef/src/data/api_routes/user_api/user_data/user_activities.dart';
import 'package:hef/src/interface/components/ModalSheets/bussiness_enquiry_modal.dart';
import 'package:hef/src/interface/screens/main_pages/notification_page.dart';
import 'package:hl_image_picker/hl_image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/business_model.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/notifiers/business_notifier.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/interface/components/Dialogs/upgrade_dialog.dart';
import 'package:hef/src/interface/components/DropDown/block_repor_dropDown.dart';
import 'package:hef/src/interface/components/ModalSheets/addBusinessSheet.dart';
import 'package:hef/src/interface/components/ModalSheets/business_details.dart';
import 'package:hef/src/interface/components/animations/widget_animations.dart';
import 'package:hef/src/interface/components/custom_widgets/user_tile.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shimmer/shimmer.dart';

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
    _fetchInitialUsers();
  }

  Future<void> _fetchInitialUsers() async {
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
    final _picker = HLImagePicker();

    try {
      // Open the picker to select an image
      final images = await _picker.openPicker(
        cropping: true, // Enable cropping
        pickerOptions: HLPickerOptions(
          mediaType: MediaType.image, // Ensure we are selecting images
          maxSelectedAssets: 1, // Allow selecting only one image
        ),
        cropOptions: HLCropOptions(
          aspectRatio:
              CropAspectRatio(ratioX: 4, ratioY: 5), // Set 4:5 aspect ratio
          compressQuality: 0.9, // Updated: Use a value between 0.1 and 1.0
          compressFormat: CompressFormat.jpg,
          croppingStyle: CroppingStyle.normal, // Optional, set cropping style
        ),
      );

      if (images.isNotEmpty) {
        final selectedImage = images.first;
        setState(() {
          _feedImage = File(selectedImage.path);
          _feedImageSource = ImageSource.gallery;
        });
        return _feedImage;
      }
    } catch (e) {
      debugPrint("Error picking or cropping the image: $e");
    }

    return null;
  }

  void _openModalSheet({required String sheet}) {
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

  String selectedFilter = 'All'; // Default filter is 'All'

  // Example method to filter feeds
  List<Business> filterFeeds(List<Business> feeds) {
    if (selectedFilter == 'All') {
      return feeds;
    } else {
      return feeds.where((feed) => feed.type == selectedFilter).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feeds = ref.watch(businessNotifierProvider);
    final isLoading = ref.read(businessNotifierProvider.notifier).isLoading;

    List<Business> filteredFeeds = filterFeeds(feeds);

    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: Colors.red,
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
                  child: filteredFeeds.isEmpty
                      ? const Center(child: Text('No FEEDS'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount:
                              filteredFeeds.length + 2, // +2 for Ad and spacer
                          itemBuilder: (context, index) {
                            if (index == filteredFeeds.length) {
                              return isLoading
                                  ? const ReusableFeedPostSkeleton()
                                  : const SizedBox.shrink();
                            }

                            if (index == filteredFeeds.length + 1) {
                              return const SizedBox(height: 80);
                            }

                            final feed = filteredFeeds[index];
                            if (feed.status == 'published') {
                              return _buildPost(
                                withImage: feed.media != null &&
                                    feed.media!.isNotEmpty,
                                feed: feed,
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
                onTap: () {
                  if (subscriptionType != 'free') {
                    _openModalSheet(sheet: 'post');
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => const UpgradeDialog(),
                    );
                  }
                },
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
        //   backgroundColor: const Color(0xFFE30613),
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

  Widget _buildPost({bool withImage = false, required Business feed}) {
    return Consumer(
      builder: (context, ref, child) {
        final asyncUser =
            ref.watch(fetchUserDetailsProvider(feed.author ?? ''));
        return asyncUser.when(
          data: (user) {
            var receiver = Participant(
              id: user.uid ?? '',
              name: user.name ?? '',
              image: user.image ?? '',
            );

            var sender = Participant(
              id: id,
            );
            return ReusableBusinessPost(
                author: user,
                withImage: feed.media != null ? true : false,
                business: feed,
                onLike: () async {
                  await likeFeed(feed.id!);
                  ref.read(businessNotifierProvider.notifier).refreshFeed();
                },
                onComment: () async {},
                onShare: () {
                  businessEnquiry(
                      businessAuthor: user,
                      context: context,
                      onButtonPressed: () async {},
                      buttonText: 'MESSAGE',
                      businesss: feed,
                      receiver: receiver,
                      sender: sender);
                });
          },
          loading: () => const ReusableFeedPostSkeleton(),
          error: (error, stackTrace) {
            return const Center(
              child: Text('No Posts'),
            );
          },
        );
      },
    );
  }
}

class ReusableBusinessPost extends ConsumerStatefulWidget {
  final Business business;
  final bool withImage;
  final UserModel author;
  final Function onLike;
  final Function onComment;
  final Function onShare;

  const ReusableBusinessPost({
    super.key,
    required this.business,
    this.withImage = false,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.author,
  });

  @override
  _ReusableBusinessPostState createState() => _ReusableBusinessPostState();
}

class _ReusableBusinessPostState extends ConsumerState<ReusableBusinessPost>
    with SingleTickerProviderStateMixin {
  FocusNode commentFocusNode = FocusNode();
  bool isLiked = false;
  bool showHeartAnimation = false;
  late AnimationController _animationController;
  TextEditingController commentController = TextEditingController();
  int likes = 0;
  @override
  void initState() {
    super.initState();

    initialize();
  }

  initialize() async {
    if (widget.business.likes != null) {
      if (widget.business.likes!.contains(id)) {
        isLiked = true;
      }
    }
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _toggleLike() {
    setState(() {
      likes = isLiked == true ? likes - 1 : likes + 1;
      isLiked = !isLiked;
      showHeartAnimation = true;
      widget.onLike();
    });
    _animationController.forward().then((_) {
      _animationController.reset();
      setState(() {
        showHeartAnimation = false;
      });
    });
  }

  void _openCommentModal() {
    log('comments: ${widget.business.comments?.length}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20.0),
                bottom: Radius.circular(20.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: const Text('Comments'),
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.0),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.business.comments?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Consumer(
                            builder: (context, ref, child) {
                              return ListTile(
                                leading: ClipOval(
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    child: widget.business.comments?[index].user
                                                ?.image !=
                                            null
                                        ? Image.network(
                                            fit: BoxFit.fill,
                                            widget.business.comments![index]
                                                .user!.image!)
                                        : const Icon(Icons.person),
                                  ),
                                ),
                                title: Text(
                                    widget.business.comments![index].user !=
                                            null
                                        ? widget.business.comments![index].user!
                                                .name ??
                                            'Unknown User'
                                        : 'Unknown User'),
                                subtitle: Text(
                                    widget.business.comments?[index].comment ??
                                        ''),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    _buildCommentInputField(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: commentFocusNode,
              controller: commentController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                hintText: "Add a comment...",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Text(
                'Post',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                if (commentController.text != '') {
                  FocusScope.of(context)
                      .unfocus(); // Ensure the keyboard is dismissed immediately

                  await postComment(
                      feedId: widget.business.id!,
                      comment: commentController.text);
                  await ref
                      .read(businessNotifierProvider.notifier)
                      .refreshFeed();
                  commentController.clear();
                  commentFocusNode.unfocus();
                }
              })
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    commentFocusNode.dispose();
    super.dispose();
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
            child: buildUserInfo(widget.author, widget.business, context),
          ),
          if (widget.withImage)
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: _buildPostImage(widget.business.media!),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(widget.business.content!,
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                _buildActionButtons(),
                GestureDetector(
                  onTap: () => _openCommentModal(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                    child: Text(
                      'View all ${widget.business.comments?.length ?? 0} comments',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 14.5),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 30,
                          height: 30,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          child: Image.network(
                            widget.author.image ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                  'assets/icons/dummy_person_small.png');
                            },
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openCommentModal(),
                        child: const Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            'Add a comment...',
                            style: TextStyle(
                                color: Color.fromARGB(255, 129, 128, 128)),
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _openCommentModal(),
                        child: const Row(
                          children: [
                            Text(
                              '❤️',
                              style: TextStyle(color: Colors.red),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('🙌'),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.add_circle_outline_sharp,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Text(
                    '${timeAgo(widget.business.createdAt!)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(String imageUrl) {
    return GestureDetector(
      onDoubleTap: _toggleLike,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
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
          ),
          if (showHeartAnimation)
            Icon(Icons.favorite, color: Colors.red.withOpacity(0.8), size: 100)
                .animate(target: showHeartAnimation ? 1 : 0)
                .scaleXY(begin: 0.7, end: 1.2)
                .then()
                .scaleXY(begin: 1.2, end: 0.9),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.black,
                  ),
                  onPressed: _toggleLike,
                ),
                IconButton(
                  icon: SvgPicture.asset('assets/svg/icons/comment.svg'),
                  onPressed: _openCommentModal,
                ),
                if (widget.business.author != id)
                  IconButton(
                    icon: SvgPicture.asset('assets/svg/icons/share.svg'),
                    onPressed: () => widget.onShare(),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                '${widget.business.likes?.length ?? 0} Likes',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const Spacer(),
        if (widget.business.author != id)
          BlockReportDropdown(
            isBlocked: false,
            feed: widget.business,
          )
      ],
    );
  }
}

class ReusableFeedPostSkeleton extends StatelessWidget {
  const ReusableFeedPostSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
            // Image Skeleton
            _buildShimmerContainer(height: 200.0, width: double.infinity),
            const SizedBox(height: 16),
            // Content Text Skeleton
            _buildShimmerContainer(height: 14, width: double.infinity),
            const SizedBox(height: 16),
            // User Info Skeleton
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
            // Action Buttons Skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildShimmerCircle(height: 30, width: 30),
                    const SizedBox(width: 8),
                    _buildShimmerCircle(height: 30, width: 30),
                    const SizedBox(width: 8),
                    _buildShimmerCircle(height: 30, width: 30),
                  ],
                ),
                // Likes Count Skeleton
                _buildShimmerContainer(height: 14, width: 60),
              ],
            ),
          ],
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
