import 'dart:developer';

import 'package:hef/src/data/models/analytics_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hef/src/data/api_routes/analytics_api/analytics_api.dart';

part 'analytics_notifier.g.dart';

@riverpod
class AnalyticsNotifier extends _$AnalyticsNotifier {
  List<AnalyticsModel> analytics = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  int pageNo = 1;
  final int limit = 10;
  bool hasMore = true;

  // Filter state variables
  String? type; // 'sent', 'received', or null for all
  String? startDate;
  String? endDate;
  String? requestType;
  String? searchQuery;

  @override
  List<AnalyticsModel> build() {
    return [];
  }

  Future<void> fetchMoreAnalytics() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    state = [...analytics];

    try {
      log('Fetching analytics for pageNo: $pageNo, limit: $limit, type: $type');
      final newAnalytics = await ref.read(
        fetchAnalyticsProvider(
          type: type,
          startDate: startDate,
          endDate: endDate,
          requestType: requestType,
          pageNo: pageNo,
          limit: limit,
        ).future,
      );

      final existingIds = analytics.map((e) => e.id).toSet();
      final uniqueNewAnalytics =
          newAnalytics.where((item) => !existingIds.contains(item.id)).toList();

      analytics = [...analytics, ...uniqueNewAnalytics];
      pageNo++;
      hasMore = newAnalytics.length == limit;
      isFirstLoad = false;

      log('Fetched ${newAnalytics.length} analytics, total: ${analytics.length}, hasMore: $hasMore, next pageNo: $pageNo');
      state = [...analytics];
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
      state = [...analytics];
      log('Analytics fetch complete');
    }
  }

  Future<void> searchAnalytics({
    String? newType,
    String? newStartDate,
    String? newEndDate,
    String? newRequestType,
    String? query,
  }) async {
    isLoading = true;
    isFirstLoad = true;
    pageNo = 1;
    analytics = [];
    type = newType;
    startDate = newStartDate;
    endDate = newEndDate;
    requestType = newRequestType;
    searchQuery = query;
    state = [...analytics];

    try {
      log('Searching analytics with type: $type, pageNo: $pageNo');
      final newAnalytics = await ref.read(
        fetchAnalyticsProvider(
          type: type,
          startDate: startDate,
          endDate: endDate,
          requestType: requestType,
          pageNo: pageNo,
          limit: limit,
        ).future,
      );

      analytics = [...newAnalytics];
      hasMore = newAnalytics.length == limit;
      isFirstLoad = false;
      state = [...analytics];
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
      state = [...analytics];
    }
  }

  Future<void> refresh() async {
    isLoading = true;
    isFirstLoad = true;
    pageNo = 1;
    hasMore = true;
    analytics = [];
    state = [...analytics];

    try {
      log('Refreshing analytics with type: $type, pageNo: $pageNo');
      final newAnalytics = await ref.read(
        fetchAnalyticsProvider(
          type: type,
          startDate: startDate,
          endDate: endDate,
          requestType: requestType,
          pageNo: pageNo,
          limit: limit,
        ).future,
      );

      analytics = [...newAnalytics];
      hasMore = newAnalytics.length == limit;
      isFirstLoad = false;
      state = [...analytics];
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
      state = [...analytics];
    }
  }

  void updateFilters({
    String? newType,
    String? newStartDate,
    String? newEndDate,
    String? newRequestType,
  }) {
    type = newType;
    startDate = newStartDate;
    endDate = newEndDate;
    requestType = newRequestType;
    refresh(); // Auto-refresh when filters are updated
  }
}
