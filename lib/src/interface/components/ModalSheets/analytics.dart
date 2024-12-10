import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/analytics_api/analytics_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/analytics_model.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';

class AnalyticsModalSheet extends ConsumerWidget {
  final AnalyticsModel analytic;
  final String tabBarType;
  const AnalyticsModalSheet({
    Key? key,
    required this.tabBarType,
    required this.analytic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    NavigationService navigationService = NavigationService();
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 25, top: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Indicator
            Center(
              child: Container(
                height: 4,
                width: 60,
                decoration: BoxDecoration(
                  color: kBlack54,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // User Info Row
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(analytic.userImage ?? ''),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        analytic.username ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        analytic.title ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Details Section

            // _buildDetailRow('Request Type', analytic.type ?? ''),
            _buildDetailRow('Title', analytic.title ?? ''),
            _buildDetailRow('Date & time', analytic.date.toString()),
            _buildDetailRow('Amount', analytic.amount ?? ''),
            _buildDetailRow(
              'Status',
              analytic.status ?? '',
              statusColor: analytic.status == 'accepted'
                  ? kGreen
                  : analytic.status == 'rejected'
                      ? kPrimaryColor
                      : kGrey,
            ),
            const SizedBox(height: 8),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              analytic.description ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            SizedBox(
              height: 20,
            ),
            if (analytic.status != 'accepted')
              Row(
                children: [
                  Flexible(
                      child: customButton(
                    sideColor: kRedDark,
                    buttonColor: kRedDark,
                    label: 'Reject',
                    onPressed: () async {
                      await updateAnalyticStatus(
                          analyticId: analytic.id ?? '', action: 'rejected');
                      navigationService.pop();
                    },
                  )),
                  SizedBox(
                    width: 20,
                  ),
                  Flexible(
                      child: customButton(
                    sideColor: kGreen,
                    buttonColor: kGreen,
                    label: 'Accept',
                    onPressed: () async {
                      await updateAnalyticStatus(
                          analyticId: analytic.id ?? '', action: 'accepted');

                      ref.invalidate(fetchAnalyticsProvider);
                      navigationService.pop();
                    },
                  )),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Spacer(),
          if (statusColor != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                value,
                style: TextStyle(
                    color: analytic.status == 'pending' ? kGreyDark : kWhite),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
