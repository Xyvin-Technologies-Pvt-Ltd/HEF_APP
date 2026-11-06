import 'package:flutter/material.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/interface/screens/main_pages/profile/member_profile_view.dart';

class ProfilePreview extends StatelessWidget {
  final UserModel user;

  const ProfilePreview({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MemberProfileView(user: user);
  }
}
