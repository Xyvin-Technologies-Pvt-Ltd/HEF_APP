import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/services/save_qr.dart';
import 'package:hef/src/data/services/share_qr.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

class ProfileCard extends StatelessWidget {
  final UserModel user;
  const ProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    ScreenshotController screenshotController = ScreenshotController();
    final isFullScreenProvider = StateProvider<bool>((ref) => false);

    return Consumer(
      builder: (context, ref, child) {
        final isFullScreen = ref.watch(isFullScreenProvider);
        return Scaffold(
          backgroundColor: kScaffoldColor,
          appBar: !isFullScreen
              ? AppBar(
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  bottom: PreferredSize(
                    preferredSize: Size(double.infinity, 0),
                    child: Container(
                        width: double.infinity, // Width of the line
                        height: 1, // Thickness of the line
                        color: kTertiary // Line color
                        ),
                  ),
                  backgroundColor: kScaffoldColor,
                  title: Text(
                    'Profile',
                    style: kSubHeadingL,
                  ),
                )
              : null,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          if (!isFullScreen) {
                            return IconButton(
                              icon: Container(
                                  decoration: BoxDecoration(
                                    color: kWhite,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: const Icon(Icons.open_in_full),
                                  )),
                              onPressed: () {
                                SystemChrome.setEnabledSystemUIMode(
                                    SystemUiMode.immersiveSticky);
                                ref.read(isFullScreenProvider.notifier).state =
                                    true;
                              },
                            );
                          } else {
                            return Container(
                              decoration: BoxDecoration(
                                color: kWhite,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close_fullscreen),
                                onPressed: () {
                                  SystemChrome.setEnabledSystemUIMode(
                                      SystemUiMode.edgeToEdge);
                                  ref
                                      .read(isFullScreenProvider.notifier)
                                      .state = false;
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Screenshot(
                    controller: screenshotController,
                    child: Container(
                      decoration: const BoxDecoration(color: kScaffoldColor),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25, right: 15),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: SizedBox(
                                    width: double
                                        .infinity, // Sets a bounded width constraint
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(width: 20),
                                            Column(
                                              children: [
                                                user.image != null &&
                                                        user.image != ''
                                                    ? Container(
                                                        width:
                                                            100, // Diameter + border width
                                                        height: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                            color:
                                                                kPrimaryColor,
                                                            width:
                                                                2.0, // Border width
                                                          ),
                                                        ),
                                                        child: ClipOval(
                                                          child: Image.network(
                                                            user.image ?? '',
                                                            width:
                                                                74, // Diameter of the circle (excluding border)
                                                            height: 74,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                      )
                                                    : Image.asset(
                                                        'assets/pngs/dummy_person_large.png'),
                                              ],
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(user.name ?? '',
                                                      style: kHeadTitleB),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  for (Company i
                                                      in user.company ?? [])
                                                    if ((i?.name != null &&
                                                            i?.name != '') ||
                                                        (i?.designation !=
                                                                null &&
                                                            i?.designation !=
                                                                ''))
                                                      RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            if (i.name !=
                                                                    null &&
                                                                i.name != '')
                                                              TextSpan(
                                                                text: i.name,
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          42,
                                                                          41,
                                                                          41),
                                                                ),
                                                              ),
                                                            if (i.name !=
                                                                    null &&
                                                                i.name != '' &&
                                                                i.designation !=
                                                                    null &&
                                                                i.designation !=
                                                                    '')
                                                              const TextSpan(
                                                                text: ' - ',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            if (i.designation !=
                                                                    null &&
                                                                i.designation !=
                                                                    '')
                                                              TextSpan(
                                                                text: i
                                                                    .designation,
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: kWhite,
                              ),
                              child: QrImageView(
                                size: 285,
                                data:
                                    'https://admin.hefconnect.in/user/${user.uid}',
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (user.phone != null)
                              Row(
                                children: [
                                  const Icon(Icons.phone, color: kPrimaryColor),
                                  const SizedBox(width: 10),
                                  Text(user.phone?.toString() ?? ''),
                                ],
                              ),
                            const SizedBox(height: 10),
                            if (user.email != null)
                              Row(
                                children: [
                                  const Icon(Icons.email, color: kPrimaryColor),
                                  const SizedBox(width: 10),
                                  Text(user.email ?? ''),
                                ],
                              ),
                            const SizedBox(height: 10),
                            if (user.address != null)
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: kPrimaryColor),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      user.address ?? '',
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isFullScreen)
                    Container(
                      color: kWhite,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Flexible(
                                  child: customButton(
                                      buttonHeight: 60,
                                      fontSize: 16,
                                      label: 'Share',
                                      onPressed: () async {
                                        captureAndShareWidgetScreenshot(
                                            context);
                                      }),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  child: customButton(
                                      sideColor: kPrimaryColor,
                                      labelColor: kPrimaryColor,
                                      buttonColor: kWhite,
                                      buttonHeight: 60,
                                      fontSize: 15,
                                      label: 'Download QR',
                                      onPressed: () async {
                                        saveQr(
                                          screenshotController:
                                              screenshotController,
                                        );
                                      }),
                                ),
                              ],
                            )),
                      ),
                    ),
                  if (!isFullScreen)
                    Container(
                      color: kWhite,
                      height: 40,
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
