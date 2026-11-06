import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:hef/src/data/api_routes/business_api/business_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_activities.dart';
import 'package:hef/src/interface/components/ModalSheets/bussiness_enquiry_modal.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/components/textWidgets/expandable_text.dart';
import 'package:hef/src/interface/screens/main_pages/notification_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/business_model.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/notifiers/business_notifier.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/interface/components/Dialogs/upgrade_dialog.dart';
import 'package:hef/src/interface/components/DropDown/block_repor_dropDown.dart';
import 'package:hef/src/interface/components/ModalSheets/addBusinessSheet.dart';
import 'package:hef/src/interface/components/common/community_chrome.dart';
import 'package:intl/intl.dart';
import 'package:hef/src/data/services/image_upload.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:shimmer/shimmer.dart';

class BusinessView extends ConsumerStatefulWidget {
  const BusinessView({super.key});

  @override
  ConsumerState<BusinessView> createState() => _BusinessViewState();
}

class _BusinessViewState extends ConsumerState<BusinessView> {
  final TextEditingController feedContentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _query = '';
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

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    feedContentController.dispose();
    super.dispose();
  }

  File? _feedImage;
  ImageSource? _feedImageSource;

  Future<File?> _pickFile() async {
    final result = await pickMedia(
      context: context,
      enableCrop: true,
      showDocument: false,
      cropRatio: CropAspectRatio(
          ratioX: 4,
          ratioY:
              5), // Align with previous AspectRatio 4/5 if possible, but 4/5 = 0.8
    );

    if (result != null && result is XFile) {
      final File imageFile = File(result.path);
      setState(() {
        _feedImage = imageFile;
        _feedImageSource =
            ImageSource.gallery; // Assumption as pickMedia handles source
      });
      return _feedImage;
    }
    return null;
  }

  void _openModalSheet({required String sheet}) {
    feedContentController.clear();
    _feedImage = null;
    showModalBottomSheet(
        isScrollControlled: true,
        // Pad manually in the sheet — modal MediaQuery often reports 0.
        useSafeArea: false,
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
    final typed = selectedFilter == 'All'
        ? feeds
        : feeds.where((feed) => feed.type == selectedFilter).toList();
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return typed;
    return typed
        .where((feed) => (feed.content ?? '').toLowerCase().contains(query))
        .toList();
  }

  void _showFeedFilter() {
    const options = ['All', 'Information', 'Job', 'Funding', 'Requirement'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              for (final option in options)
                ListTile(
                  title: Text(option),
                  trailing: selectedFilter == option
                      ? const Icon(Icons.check, color: kCommunityOrange)
                      : null,
                  onTap: () {
                    setState(() => selectedFilter = option);
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final feeds = ref.watch(businessNotifierProvider);
    final isLoading = ref.read(businessNotifierProvider.notifier).isLoading;
    final isFirstLoad = ref.read(businessNotifierProvider.notifier).isFirstLoad;
    List<Business> filteredFeeds = filterFeeds(feeds);

    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: kCommunityOrange,
      onRefresh: () =>
          ref.read(businessNotifierProvider.notifier).refreshFeed(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 8),
                CommunitySearchRow(
                  controller: _searchController,
                  hint: 'Search by Name, city, state...',
                  filterActive: selectedFilter != 'All',
                  onFilter: _showFeedFilter,
                  onChanged: (value) => setState(() => _query = value),
                  onSubmitted: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 8),
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
                  child: isFirstLoad
                      ? Center(
                          child: LoadingAnimation(),
                        )
                      : filteredFeeds.isEmpty
                          ? const Center(child: Text('No FEEDS'))
                          : ListView.builder(
                              controller: _scrollController,
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              itemCount: filteredFeeds.length +
                                  2, // +2 for Ad and spacer
                              itemBuilder: (context, index) {
                                if (index == filteredFeeds.length) {
                                  return isLoading
                                      ? const ReusableFeedPostSkeleton()
                                      : const SizedBox.shrink();
                                }

                                if (index == filteredFeeds.length + 1) {
                                  return const SizedBox(height: 120);
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
              right: 16,
              bottom: 96,
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
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kCommunityOrange,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
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

  void _showDeleteDialog(String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.question_mark_rounded,
                size: 70,
              ),
              SizedBox(height: 20),
              Text(
                'Delete Post?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                'Are you sure?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child:
                        Text('No', style: TextStyle(color: Color(0xFF0E1877))),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      return TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Color(0xFFEB5757)),
                        onPressed: () async {
                          await BusinessApiService.deletePost(postId, context);
                          ref
                              .read(businessNotifierProvider.notifier)
                              .refreshFeed();
                          Navigator.of(context).pop();
                        },
                        child: Text('Yes, Delete',
                            style: TextStyle(color: Colors.white)),
                      );
                    },
                  ),
                ],
              ),
            ],
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

  Future<void> _submitComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty || widget.business.id == null) return;
    FocusScope.of(context).unfocus();
    await postComment(feedId: widget.business.id!, comment: text);
    await ref.read(businessNotifierProvider.notifier).refreshFeed();
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final company = (widget.author.company != null &&
            widget.author.company!.isNotEmpty)
        ? widget.author.company!.first.name?.trim()
        : null;
    final created = widget.business.createdAt?.toLocal();
    final stamp = created == null
        ? ''
        : DateFormat('h:mm a · MMM d, yyyy').format(created);
    final me = ref.watch(userProvider).asData?.value;
    final commentCount = widget.business.comments?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEEEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: Image.network(
                      widget.author.image ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => SvgPicture.asset(
                        'assets/svg/icons/dummy_person_small.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.author.name ?? 'Unknown User',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kCommunityText,
                        ),
                      ),
                      if (company != null && company.isNotEmpty)
                        Text(
                          company.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                            color: kCommunityMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (stamp.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      stamp,
                      style: const TextStyle(
                        fontSize: 11,
                        color: kCommunityMuted,
                      ),
                    ),
                  ),
                if (widget.business.author == id)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.more_vert, size: 20),
                    color: const Color(0xFF6B7280),
                    onPressed: () => _showDeleteDialog(widget.business.id!),
                  )
                else
                  const SizedBox(width: 4),
                if (widget.business.author != id)
                  BlockReportDropdown(
                    isBlocked: false,
                    feed: widget.business,
                  ),
              ],
            ),
            if (widget.withImage && (widget.business.media ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 4),
                child: _buildPostImage(widget.business.media!),
              ),
            if ((widget.business.content ?? '').trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 4),
                child: ExpandableText(
                  text: widget.business.content ?? '',
                  readMoreColor: kCommunityOrange,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 4),
              child: Row(
                children: [
                  InkWell(
                    onTap: _openCommentModal,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 20,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$commentCount',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.business.author != id) ...[
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => widget.onShare(),
                      child: const Icon(
                        Icons.send_outlined,
                        size: 20,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                  const Spacer(),
                  InkWell(
                    onTap: _toggleLike,
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isLiked ? Colors.red : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('👏', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _openCommentModal,
                    child: const Icon(
                      Icons.add,
                      size: 20,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 4),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Image.network(
                        me?.image ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => SvgPicture.asset(
                          'assets/svg/icons/dummy_person_small.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      onSubmitted: (_) => _submitComment(),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Add a comment...',
                        hintStyle: const TextStyle(
                          color: Color(0xFFB0B6BE),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.business.createdAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 2),
                child: Text(
                  timeAgo(widget.business.createdAt!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: kCommunityMuted,
                  ),
                ),
              ),
          ],
        ),
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
            aspectRatio: 16 / 9,
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
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: showHeartAnimation ? 1.0 : 0.0,
              child: Icon(
                Icons.favorite,
                color: Colors.red.withOpacity(0.8),
                size: 100,
              ),
            ),
        ],
      ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                _buildShimmerContainer(height: 12, width: 100),
                const SizedBox(height: 15),
              ],
            ),
            // Image Skeleton
            _buildShimmerContainer(height: 400.0, width: double.infinity),
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
