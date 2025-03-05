import 'dart:developer';
import 'package:hef/src/data/api_routes/people_api/people_api.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'people_notifier.g.dart';

@riverpod
class PeopleNotifier extends _$PeopleNotifier {
  List<UserModel> users = [];
  bool isLoading = false;
  int pageNo = 1;
  final int limit = 9;
  bool hasMore = true;
  String? searchQuery;

  @override
  List<UserModel> build() {
    return [];
  }

  Future<void> fetchMoreUsers() async {
    if (isLoading || !hasMore) return;

    isLoading = true;

    // Delay state update to avoid modifying during widget build
    Future(() {
      state = [...users];
    });

    try {
      final newUsers = await ref.read(
          fetchActiveUsersProvider(pageNo: pageNo, limit: limit, query: searchQuery)
              .future);

      users = [...users, ...newUsers];
      pageNo++;
      hasMore = newUsers.length == limit;

      // Delay state update to trigger rebuild after data is fetched
      Future(() {
        state = [...users];
      });
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;

      // Ensure state update after fetch completion
      Future(() {
        state = [...users];
      });

      log('Fetched users: $users');
    }
  }

  Future<void> searchUsers(String query) async {
    isLoading = true;
    pageNo = 1;
    users = []; // Reset the user list when searching
    searchQuery = query;

    try {
      final newUsers = await ref.read(
          fetchActiveUsersProvider(pageNo: pageNo, limit: limit, query: query)
              .future);

      users = [...newUsers];
      hasMore = newUsers.length == limit;

      state = [...users];
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
    }
  }

  Future<void> refresh() async {
    isLoading = true;
    pageNo = 1;
    hasMore = true;
    users = []; // Clear the current user list
    state = [...users]; // Update the state to reflect the cleared list

    try {
      final newUsers = await ref.read(
          fetchActiveUsersProvider(pageNo: pageNo, limit: limit, query: searchQuery)
              .future);

      users = [...newUsers];
      hasMore = newUsers.length == limit;

      state = [...users]; // Update the state with refreshed data
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
    }
  }
}


