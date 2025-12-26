import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/business_category_api.dart/business_category_api_service.dart';
import 'package:hef/src/data/models/business_category_model.dart';

class BusinessCategoryNotifier
    extends StateNotifier<List<BusinessCategoryModel>> {
  BusinessCategoryNotifier(this._ref) : super([]);

  final Ref _ref;

  List<BusinessCategoryModel> categories = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  int pageNo = 1;
  final int limit = 200;
  bool hasMore = true;
  String? searchQuery;

  Future<void> fetchMoreCategories() async {
    if (isLoading || !hasMore) return;

    isLoading = true;

    try {
      final apiService = BusinesscategoryApiService();
      final newCategories = await apiService.getBusinessCategories(
        pageNo: pageNo,
        limit: limit,
      );

      // FILTER ONLY ACTIVE CATEGORIES
      final activeCategories =
          newCategories.where((c) => c.status == true).toList();

      if (activeCategories.isEmpty) {
        hasMore = false;
      } else {
        categories = [...categories, ...activeCategories];
        pageNo++;
        hasMore = activeCategories.length >= limit;
      }

      isFirstLoad = false;
      state = categories;
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
    }
  }

  Future<void> refreshCategories() async {
    if (isLoading) return;

    isLoading = true;

    try {
      pageNo = 1;
      final apiService = BusinesscategoryApiService();
      final refreshedCategories = await apiService.getBusinessCategories(
        pageNo: pageNo,
        limit: limit,
      );

      // FILTER ONLY ACTIVE CATEGORIES
      categories = refreshedCategories.where((c) => c.status == true).toList();
      hasMore = categories.length >= limit;
      isFirstLoad = false;
      state = categories;
      log('refreshed');
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
    }
  }

  Future<void> searchCategories(String query) async {
    isLoading = true;
    pageNo = 1;
    categories = [];
    searchQuery = query;

    try {
      final apiService = BusinesscategoryApiService();
      final newCategories = await apiService.getBusinessCategories(
        pageNo: pageNo,
        limit: limit,
        query: query,
      );

      // FILTER ONLY ACTIVE CATEGORIES
      final activeCategories =
          newCategories.where((c) => c.status == true).toList();

      categories = [...activeCategories];
      hasMore = activeCategories.length == limit;
      state = [...categories];
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
    }
  }
}

// Provider
final businessCategoryNotifierProvider = StateNotifierProvider<
    BusinessCategoryNotifier, List<BusinessCategoryModel>>(
  (ref) => BusinessCategoryNotifier(ref),
);
