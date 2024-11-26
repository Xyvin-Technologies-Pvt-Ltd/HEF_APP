import 'dart:async';
import 'dart:developer';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hef/src/data/api_routes/user_api/login/user_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';

import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_page.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/notifiers/loading_notifier.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextEditingController _mobileController = TextEditingController();
TextEditingController _otpController = TextEditingController();

final countryCodeProvider = StateProvider<String?>((ref) => '91');

class PhoneNumberScreen extends ConsumerWidget {
  PhoneNumberScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);
    final countryCode = ref.watch(countryCodeProvider);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kPrimaryLightColor,
      body: Stack(
        children: [
          Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: SvgPicture.asset('assets/svg/images/login_flower.svg')),

          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const SizedBox(height: 80),
                    Text(
                      'Login',
                      style: kHeadTitleB.copyWith(color: kPrimaryColor),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: bottomInset),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Please enter your mobile number',
                                  style: kBodyTitleL),
                              const SizedBox(height: 20),
                              IntlPhoneField(
                                validator: (phone) {
                                  if (phone!.number.length > 9) {
                                    if (phone.number.length > 10) {
                                      return 'Phone number cannot exceed 10 digits';
                                    }
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  letterSpacing: 8,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                                controller: _mobileController,
                                disableLengthCheck: true,
                                showCountryFlag: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: kWhite,
                                  hintText: 'Enter your phone number',
                                  hintStyle: const TextStyle(
                                    letterSpacing: 2,
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: kGrey),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: kGrey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: kGrey),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 10.0,
                                  ),
                                ),
                                onCountryChanged: (value) {
                                  ref.read(countryCodeProvider.notifier).state =
                                      value.dialCode;
                                },
                                initialCountryCode: 'IN',
                                onChanged: (PhoneNumber phone) {
                                  print(phone.completeNumber);
                                },
                                flagsButtonPadding: const EdgeInsets.only(
                                    left: 10, right: 10.0),
                                showDropdownIcon: true,
                                dropdownIconPosition: IconPosition.trailing,
                                dropdownTextStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                  'A 6 digit verification code will be sent',
                                  style: kSmallTitleR),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: SizedBox(
                                  height: 47,
                                  width: double.infinity,
                                  child: customButton(
                                    label: 'GENERATE OTP',
                                    onPressed: isLoading
                                        ? () {}
                                        : () {
                                            _handleOtpGeneration(context, ref);
                                          },
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading overlay
          if (isLoading)
            Container(
              color: kBlack54,
              child: const Center(
                child: LoadingAnimation(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleOtpGeneration(BuildContext context, WidgetRef ref) async {
    SnackbarService scaffoldMessengerKey = SnackbarService();
    NavigationService navigationService = NavigationService();
    final countryCode = ref.watch(countryCodeProvider);
    ref.read(loadingProvider.notifier).startLoading();

    try {
      if (countryCode == '971') {
        if (_mobileController.text.length != 9) {
          scaffoldMessengerKey.showSnackBar('Please Enter valid mobile number');
        } else {
          final data = await sendOtp(
            phone: _mobileController.text,
            countryCode: countryCode == '971'
                ? 9710.toString()
                : countryCode ?? 91.toString(),
          );
          scaffoldMessengerKey.showSnackBar(data);
          // final data = await submitPhoneNumber(
          //     countryCode == '971'
          //         ? 9710.toString()
          //         : countryCode ?? 91.toString(),
          //     context,
          //     _mobileController.text);
          // final verificationId = data['verificationId'];
          // final resendToken = data['resendToken'];
          // if (verificationId != null && verificationId.isNotEmpty) {
          //   log('Otp Sent successfully');
          navigationService.pushNamedReplacement('Otp',
              arguments: '$countryCode${_mobileController.text}');

          // Navigator.of(context).pushReplacement(MaterialPageRoute(
          //   builder: (context) => OTPScreen(
          //     phone: _mobileController.text,
          //     verificationId: verificationId,
          //     resendToken: resendToken ?? '',
          //   ),
          // ));
          // } else {
          //   CustomSnackbar.showSnackbar(context, 'Failed');
          // }
        }
      } else if (countryCode != '971') {
        if (_mobileController.text.length != 10) {
          scaffoldMessengerKey.showSnackBar('Please Enter valid mobile number');
        } else {
          final data = await sendOtp(
            phone: _mobileController.text,
            countryCode: countryCode == '971'
                ? 9710.toString()
                : countryCode ?? 91.toString(),
          );
          scaffoldMessengerKey.showSnackBar(data);
          navigationService.pushNamedReplacement('Otp',
              arguments: '$countryCode${_mobileController.text}');

          // ApiRoutes userApi = ApiRoutes();

          // final data = await userApi.submitPhoneNumber(
          //     countryCode == '971'
          //         ? 9710.toString()
          //         : countryCode ?? 971.toString(),
          //     context,
          //     _mobileController.text);
          // final verificationId = data['verificationId'];
          // final resendToken = data['resendToken'];
          // if (verificationId != null && verificationId.isNotEmpty) {
          //   log('Otp Sent successfully');

          //   Navigator.of(context).pushReplacement(MaterialPageRoute(
          //     builder: (context) => OTPScreen(
          //       phone: _mobileController.text,
          //       verificationId: verificationId,
          //       resendToken: resendToken ?? '',
          //     ),
          //   ));
          // } else {
          //   CustomSnackbar.showSnackbar(context, 'Failed');
          // }
        }
      }
    } catch (e) {
      log(e.toString());
      scaffoldMessengerKey.showSnackBar('Failed');
    } finally {
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }
}

class OTPScreen extends ConsumerStatefulWidget {
  // final String verificationId;
  // final String resendToken;
  final String phone;
  const OTPScreen({
    required this.phone,
    // required this.resendToken,
    super.key,
    // required this.verificationId,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  Timer? _timer;

  int _start = 20;

  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _isButtonDisabled = true;
    _start = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isButtonDisabled = false;
        });
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void resendCode() {
    startTimer();
    // ApiRoutes userApi = ApiRoutes();
    // userApi.resendOTP(widget.phone, widget.verificationId, widget.resendToken);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kPrimaryLightColor,
      body: Stack(
        children: [
          Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: SvgPicture.asset('assets/svg/images/login_flower.svg')),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const SizedBox(height: 80),
                Text(
                  'Verify OTP',
                  style: kHeadTitleB.copyWith(color: kPrimaryColor),
                ),
                SizedBox(
                  height: 40,
                ),
                Text('Enter the Otp to verify',
                    style: kSmallerTitleEL.copyWith(fontSize: 20)),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6, // Number of OTP digits
                    obscureText: false,
                    keyboardType: TextInputType.number, // Number-only keyboard
                    animationType: AnimationType.fade,
                    textStyle: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 5.0,
                    ),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 55,
                      fieldWidth: 50, selectedColor: kPrimaryColor,
                      activeColor: const Color.fromARGB(255, 232, 226, 226),
                      inactiveColor: kWhite,
                      activeFillColor: kWhite, // Box color when focused
                      selectedFillColor: kWhite, // Box color when selected
                      inactiveFillColor:
                          kWhite, // Box fill color when not selected
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    controller: _otpController,
                    onChanged: (value) {
                      // Handle input change
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        _isButtonDisabled
                            ? 'Enter OTP in $_start seconds'
                            : 'Enter your OTP',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _isButtonDisabled ? kGrey : kBlack),
                      ),
                    ),
                    GestureDetector(
                      onTap: _isButtonDisabled ? null : resendCode,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Text(
                          _isButtonDisabled ? '' : 'Resend Code',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: _isButtonDisabled ? kGrey : kRed),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: SizedBox(
                    height: 47,
                    width: double.infinity,
                    child: customButton(
                      label: 'CONTINUE',
                      onPressed: isLoading
                          ? () {}
                          : () {
                              _handleOtpVerification(context, ref);
                            },
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Loading overlay
          if (isLoading)
            Container(
              color: kBlack54,
              child: const Center(
                child: LoadingAnimation(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleOtpVerification(
      BuildContext context, WidgetRef ref) async {
    NavigationService navigationService = NavigationService();
    final countryCode = ref.watch(countryCodeProvider);
    ref.read(loadingProvider.notifier).startLoading();

    try {
      print(_otpController.text);
      String response = await verifyUser(
        phone: '+91${_mobileController.text}',
        otp: _otpController.text,
      );
      log('Token:$response');
      // Map<String, dynamic> responseMap = await userApi.verifyOTP(
      //     verificationId: widget.verificationId,
      //     fcmToken: fcmToken,
      //     smsCode: _otpController.text,
      //     context: context);
      String savedToken = response;
      // String savedToken = responseMap['token'];
      // String savedId = responseMap['userId'];

      if (savedToken.isNotEmpty) {
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        await preferences.setString('token', savedToken);
        // await preferences.setString('id', savedId);
        token = savedToken;
        // id = savedId;
        log('savedToken: $token');
        // log('savedId: $savedId');
        ref.read(userProvider.notifier).refreshUser();
        navigationService.pushNamedReplacement('ProfileCompletion');
      } else {
        // CustomSnackbar.showSnackbar(context, 'Wrong OTP');
      }
    } catch (e) {
      // CustomSnackbar.showSnackbar(context, 'Wrong OTP');
    } finally {
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }
}

class ProfileCompletionScreen extends StatelessWidget {
  const ProfileCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryLightColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace SvgPicture.asset with any image you are using
            SvgPicture.asset('assets/svg/images/letsgetstarted.svg'),
            SizedBox(
              height: 10,
            ),
            Text("Let's Get Started,\nComplete your profile",
                textAlign: TextAlign.center,
                style: GoogleFonts.unna(
                  color: kGreyDark,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, top: 10),
              child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: Consumer(
                    builder: (context, ref, child) {
                      return customButton(
                          label: 'Next',
                          onPressed: () {
                          
                            // Navigator.of(context).pushReplacement(
                            //     MaterialPageRoute(
                            //         settings: RouteSettings(
                            //             name: 'ProfileCompletion'),
                            //         builder: (context) => const DetailsPage()));
                            ref.invalidate(userProvider);
                          },
                          fontSize: 16);
                    },
                  )),
            ),
            TextButton(
              onPressed: () {
                NavigationService navigationService = NavigationService();
                // _mobileController.dispose();
                // _otpController.dispose();
                navigationService.pushNamedReplacement('MainPage');
              },
              child: Text(
                'Skip',
                style: kSmallTitleB.copyWith(color: kPrimaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}
