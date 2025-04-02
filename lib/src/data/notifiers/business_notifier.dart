import 'dart:developer';
import 'package:hef/src/data/api_routes/business_api/business_api.dart';
import 'package:hef/src/data/models/business_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'business_notifier.g.dart';

@riverpod
class BusinessNotifier extends _$BusinessNotifier {
  List<Business> businesses = [];
  bool isLoading = false;
  int pageNo = 1;
  final int limit = 5;
  bool hasMore = true;

  @override
  List<Business> build() {
    return [];
  }

  Future<void> fetchMoreFeed() async {
    if (isLoading || !hasMore) return;

    isLoading = true;

    try {
      final newBusinesses = await ref
          .read(fetchBusinessProvider(pageNo: pageNo, limit: limit).future);
      businesses = [...businesses, ...newBusinesses];
      pageNo++;
      hasMore = newBusinesses.length == limit;
      state = businesses;
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
    }
  }

  Future<void> refreshFeed() async {
    if (isLoading) return;

    isLoading = true;

    try {
      pageNo = 1;
      final refreshedBusinesses = await ref
          .read(fetchBusinessProvider(pageNo: pageNo, limit: limit).future);
      businesses = refreshedBusinesses;
      hasMore = refreshedBusinesses.length == limit;
      state = businesses; // Update the state with the refreshed feed\
      log('refreshed');
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
    }
  }
}
