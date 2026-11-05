import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/analytics_model.dart';
import 'package:hef/src/data/notifiers/analytics_notifier.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/ModalSheets/analytics.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:intl/intl.dart';

class BusinessActivityPage extends ConsumerStatefulWidget {
  final String title;
  final String searchHint;
  final String listType;
  final String requestType;
  final bool showAdd;

  const BusinessActivityPage({
    super.key,
    required this.title,
    required this.searchHint,
    required this.listType,
    required this.requestType,
    required this.showAdd,
  });

  @override
  ConsumerState<BusinessActivityPage> createState() =>
      _BusinessActivityPageState();
}

class _BusinessActivityPageState extends ConsumerState<BusinessActivityPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future(() => _load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(analyticsNotifierProvider.notifier).fetchMoreAnalytics();
    }
  }

  Future<void> _load() {
    return ref.read(analyticsNotifierProvider.notifier).searchAnalytics(
          newType: widget.listType,
          newStartDate: _startDate == null
              ? null
              : DateFormat('yyyy-MM-dd').format(_startDate!),
          newEndDate: _endDate == null
              ? null
              : DateFormat('yyyy-MM-dd').format(_endDate!),
          newRequestType: widget.requestType,
          query: _searchController.text,
        );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() {});
    });
    setState(() {});
  }

  Future<void> _showFilter() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text('Date Range', style: kBodyTitleB),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _dateField(
                          label: _startDate == null
                              ? 'Start Date'
                              : DateFormat('MMM d, yyyy').format(_startDate!),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setSheetState(() => _startDate = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _dateField(
                          label: _endDate == null
                              ? 'End Date'
                              : DateFormat('MMM d, yyyy').format(_endDate!),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setSheetState(() => _endDate = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setSheetState(() {
                              _startDate = null;
                              _endDate = null;
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
                            _load();
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _dateField({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE4E4E4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  void _openDetails(AnalyticsModel analytic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return AnalyticsModalSheet(
          analytic: analytic,
          tabBarType: widget.listType,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsNotifierProvider);
    final notifier = ref.read(analyticsNotifierProvider.notifier);
    final query = _searchController.text.trim().toLowerCase();
    final visible = query.isEmpty
        ? analytics
        : analytics.where((item) {
            final name = item.username?.toLowerCase() ?? '';
            final title = item.title?.toLowerCase() ?? '';
            return name.contains(query) || title.contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C1C), size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFF1C1C1C),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1)),
        ),
      ),
      floatingActionButton: widget.showAdd
          ? FloatingActionButton(
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
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1C1C1C),
                      ),
                      decoration: InputDecoration(
                        hintText: widget.searchHint,
                        hintStyle: const TextStyle(
                          color: Color(0xFFB0B4BA),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFB0B4BA),
                          size: 22,
                        ),
                        filled: true,
                        fillColor: kWhite,
                        contentPadding: EdgeInsets.zero,
                        border: _searchBorder(),
                        enabledBorder: _searchBorder(),
                        focusedBorder: _searchBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _filterButton(),
              ],
            ),
          ),
          Expanded(
            child: notifier.isFirstLoad
                ? const Center(child: LoadingAnimation())
                : RefreshIndicator(
                    color: kPrimaryColor,
                    onRefresh: _load,
                    child: visible.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: Text(
                                  'No data available',
                                  style: TextStyle(color: Color(0xFF8E939A)),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              16,
                              10,
                              16,
                              widget.showAdd ? 96 : 24,
                            ),
                            itemCount: visible.length +
                                (notifier.isLoading && notifier.hasMore ? 1 : 0),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              if (index == visible.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(child: LoadingAnimation()),
                                );
                              }
                              return _ActivityCard(
                                analytic: visible[index],
                                onTap: () => _openDetails(visible[index]),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _searchBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
    );
  }

  Widget _filterButton() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: kWhite,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _showFilter,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF8A1A),
                    width: 1.2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.tune,
                    color: Color(0xFFFF7A00),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 7,
            right: 7,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFF3B30),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final AnalyticsModel analytic;
  final VoidCallback onTap;

  const _ActivityCard({required this.analytic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = analytic.date == null
        ? ''
        : DateFormat('MMM d yyyy').format(analytic.date!.toLocal());
    final amount = analytic.amount == null
        ? null
        : '₹${analytic.amount!.toStringAsFixed(1)}';
    final status = _statusStyle(analytic.status ?? '');

    return Material(
      color: kWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _avatar(analytic.userImage),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analytic.username?.trim().isNotEmpty == true
                          ? analytic.username!
                          : 'Member',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    if ((analytic.title ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        analytic.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8E939A),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ],
                    if (amount != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        amount,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
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
                  Text(
                    date,
                    style: const TextStyle(
                      color: Color(0xFFA0A4AB),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status.label.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: status.background,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.label,
                            style: TextStyle(
                              color: status.foreground,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFFC5C5C5),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(String? url) {
    const size = 46.0;
    if (url == null || url.isEmpty) {
      return const CircleAvatar(
        radius: 23,
        backgroundColor: Color(0xFFF1F2F4),
        child: Icon(Icons.person, color: Color(0xFFB0B4BA), size: 24),
      );
    }
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const CircleAvatar(
          radius: 23,
          backgroundColor: Color(0xFFF1F2F4),
          child: Icon(Icons.person, color: Color(0xFFB0B4BA), size: 24),
        ),
      ),
    );
  }
}

class _StatusStyle {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusStyle(this.label, this.background, this.foreground);
}

_StatusStyle _statusStyle(String raw) {
  final value = raw.trim().toLowerCase();
  if (value.isEmpty) {
    return const _StatusStyle('', Colors.transparent, Colors.transparent);
  }
  final label = value
      .split(RegExp(r'[_\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
  switch (value) {
    case 'pending':
      return _StatusStyle(
        label,
        const Color(0xFFFCF8E0),
        const Color(0xFFA89858),
      );
    case 'accepted':
    case 'completed':
      return _StatusStyle(label, const Color(0xFFE7F7EA), const Color(0xFF2E9E45));
    case 'rejected':
      return _StatusStyle(label, const Color(0xFFFDECEC), const Color(0xFFE15B5B));
    case 'meeting_scheduled':
      return _StatusStyle(label, const Color(0xFFE8F1FC), const Color(0xFF2B74E1));
    default:
      return _StatusStyle(label, const Color(0xFFF3F4F6), const Color(0xFF8A8F98));
  }
}
