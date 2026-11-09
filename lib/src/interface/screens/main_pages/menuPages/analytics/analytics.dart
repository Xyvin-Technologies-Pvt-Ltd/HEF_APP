import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/analytics_api/analytics_api.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/api_routes/notification_api/notification_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/analytics_model.dart';
import 'package:hef/src/data/models/notification_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/notifiers/analytics_notifier.dart';
import 'package:hef/src/data/services/analytics_pdf_service.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/Drawer/drawer.dart';
import 'package:hef/src/interface/components/common/community_chrome.dart';
import 'package:hef/src/interface/screens/main_pages/notification_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hef/src/interface/components/ModalSheets/analytics.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  final String? initialTab;
  final String? requestType;
  final String? startDate;
  final String? endDate;

  const AnalyticsPage({
    super.key,
    this.initialTab,
    this.requestType,
    this.startDate,
    this.endDate,
  });

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocus = FocusNode();
  Timer? _debounce;
  Timer? _autoRefreshTimer;
  int _previousTabIndex = 0;

  late TabController _tabController;
  final AdvancedDrawerController _drawerController = AdvancedDrawerController();

  bool get _isMeetings => widget.requestType == 'One v One Meeting';
  int _receivedTotal = 0;
  int _sentTotal = 0;
  double? _receivedChange;
  double? _sentChange;

  // Add filter state variables
  DateTime? startDate;
  DateTime? endDate;
  String? selectedRequestType;
  final List<String> requestTypes = [
    'Business',
    'One v One Meeting',
    'Referral'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _tabController = TabController(length: 3, vsync: this);

    if (_isMeetings) {
      _previousTabIndex = widget.initialTab == 'received'
          ? 1
          : widget.initialTab == 'history'
              ? 2
              : 0;
      _tabController.animateTo(_previousTabIndex);
    } else if (widget.initialTab != null) {
      _previousTabIndex = widget.initialTab == 'sent'
          ? 1
          : widget.initialTab == 'received'
              ? 0
              : 2;
      _tabController.animateTo(_previousTabIndex);
    }

    // Set initial filters if provided
    if (widget.requestType != null) {
      selectedRequestType = widget.requestType;
    }
    if (widget.startDate != null) {
      startDate = DateTime.parse(widget.startDate!);
    }
    if (widget.endDate != null) {
      endDate = DateTime.parse(widget.endDate!);
    }

    // Fetch initial analytics after widget tree is built
    Future(() {
      _fetchInitialAnalytics();
      if (_isMeetings) _loadMeetingStats();
    });
  }

  Future<void> _loadMeetingStats() async {
    try {
      final results = await Future.wait([
        AnalyticsApiService.fetchAnalytics(
          type: 'received',
          requestType: widget.requestType,
          pageNo: 1,
          limit: 200,
        ),
        AnalyticsApiService.fetchAnalytics(
          type: 'sent',
          requestType: widget.requestType,
          pageNo: 1,
          limit: 200,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _receivedTotal = results[0].length;
        _sentTotal = results[1].length;
        _receivedChange = _monthChange(results[0]);
        _sentChange = _monthChange(results[1]);
      });
    } catch (error, stackTrace) {
      log('Meeting stats failed: $error', stackTrace: stackTrace);
    }
  }

  double? _monthChange(List<AnalyticsModel> items) {
    final now = DateTime.now();
    final previous = DateTime(now.year, now.month - 1, 1);
    final currentCount =
        items.where((item) => _sameMonth(item.date, now)).length;
    final previousCount =
        items.where((item) => _sameMonth(item.date, previous)).length;
    if (previousCount == 0) return currentCount == 0 ? 0 : null;
    return (currentCount - previousCount) / previousCount * 100;
  }

  bool _sameMonth(DateTime? date, DateTime month) {
    if (date == null) return false;
    final local = date.toLocal();
    return local.year == month.year && local.month == month.month;
  }

  Future<void> _fetchInitialAnalytics() async {
    // Determine the initial tab type based on previousTabIndex
    // Default to index 0 (Received) if initialTab is null
    String? initialType = _getTabTypeFor(_previousTabIndex);

    ref.read(analyticsNotifierProvider.notifier).searchAnalytics(
          newType: initialType,
          newStartDate: startDate != null
              ? DateFormat('yyyy-MM-dd').format(startDate!)
              : null,
          newEndDate: endDate != null
              ? DateFormat('yyyy-MM-dd').format(endDate!)
              : null,
          newRequestType: selectedRequestType,
          query: _searchController.text,
        );
  }

  String? _getTabTypeFor(int index) {
    if (_isMeetings) {
      switch (index) {
        case 0:
          return 'sent';
        case 1:
          return 'received';
        case 2:
          return null;
        default:
          return 'sent';
      }
    }
    switch (index) {
      case 0:
        return 'received';
      case 1:
        return 'sent';
      case 2:
        return null; // History (all data)
      default:
        return 'received';
    }
  }

  void _selectTab(int index) {
    if (_previousTabIndex == index) return;
    _previousTabIndex = index;
    _tabController.animateTo(index);
    ref.read(analyticsNotifierProvider.notifier).searchAnalytics(
          newType: _getTabTypeFor(index),
          newStartDate: startDate != null
              ? DateFormat('yyyy-MM-dd').format(startDate!)
              : null,
          newEndDate:
              endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : null,
          newRequestType: selectedRequestType,
          query: _searchController.text,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(analyticsNotifierProvider.notifier).fetchMoreAnalytics();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
    setState(() {});
  }

  void _onSearchSubmitted(String query) {
    _performSearch(query);
  }

  void _performSearch(String query) {
    final currentTabType = _getCurrentTabType();
    ref.read(analyticsNotifierProvider.notifier).searchAnalytics(
          newType: currentTabType,
          newStartDate: startDate != null
              ? DateFormat('yyyy-MM-dd').format(startDate!)
              : null,
          newEndDate: endDate != null
              ? DateFormat('yyyy-MM-dd').format(endDate!)
              : null,
          newRequestType: selectedRequestType,
          query: query,
        );
  }

  String? _getCurrentTabType() {
    return _getTabTypeFor(_tabController.index);
  }

  // Add filter modal sheet
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag indicator
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Date Range Section
                  Text('Date Range', style: kBodyTitleB),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => startDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: kGrey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              startDate != null
                                  ? DateFormat('MMM d, yyyy').format(startDate!)
                                  : 'Start Date',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => endDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: kGrey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              endDate != null
                                  ? DateFormat('MMM d, yyyy').format(endDate!)
                                  : 'End Date',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Request Type Section
                  Text('Request Type', style: kBodyTitleB),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: kGrey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedRequestType,
                      isExpanded: true,
                      hint: const Text('Select Request Type'),
                      underline: Container(),
                      items: requestTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() => selectedRequestType = value);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              startDate = null;
                              endDate = null;
                              selectedRequestType = null;
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: kWhite,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            // Update filters and refresh
                            ref
                                .read(analyticsNotifierProvider.notifier)
                                .updateFilters(
                                  newType: _getCurrentTabType(),
                                  newStartDate: startDate != null
                                      ? DateFormat('yyyy-MM-dd')
                                          .format(startDate!)
                                      : null,
                                  newEndDate: endDate != null
                                      ? DateFormat('yyyy-MM-dd')
                                          .format(endDate!)
                                      : null,
                                  newRequestType: selectedRequestType,
                                );
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReusableModalSheet(
      AnalyticsModel analytic, String tabBarType, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AnalyticsModalSheet(
          analytic: analytic,
          tabBarType: tabBarType,
        );
      },
    );
  }

  Future<void> _downloadPdf() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Request storage permission for Android
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }

      // Fetch all analytics data from API for PDF
      final analyticsData = await ref.read(
        fetchAnalyticsProvider(
          type: _getCurrentTabType(),
          startDate: startDate != null
              ? DateFormat('yyyy-MM-dd').format(startDate!)
              : null,
          endDate: endDate != null
              ? DateFormat('yyyy-MM-dd').format(endDate!)
              : null,
          requestType: selectedRequestType,
          pageNo: 1,
          limit: 10000,
        ).future,
      );
      String reportType;

      switch (_tabController.index) {
        case 0: // Received
          reportType = 'received';
          break;
        case 1: // Sent
          reportType = 'sent';
          break;
        case 2: // History
          reportType = 'history';
          break;
        default:
          reportType = 'all';
      }

      // Generate PDF
      final file = await AnalyticsPdfService.generateAnalyticsPdf(
        analyticsData: analyticsData,
        reportType: reportType,
        startDate: startDate != null
            ? DateFormat('yyyy-MM-dd').format(startDate!)
            : null,
        endDate:
            endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : null,
        requestType: selectedRequestType,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF downloaded successfully!'),
            backgroundColor: kGreen,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () {
                AnalyticsPdfService.openPdfFile(file);
              },
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: kRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _drawerController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsNotifierProvider);
    final notifier = ref.read(analyticsNotifierProvider.notifier);
    final isFirstLoad = notifier.isFirstLoad;

    if (_isMeetings) return _buildMeetingsScaffold(analytics, isFirstLoad);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 1),
                blurRadius: 1,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: const Text(
              "Analytics",
              style: kSmallTitleM,
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterModal,
                  ),
                  if (startDate != null ||
                      endDate != null ||
                      selectedRequestType != null)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 8,
                          minHeight: 8,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: _downloadPdf,
              ),
            ],
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Material(
            color: kWhite,
            elevation: 0.0,
            child: TabBar(
              controller: _tabController,
              indicatorWeight: 3,
              dividerColor: kWhite,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.orange,
              onTap: _selectTab,
              tabs: const [
                Tab(text: "Received"),
                Tab(text: "Sent"),
                Tab(text: "History"),
              ],
            ),
          ),
          //search bar
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search Analytics',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 216, 211, 211),
                            ),
                          ),
                        ),
                        onChanged: _onSearchChanged,
                        onSubmitted: _onSearchSubmitted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: isFirstLoad
                ? const Center(child: LoadingAnimation())
                : analytics.isNotEmpty
                    ? _buildAnalyticsList(analytics)
                    : const Center(child: Text("No data available")),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigationService navigationService = NavigationService();
          //received tab
          bool isReceivedValue = _tabController.index == 0;

          // Log the navigation details
          log('AnalyticsPage - Current tab index: ${_tabController.index}',
              name: 'Analytics Navigation');
          log('AnalyticsPage - isReceivedValue: $isReceivedValue',
              name: 'Analytics Navigation');
          log(
              'AnalyticsPage - Tab name: ${_tabController.index == 0 ? "Received" : _tabController.index == 1 ? "Sent" : "History"}',
              name: 'Analytics Navigation');

          navigationService.pushNamed('SendAnalyticRequest',
              arguments: {'isReceived': isReceivedValue});
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(
          Icons.add,
          color: kWhite,
        ),
      ),
    );
  }

  Widget _buildAnalyticsList(List<AnalyticsModel> analytics) {
    // Search filter (client-side) — preserves API response order, no sorting
    final searchQuery = _searchController.text.trim().toLowerCase();
    final List<AnalyticsModel> filtered = searchQuery.isEmpty
        ? analytics
        : analytics.where((analytic) {
            final username = analytic.username?.toLowerCase() ?? '';
            final title = analytic.title?.toLowerCase() ?? '';
            return username.contains(searchQuery) || title.contains(searchQuery);
          }).toList();

    final notifier = ref.read(analyticsNotifierProvider.notifier);
    final isLoading = notifier.isLoading;
    final hasMore = notifier.hasMore;

    return RefreshIndicator(
      backgroundColor: kWhite,
      color: kPrimaryColor,
      onRefresh: () async {
        ref.read(analyticsNotifierProvider.notifier).refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, _isMeetings ? 4 : 16, 16, _isMeetings ? 120 : 16),
        itemCount: filtered.length + (isLoading && hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filtered.length) {
            return const Center(child: LoadingAnimation());
          }
          final analytic = filtered[index];
          return _buildCard(analytic, _getCurrentTabType() ?? 'history');
        },
      ),
    );
  }

  Widget _buildCard(AnalyticsModel analytic, String tabBarType) {
    if (_isMeetings) return _meetingCard(analytic, tabBarType);
    log(analytic.userImage ?? '', name: 'User image of analytic');
    return InkWell(
      onTap: () => _showReusableModalSheet(analytic, tabBarType, context),
      child: Container(
        decoration: BoxDecoration(
            color: kWhite,
            border: Border.all(
              color: kGrey,
            ),
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24.0,
                          backgroundImage: NetworkImage(
                            analytic.userImage ?? '',
                          ),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: Text(
                            maxLines: 2,
                            analytic.username ?? '',
                            style: const TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        if (analytic.date != null)
                          Row(
                            children: [
                              Text(
                                maxLines: 2,
                                '${DateFormat("MMM d yyyy ").format(analytic.date!.toLocal())}',
                                style: const TextStyle(
                                    fontSize: 10.0, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (analytic.time != null)
                                Text(
                                  '${analytic.time}',
                                  style: const TextStyle(
                                      fontSize: 10.0, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                )
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    const SizedBox(height: 12.0),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            maxLines: 3,
                            analytic.title ?? '',
                            style: kBodyTitleB,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10),
                        if (analytic.amount != null)
                          Expanded(
                            child: Text(
                              "₹${analytic.amount}",
                              style: kBodyTitleB,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              analytic.status ?? '',
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              analytic.status ?? '',
                              style: const TextStyle(
                                color: kWhite,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Color _getStatusColor(String status) {
    switch (status) {
      case "accepted":
        return kGreen;
      case "completed":
        return kGreen;
      case "rejected":
        return kRed;
      case "meeting_scheduled":
        return const Color(0xFF2B74E1);
      default:
        return Colors.grey;
    }
  }

  Widget _buildMeetingsScaffold(List<AnalyticsModel> analytics, bool isFirstLoad) {
    final user = ref.watch(userProvider).value ?? UserModel();
    return AdvancedDrawer(
      drawer: customDrawer(user: user, context: context),
      backdrop: const ColoredBox(color: kWhite),
      controller: _drawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 78),
          child: FloatingActionButton(
            onPressed: () {
              NavigationService().pushNamed(
                'SendAnalyticRequest',
                arguments: {'isReceived': false},
              );
            },
            backgroundColor: const Color(0xFFFF6A00),
            elevation: 6,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: kWhite, size: 30),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _meetingsHeader(),
              Expanded(child: _meetingsBody(analytics, isFirstLoad)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meetingsBody(List<AnalyticsModel> analytics, bool isFirstLoad) {
    final searchQuery = _searchController.text.trim().toLowerCase();
    final filtered = searchQuery.isEmpty
        ? analytics
        : analytics.where((analytic) {
            final username = analytic.username?.toLowerCase() ?? '';
            final title = analytic.title?.toLowerCase() ?? '';
            final description = analytic.description?.toLowerCase() ?? '';
            final location = analytic.location?.toLowerCase() ?? '';
            return username.contains(searchQuery) ||
                title.contains(searchQuery) ||
                description.contains(searchQuery) ||
                location.contains(searchQuery);
          }).toList();
    final tabType = _getCurrentTabType() ?? 'sent';
    final notifier = ref.read(analyticsNotifierProvider.notifier);

    return RefreshIndicator(
      backgroundColor: kWhite,
      color: kPrimaryColor,
      onRefresh: () async {
        await ref.read(analyticsNotifierProvider.notifier).refresh();
        await _loadMeetingStats();
      },
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 110),
        children: [
          _meetingsHero(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _statCard(
                    label: 'Received',
                    value: _receivedTotal,
                    change: _receivedChange,
                    changeColor: const Color(0xFFFF6D00),
                    icon: Icons.work_outline,
                    iconColor: const Color(0xFFFF6D00),
                    iconBackground: const Color(0xFFFFF1E6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    label: 'Sent',
                    value: _sentTotal,
                    change: _sentChange,
                    changeColor: const Color(0xFF5C7CFA),
                    icon: Icons.handshake_outlined,
                    iconColor: const Color(0xFF5C7CFA),
                    iconBackground: const Color(0xFFEEF1FF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _meetingSwitch(),
          const SizedBox(height: 14),
          _meetingSearch(),
          const SizedBox(height: 14),
          if (isFirstLoad)
            const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Center(child: LoadingAnimation()),
            )
          else if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 28),
              child: Center(
                child: Text(
                  'No meetings yet',
                  style: TextStyle(
                    fontFamily: kFamilyName,
                    color: Color(0xFF8B939E),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...filtered.map(
              (analytic) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _meetingCard(analytic, tabType),
              ),
            ),
          if (notifier.isLoading && notifier.hasMore && filtered.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: LoadingAnimation()),
            ),
        ],
      ),
    );
  }

  Widget _meetingsHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 6, 12, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF4EA), Color(0xFFFFFBF7), Colors.white],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1-1 Meetings',
                  style: TextStyle(
                    fontFamily: kFamilyName,
                    color: Color(0xFF1C1F26),
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Track your business opportunities and referrals within the HEF community.',
                  style: TextStyle(
                    fontFamily: kFamilyName,
                    color: Color(0xFF8B939E),
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const _GrowthArt(),
        ],
      ),
    );
  }

  Widget _statCard({
    required String label,
    required int value,
    required double? change,
    required Color changeColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
  }) {
    final formatted = NumberFormat.decimalPattern().format(value);
    return Container(
      height: 112,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F1F3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
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
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: kFamilyName,
                    color: Color(0xFF8B939E),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const Spacer(),
          Text(
            formatted,
            style: const TextStyle(
              fontFamily: kFamilyName,
              color: Color(0xFF1C1F26),
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          _changeRow(change, changeColor),
        ],
      ),
    );
  }

  Widget _changeRow(double? change, Color color) {
    if (change == null) {
      return Text(
        'vs LM',
        style: TextStyle(
          fontFamily: kFamilyName,
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    final positive = change >= 0;
    final label =
        '${positive ? '+' : ''}${change.toStringAsFixed(1)}% vs LM';
    return Row(
      children: [
        Icon(
          positive ? Icons.trending_up : Icons.trending_down,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: kFamilyName,
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _meetingSwitch() {
    final sentSelected = _tabController.index != 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _switchButton(
              label: '1-1 Meetings Send',
              selected: sentSelected,
              onTap: () => setState(() => _selectTab(0)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _switchButton(
              label: '1-1 Meetings Received',
              selected: !sentSelected,
              onTap: () => setState(() => _selectTab(1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 46,
      child: selected
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFFF6D00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: kFamilyName,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1C1F26),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE6E8EC)),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: kFamilyName,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }

  Widget _meetingSearch() {
    final filterActive = startDate != null || endDate != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmitted,
                style: const TextStyle(
                  fontFamily: kFamilyName,
                  fontSize: 14,
                  color: Color(0xFF1C1F26),
                ),
                decoration: InputDecoration(
                  hintText: 'Search by name, business or chapter...',
                  hintStyle: const TextStyle(
                    fontFamily: kFamilyName,
                    color: Color(0xFFB7BDC6),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFB7BDC6), size: 22),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  border: _searchBorder(const Color(0xFFE6E8EC)),
                  enabledBorder: _searchBorder(const Color(0xFFE6E8EC)),
                  focusedBorder: _searchBorder(const Color(0xFFFF6D00)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 48,
            height: 48,
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: filterActive
                      ? const Color(0xFFFF6D00)
                      : const Color(0xFFE6E8EC),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _showFilterModal,
                child: Icon(
                  Icons.tune,
                  color: filterActive
                      ? const Color(0xFFFF6D00)
                      : const Color(0xFF9AA1AB),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _searchBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }

  Widget _meetingsHeader() {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
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
              final asyncNotifications = ref.watch(fetchNotificationsProvider);
              return asyncNotifications.when(
                data: (notifications) =>
                    _bell(hasUnread: _hasUnread(notifications)),
                loading: () => _bell(hasUnread: false),
                error: (_, __) => _bell(hasUnread: false),
              );
            },
          ),
          InkWell(
            onTap: _drawerController.showDrawer,
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE9EAEC)),
              ),
              child: const Icon(Icons.menu_rounded, color: Color(0xFF1C1F26), size: 22),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasUnread(List<NotificationModel> notifications) {
    return notifications.any((notification) {
      final userNotification = notification.users?.firstWhere(
        (user) => user.userId == id,
        orElse: () => UserNotification(userId: '', read: false, cleared: false),
      );
      return !(userNotification?.cleared ?? false) &&
          !(userNotification?.read ?? false);
    });
  }

  Widget _bell({required bool hasUnread}) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE9EAEC)),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.notifications_none_outlined, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
          ),
          if (hasUnread)
            const Positioned(
              right: 11,
              top: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: kCommunityOrange,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 8, height: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _meetingCard(AnalyticsModel analytic, String tabBarType) {
    final name = (analytic.username ?? '').trim();
    final displayName = name.isEmpty ? 'Member' : name;
    final company = (analytic.title ?? '').trim();
    final chapter = (analytic.location ?? '').trim();
    final when = analytic.date?.toLocal();
    final dateText = when == null ? '' : DateFormat('d MMM yyyy').format(when);
    final badge = tabBarType == 'received' ? 'Received' : 'Sent';
    final initials = _initials(displayName);
    final palette = _avatarPalette(displayName);

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEF2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showReusableModalSheet(analytic, tabBarType, context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.$1,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initials,
                  style: TextStyle(
                    fontFamily: kFamilyName,
                    color: palette.$2,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: kFamilyName,
                        color: Color(0xFF1C1F26),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    if (company.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: kFamilyName,
                          color: Color(0xFF8B939E),
                          fontSize: 12.5,
                          height: 1.25,
                        ),
                      ),
                    ],
                    if (chapter.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        chapter,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: kFamilyName,
                          color: Color(0xFF6B7280),
                          fontSize: 12.5,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F8EE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontFamily: kFamilyName,
                        color: Color(0xFF178A4C),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (dateText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      dateText,
                      style: const TextStyle(
                        fontFamily: kFamilyName,
                        color: Color(0xFF9AA1AB),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFC5CAD3), size: 22),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).take(2);
    final letters = parts.map((part) => part[0]).join().toUpperCase();
    return letters.isEmpty ? '?' : letters;
  }

  (Color, Color) _avatarPalette(String name) {
    const palettes = <(Color, Color)>[
      (Color(0xFFFFF1E6), Color(0xFFE07A20)),
      (Color(0xFFE8EEF8), Color(0xFF5C7EA6)),
      (Color(0xFFF3EAF8), Color(0xFF8A74B0)),
    ];
    return palettes[name.hashCode.abs() % palettes.length];
  }
}

class _GrowthArt extends StatelessWidget {
  const _GrowthArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFF1E4),
            ),
          ),
          const Positioned(
            right: 8,
            bottom: 16,
            child: Icon(Icons.bar_chart, color: Color(0xFF7EA2E8), size: 28),
          ),
          const Positioned(
            right: 18,
            top: 14,
            child: Icon(Icons.trending_up, color: Color(0xFFFF6D00), size: 34),
          ),
          const Icon(Icons.business_center, color: Color(0xFF1E3A5F), size: 42),
        ],
      ),
    );
  }
}
