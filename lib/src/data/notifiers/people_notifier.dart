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
  final int limit = 20;
  bool hasMore = true;

  @override
  List<UserModel> build() {
    return [];
  }

  Future<void> fetchMoreUsers() async {
    if (isLoading || !hasMore) return;

    isLoading = true;

    try {
      final newUsers = await ref
          .read(fetchActiveUsersProvider(pageNo: pageNo, limit: limit).future);
      users = [...users, ...newUsers];
      pageNo++;
      hasMore = newUsers.length == limit;
      state = users;
    } catch (e, stackTrace) {
      log(e.toString());

      log(stackTrace.toString());
    } finally {
      isLoading = false;
      log('im in people $users');
    }
  }
}