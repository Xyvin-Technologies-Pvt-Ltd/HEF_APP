import 'package:flutter/material.dart';
import 'package:hef/src/data/api_routes/analytics_api/analytics_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/analytics_model.dart';
import 'package:hef/src/data/services/analytics_pdf_service.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class ChapterBusinessPage extends StatefulWidget {
  const ChapterBusinessPage({super.key});

  @override
  State<ChapterBusinessPage> createState() => _ChapterBusinessPageState();
}

class _ChapterBusinessPageState extends State<ChapterBusinessPage> {
  final ScrollController _scrollController = ScrollController();
  final List<AnalyticsModel> _items = [];
  final AnalyticsApiService _api = AnalyticsApiService();
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loading || _loadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = _items.isEmpty;
        _error = null;
        _page = 1;
        _hasMore = true;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    try {
      final page = reset ? 1 : _page;
      final batch = await AnalyticsApiService.fetchChapterBusiness(
        pageNo: page,
        limit: 10,
      );
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(batch);
        _hasMore = batch.length == 10;
        _page = page + 1;
        _loading = false;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      final text = error.toString().replaceFirst('Exception: ', '');
      setState(() {
        _error = text.isEmpty ? 'Could not load chapter business' : text;
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _download(DateTime start, DateTime end, String label) async {
    final startText = DateFormat('yyyy-MM-dd').format(start);
    final endText = DateFormat('yyyy-MM-dd').format(end);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: LoadingAnimation()),
    );

    try {
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
      final data = await AnalyticsApiService.fetchChapterBusiness(
        startDate: startText,
        endDate: endText,
        pageNo: 1,
        limit: 10000,
      );
      if (!mounted) return;
      if (data.isEmpty) {
        Navigator.of(context).pop();
        _message('No business in this $label');
        return;
      }
      final file = await AnalyticsPdfService.generateAnalyticsPdf(
        analyticsData: data,
        reportType: 'chapter',
        startDate: startText,
        endDate: endText,
        requestType: 'Business',
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label report downloaded'),
          backgroundColor: kGreen,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () => AnalyticsPdfService.openPdfFile(file),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _message('Could not download the report');
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: kPrimaryColor),
    );
  }

  void _openDownloadSheet() {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    showModalBottomSheet(
      context: context,
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: SizedBox(
                    width: 42,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Download report',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Chapter business for the period you choose.',
                  style: TextStyle(color: Color(0xFF8E939A), fontSize: 13),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.date_range, color: kPrimaryColor),
                  title: const Text('This week'),
                  subtitle: Text(
                    '${DateFormat('d MMM').format(weekStart)} – ${DateFormat('d MMM').format(weekEnd)}',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _download(weekStart, weekEnd, 'weekly');
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_month, color: kPrimaryColor),
                  title: const Text('This month'),
                  subtitle: Text(DateFormat('MMMM yyyy').format(now)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _download(monthStart, monthEnd, 'monthly');
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_calendar, color: kPrimaryColor),
                  title: const Text('Custom dates'),
                  subtitle: const Text('Pick a start and end date'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickCustomRange();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month, now.day),
      ),
    );
    if (range == null || !mounted) return;
    _download(range.start, range.end, 'custom');
  }

  Future<void> _openDetails(AnalyticsModel analytic) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _BusinessDetailSheet(
          analytic: analytic,
          onDecision: (action) async {
            final result = await _api.updateAnalyticStatus(
              analyticId: analytic.id ?? '',
              action: action,
            );
            if (!mounted || !sheetContext.mounted) return;
            if (result == 'success') {
              Navigator.pop(sheetContext);
              _message(action == 'accepted' ? 'Business accepted' : 'Business rejected');
              _load(reset: true);
            } else {
              _message(result ?? 'Could not update this business');
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Business',
          style: TextStyle(
            color: Color(0xFF1C1C1C),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openDownloadSheet,
            icon: const Icon(Icons.download_outlined, color: Color(0xFF1C1C1C)),
          ),
        ],
      ),
      body: _loading && _items.isEmpty
          ? const Center(child: LoadingAnimation())
          : _error != null && _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: Color(0xFF8E939A))),
                      const SizedBox(height: 12),
                      TextButton(onPressed: () => _load(reset: true), child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: kPrimaryColor,
                  onRefresh: () => _load(reset: true),
                  child: _items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 140),
                            Center(
                              child: Text(
                                'No business in this chapter',
                                style: TextStyle(color: Color(0xFF8E939A)),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _items.length + (_loadingMore ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            if (index == _items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: LoadingAnimation(size: 28)),
                              );
                            }
                            return _BusinessCard(
                              analytic: _items[index],
                              onTap: () => _openDetails(_items[index]),
                            );
                          },
                        ),
                ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final AnalyticsModel analytic;
  final VoidCallback onTap;

  const _BusinessCard({required this.analytic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sender = (analytic.senderName ?? '').trim();
    final receiver = (analytic.receiverName ?? '').trim();
    final people = [
      if (sender.isNotEmpty) sender,
      if (receiver.isNotEmpty) receiver,
    ].join(' → ');
    final when = analytic.date?.toLocal();
    final status = _statusStyle(analytic.status ?? '');

    return Material(
      color: kWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8E8E8)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      (analytic.title ?? '').trim().isEmpty
                          ? 'Business'
                          : analytic.title!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  if (status.label.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: status.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.label,
                        style: TextStyle(
                          color: status.foreground,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              if (people.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  people,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  if (when != null)
                    Text(
                      DateFormat('d MMM yyyy').format(when),
                      style: const TextStyle(color: Color(0xFFA0A4AB), fontSize: 12),
                    ),
                  const Spacer(),
                  if (analytic.amount != null)
                    Text(
                      '₹${analytic.amount!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusinessDetailSheet extends StatelessWidget {
  final AnalyticsModel analytic;
  final Future<void> Function(String action) onDecision;

  const _BusinessDetailSheet({
    required this.analytic,
    required this.onDecision,
  });

  @override
  Widget build(BuildContext context) {
    final description = (analytic.description ?? '').trim();
    final sender = (analytic.senderName ?? '').trim();
    final receiver = (analytic.receiverName ?? '').trim();
    final status = (analytic.status ?? '').trim().toLowerCase();
    final canDecide = status != 'completed';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: SizedBox(
              width: 42,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            (analytic.title ?? '').trim().isEmpty ? 'Business' : analytic.title!.trim(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (sender.isNotEmpty) _line('Sender', sender),
          if (receiver.isNotEmpty) _line('Receiver', receiver),
          if (analytic.date != null)
            _line('Date', DateFormat('d MMM yyyy').format(analytic.date!.toLocal())),
          if (analytic.amount != null)
            _line('Amount', '₹${analytic.amount!.toStringAsFixed(2)}'),
          _line('Status', _statusStyle(analytic.status ?? '').label),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(color: Color(0xFF6B7280), height: 1.35)),
          ],
          if (canDecide) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: kWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => onDecision('accepted'),
                child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: TextButton(
                onPressed: () => onDecision('rejected'),
                child: const Text(
                  'Reject',
                  style: TextStyle(
                    color: Color(0xFFEC4444),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: const TextStyle(color: Color(0xFF9CA3AF))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _StatusColors {
  final String label;
  final Color background;
  final Color foreground;
  const _StatusColors(this.label, this.background, this.foreground);
}

_StatusColors _statusStyle(String raw) {
  final value = raw.trim().toLowerCase();
  final label = value
      .split(RegExp(r'[_\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
  switch (value) {
    case 'accepted':
    case 'completed':
      return _StatusColors(label, const Color(0xFFD0F8E4), const Color(0xFF188464));
    case 'pending':
      return _StatusColors(label, const Color(0xFFFCF8E0), const Color(0xFFA89858));
    case 'rejected':
      return _StatusColors(label, const Color(0xFFFDECEC), const Color(0xFFE15B5B));
    default:
      return _StatusColors(
        label.isEmpty ? '-' : label,
        const Color(0xFFF3F4F6),
        const Color(0xFF8A8F98),
      );
  }
}
