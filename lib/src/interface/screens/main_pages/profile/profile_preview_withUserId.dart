import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/interface/screens/main_pages/profile/member_profile_view.dart';

class ProfilePreviewUsingId extends ConsumerWidget {
  final String userId;

  const ProfilePreviewUsingId({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(fetchUserDetailsProvider(userId));
    return asyncUser.when(
      data: (user) => MemberProfileView(user: user),
      loading: () => const MemberProfileStatusScaffold(loading: true),
      error: (_, __) => const MemberProfileStatusScaffold(loading: false),
    );
  }
}
