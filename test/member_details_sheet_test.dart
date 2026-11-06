import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/interface/screens/main_pages/chat/member_details_sheet.dart';

void main() {
  testWidgets('member details sheet shows the design content', (tester) async {
    final user = UserModel(
      name: 'Karthik R',
      company: [
        Company(name: 'Company Name', designation: 'Designation'),
      ],
      chapter: UserChapterModel(name: 'Chennai'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemberDetailsSheet(
            user: user,
            onMessage: () {},
            onViewProfile: () {},
          ),
        ),
      ),
    );

    expect(find.text('Member Details'), findsOneWidget);
    expect(find.text('Karthik R'), findsOneWidget);
    expect(find.text('Company Name • Designation'), findsOneWidget);
    expect(find.text('Chennai Chapter'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('View Full Profile'), findsOneWidget);
  });
}
