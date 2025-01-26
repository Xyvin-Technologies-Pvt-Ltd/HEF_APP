import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/data/services/share_qr.dart';
import 'package:share_plus/share_plus.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
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
      ),
      backgroundColor: kScaffoldColor,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/jpgs/scaffoldBackground.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      width: double.infinity, // Width of the line
                      height: 1, // Thickness of the line
                      color: kTertiary // Line color
                      ),
                  Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 237, 231, 231)),
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(255, 182, 181, 181)
                                            .withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 1,
                                    offset: const Offset(.5, .5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xFFF2F2F2),
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: IconButton(
                                            icon: Icon(Icons.remove_red_eye),
                                            onPressed: () {
                                              navigationService.pushNamed(
                                                  'ProfilePreviewUsingID',
                                                  arguments: user.uid);
                                              // Navigator.push(
                                              //   context,
                                              //   PageRouteBuilder(
                                              //     pageBuilder: (context, animation,
                                              //             secondaryAnimation) =>
                                              //         ProfilePreview(
                                              //       user: user,
                                              //     ),
                                              //     transitionsBuilder: (context,
                                              //         animation,
                                              //         secondaryAnimation,
                                              //         child) {
                                              //       return FadeTransition(
                                              //         opacity: animation,
                                              //         child: child,
                                              //       );
                                              //     },
                                              //   ),
                                              // );
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40,
                                      ),
                                      SizedBox(
                                        width: double
                                            .infinity, // Sets a bounded width constraint
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 60,
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(width: 20),
                                                Column(
                                                  children: [
                                                    user.image != null &&
                                                            user.image != ''
                                                        ? Container(
                                                            width:
                                                                80, // Diameter + border width
                                                            height: 80,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                color:
                                                                    kPrimaryColor,
                                                                width:
                                                                    2.0, // Border width
                                                              ),
                                                            ),
                                                            child: ClipOval(
                                                              child:
                                                                  Image.network(
                                                                user.image ??
                                                                    '',
                                                                width:
                                                                    74, // Diameter of the circle (excluding border)
                                                                height: 74,
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                            ),
                                                          )
                                                        : Image.asset(
                                                            'assets/icons/dummy_person.png'),
                                                  ],
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  // Use Expanded here to take up remaining space
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(user.name ?? '',
                                                          style: kHeadTitleB),
                                                      for (Company i
                                                          in user.company ?? [])
                                                        if ((i?.name != null &&
                                                                i?.name !=
                                                                    '') ||
                                                            (i?.designation !=
                                                                    null &&
                                                                i?.designation !=
                                                                    ''))
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                if (i.name !=
                                                                        null &&
                                                                    i.name !=
                                                                        '')
                                                                  TextSpan(
                                                                    text:
                                                                        i.name,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          42,
                                                                          41,
                                                                          41),
                                                                    ),
                                                                  ),
                                                                if (i.name !=
                                                                        null &&
                                                                    i.name !=
                                                                        '' &&
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
                                                                      fontSize:
                                                                          15,
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
                                                                      fontSize:
                                                                          15,
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
                                              height: 40,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 35, right: 30, top: 25, bottom: 35),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 237, 231, 231)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 1,
                                    offset: const Offset(.5, .5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.phone,
                                          color: kPrimaryColor),
                                      const SizedBox(width: 10),
                                      Text(user.phone!),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.email,
                                          color: kPrimaryColor),
                                      const SizedBox(width: 10),
                                      Text(user.email!),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (user.address != null &&
                                      user.address != '')
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            color: kPrimaryColor),
                                        const SizedBox(width: 10),
                                        if (user.address != null)
                                          Expanded(
                                            child: Text(
                                              user.address ?? '',
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 237, 231, 231)),
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 1,
                                    offset: const Offset(.5, .5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/pngs/hef_logo.png'),
                                  Spacer(),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Member ID: ',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: user.memberId,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          captureAndShareWidgetScreenshot(context);
                        },
                        child: SvgPicture.asset(
                            'assets/svg/icons/shareButton.svg'),
                        // child: Container(
                        //   width: 90,
                        //   height: 90,
                        //   decoration: BoxDecoration(
                        //     color: kPrimaryColor,
                        //     borderRadius: BorderRadius.circular(
                        //         50), // Apply circular border to the outer container
                        //   ),
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(4.0),
                        //     child: Container(
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(50),
                        //         color: kPrimaryColor,
                        //       ),
                        //       child: Icon(
                        //         Icons.share,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ),
                      const SizedBox(width: 40),
                      GestureDetector(
                          onTap: () {
                            navigationService.pushNamed('Card',
                                arguments: user);
                          },
                          child:
                              SvgPicture.asset('assets/svg/icons/qrButton.svg')
                          // Container(
                          //   width: 90,
                          //   height: 90,
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(
                          //         50), // Apply circular border to the outer container
                          //   ),
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(4.0),
                          //     child: Container(
                          //       decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(50),
                          //         color: Colors.white,
                          //       ),
                          //       child: Icon(
                          //         Icons.qr_code,
                          //         color: Colors.grey,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          )
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
      ),
    );
  }
}
