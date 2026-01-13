import 'dart:developer';
import 'package:hef/src/data/api_routes/people_api/people_api.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'people_notifier.g.dart';

@riverpod
class PeopleNotifier extends _$PeopleNotifier {
  List<UserModel> users = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  int pageNo = 1;
  final int limit = 20;
  bool hasMore = true;
  String? searchQuery;
  String? district; // Added district filter
  List<String>? tags; // Added tags filter
  String? chapter;
  String? category;

  @override
  List<UserModel> build() {
    return [];
  }

  Future<void> fetchMoreUsers() async {
    if (isLoading || !hasMore) return;

    isLoading = true;

    try {
      final newUsers = await ref.read(
        fetchActiveUsersProvider(
                pageNo: pageNo,
                limit: limit,
                query: searchQuery,
                district: district, // Pass district filter
                tags: tags,
                chapter: chapter ,// Pass tags filter
                category:category,
                )
            .future,
      );

      users = [...users, ...newUsers];
      pageNo++;
      hasMore = newUsers.length == limit;
      isFirstLoad = false;
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
      state = [...users];
      log('Fetched users: $users');
    }
  }

  Future<void> searchUsers(String query,
      {String? districtFilter,
      List<String>? tagsFilter,
      String? chapterFilter,
      String? categoryFilter}) async {
    isLoading = true;
    isFirstLoad = true;
    pageNo = 1;
    users = [];
    searchQuery = query;
    district = districtFilter; // Apply district filter
    tags = tagsFilter; // Apply tags filter
    chapter = chapterFilter;
    category = categoryFilter;

    try {
      final newUsers = await ref.read(
        fetchActiveUsersProvider(
          pageNo: pageNo,
          limit: limit,
          query: query,
          district: district, // Pass district filter
          tags: tags, // Pass tags filter
          chapter: chapter,
          category:category,
        ).future,
      );

      users = [...newUsers];
      pageNo++;
      hasMore = newUsers.length == limit;
      isFirstLoad = false;
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
      state = [...users];
    }
  }

  Future<void> refresh() async {
    isLoading = true;
    isFirstLoad = true;
    pageNo = 1;
    hasMore = true;
    users = [];
    state = [];

    try {
      final newUsers = await ref.read(
        fetchActiveUsersProvider(
          pageNo: pageNo,
          limit: limit,
          query: searchQuery,
          district: district, // Pass district filter
          tags: tags, // Pass tags filter
          chapter: chapter,
          category: category,
        ).future,
      );

      users = [...newUsers];
      pageNo++;
      hasMore = newUsers.length == limit;
      isFirstLoad = false;
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
      state = [...users];
    }
  }

  void setDistrict(String? newDistrict) {
    district = newDistrict;
    refresh(); // Auto-refresh when district is updated
  }

  void setTags(List<String>? newTags) {
    tags = newTags;
    refresh(); // Auto-refresh when tags are updated
  }

  void setChapter(String? newChapter) {
    chapter = newChapter;
    refresh(); // Auto-refresh when chapter is updated
  }

  void setCategory(String? newCategory) {
    category = newCategory;
    refresh(); // Auto-refresh when chapter is updated
  }
}
