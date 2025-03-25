import 'dart:developer';
import 'package:hef/src/data/api_routes/analytics_api/analytics_api.dart';
import 'package:hef/src/data/api_routes/business_api/business_api.dart';
import 'package:hef/src/data/models/analytics_model.dart';
import 'package:hef/src/data/models/business_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'analytic_notifier.g.dart';

@riverpod
class AnalyticNotifier extends _$AnalyticNotifier {
  List<AnalyticsModel> analytics = [];
  bool isLoading = false;
  int pageNo = 1;
  final int limit = 7;
  bool hasMore = true;
  String? type;
  String? startDate;
  String? endDate;
  String? requestType;

  @override
  List<AnalyticsModel> build() {
    return [];
  }

  Future<void> fetchMoreAnalytic() async {
    if (isLoading || !hasMore) return;

    isLoading = true;

    try {
      final newAnalytics = await ref.read(fetchAnalyticsProvider(
              pageNo: pageNo,
              limit: limit,
              type: type,
              requestType: requestType,
              startDate: startDate,
              endDate: endDate)
          .future);
      analytics = [...analytics, ...newAnalytics];
      pageNo++;
      hasMore = newAnalytics.length == limit;
      state = analytics;
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
    }
  }

  Future<void> refreshAnalytics() async {
    if (isLoading) return;

    isLoading = true;

    try {
      pageNo = 1;
      final refreshedAnalytics = await ref.read(fetchAnalyticsProvider(
              pageNo: pageNo,
              limit: limit,
              type: type,
              requestType: requestType,
              startDate: startDate,
              endDate: endDate)
          .future);
      analytics = refreshedAnalytics;
      hasMore = refreshedAnalytics.length == limit;
      state = analytics;
      log('refreshed');
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
    }
  }
}
