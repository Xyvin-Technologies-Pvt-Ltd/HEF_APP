import 'dart:async';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hef/src/data/api_routes/user_api/login/user_login_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:hef/src/data/utils/secure_storage.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';

import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/profile/editUser.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/notifiers/loading_notifier.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

TextEditingController _mobileController = TextEditingController();
TextEditingController _otpController = TextEditingController();

final countryCodeProvider = StateProvider<String?>((ref) => '91');

class PhoneNumberScreen extends ConsumerWidget {
  const PhoneNumberScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kWhite,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.20),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontFamily: kFamilyName,
                        fontWeight: FontWeight.w700,
                        fontSize: 23,
                        color: kPrimaryColor,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 52),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: bottomInset),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Phone Number',
                                style: TextStyle(
                                  fontFamily: kFamilyName,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: kBlack,
                                ),
                              ),
                              const SizedBox(height: 10),
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
                                  letterSpacing: 1,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                controller: _mobileController,
                                disableLengthCheck: true,
                                showCountryFlag: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: kWhite,
                                  hintText: 'Enter your phone number',
                                  hintStyle: TextStyle(
                                    letterSpacing: 0,
                                    color: Colors.grey.shade500,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(
                                        color: kPrimaryColor, width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 14.0,
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
                              const SizedBox(height: 24),
                              Text(
                                'A 6 digit verification code will be sent',
                                style: TextStyle(
                                  fontFamily: kFamilyName,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 34),
                                child: SizedBox(
                                  height: 45,
                                  width: double.infinity,
                                  child: customButton(
                                    label: 'Generate OTP',
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
    SnackbarService snackbarService = SnackbarService();
    final countryCode = ref.watch(countryCodeProvider) ?? '91';
    final rawPhone = _mobileController.text.trim();
    FocusScope.of(context).unfocus();
    ref.read(loadingProvider.notifier).startLoading();

    final fullNumber = '+$countryCode$rawPhone';
    debugPrint('LOGIN: Checking if user exists: $fullNumber');

    bool userExists = false;
    try {
      userExists = await UserService.checkUser(fullNumber);
      debugPrint('LOGIN: UserService.checkUser returned: $userExists');
    } catch (e, stack) {
      debugPrint('LOGIN: UserService.checkUser failed with error: $e\n$stack');
    }

    if (userExists) {
      try {
        if (countryCode == '971' && rawPhone.length != 9) {
          debugPrint('LOGIN: Invalid phone length for 971: expected 9 digits, got ${rawPhone.length}');
          snackbarService.showSnackBar('Please Enter valid mobile number (9 digits)');
          return;
        } else if (countryCode != '971' && rawPhone.length != 10) {
          debugPrint('LOGIN: Invalid phone length: expected 10 digits, got ${rawPhone.length}');
          snackbarService.showSnackBar('Please Enter valid mobile number (10 digits)');
          return;
        }

        final formattedCountryCode = countryCode == '971' ? '9710' : countryCode;
        debugPrint('LOGIN: Submitting phone number: code=$formattedCountryCode, phone=$rawPhone');

        final data = await submitPhoneNumber(
            formattedCountryCode,
            context,
            rawPhone);

        final verificationId = data['verificationId'];
        final resendToken = data['resendToken'];
        final failureReason = data['error'];

        if (verificationId != null && verificationId.isNotEmpty) {
          debugPrint('LOGIN: OTP sent successfully, verificationId=$verificationId');
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => OTPScreen(
              phone: rawPhone,
              verificationId: verificationId,
              resendToken: resendToken ?? '',
            ),
          ));
        } else {
          final errorMsg = failureReason != null && failureReason.isNotEmpty
              ? failureReason
              : 'Unknown error occurred (verificationId is empty)';
          debugPrint('LOGIN: OTP generation failed! Failure reason: $errorMsg');
          snackbarService.showSnackBar('Failed');
        }
      } catch (e, stack) {
        debugPrint('LOGIN: Exception in _handleOtpGeneration: $e\n$stack');
        snackbarService.showSnackBar('Failed');
      } finally {
        ref.read(loadingProvider.notifier).stopLoading();
      }
    } else {
      debugPrint('LOGIN: User $fullNumber does not exist');
      snackbarService.showSnackBar('User does not exists');
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }
}

class OTPScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String resendToken;
  final String phone;
  const OTPScreen({
    required this.phone,
    required this.resendToken,
    super.key,
    required this.verificationId,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  Timer? _timer;

  int _start = 59;

  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _isButtonDisabled = true;
    _start = 59;
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

  String get _formattedTimer {
    final minutes = (_start ~/ 60).toString().padLeft(2, '0');
    final seconds = (_start % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void resendCode() {
    startTimer();

    resendOTP(widget.phone, widget.verificationId, widget.resendToken);
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
      backgroundColor: kWhite,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const PhoneNumberScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: kBlack,
                      size: 24,
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
                  Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontFamily: kFamilyName,
                      fontWeight: FontWeight.w700,
                      fontSize: 23,
                      color: kPrimaryColor,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 52),
                  const Text(
                    'Enter the OTP to verify',
                    style: TextStyle(
                      fontFamily: kFamilyName,
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: kBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: false,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 72,
                      fieldWidth: 44,
                      borderWidth: 1.5,
                      selectedColor: kPrimaryColor,
                      activeColor: Colors.grey.shade300,
                      inactiveColor: Colors.grey.shade300,
                      activeFillColor: kWhite,
                      selectedFillColor: kWhite,
                      inactiveFillColor: kWhite,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    controller: _otpController,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isButtonDisabled
                            ? 'Resend OTP in $_formattedTimer seconds'
                            : 'Didn\'t receive the OTP?',
                        style: TextStyle(
                          fontFamily: kFamilyName,
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      GestureDetector(
                        onTap: _isButtonDisabled ? null : resendCode,
                        child: Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontFamily: kFamilyName,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: _isButtonDisabled
                                ? Colors.grey.shade400
                                : kPrimaryColor,
                            decoration: _isButtonDisabled
                                ? TextDecoration.none
                                : TextDecoration.underline,
                            decorationColor: kPrimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 34),
                    child: SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: customButton(
                        label: 'Verify OTP',
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
          ),
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
    ref.read(loadingProvider.notifier).startLoading();

    try {
      final code = _otpController.text.trim();
      debugPrint('LOGIN: Verifying OTP "$code" with verificationId=${widget.verificationId}');

      Map<String, dynamic> responseMap = await verifyOTP(
          verificationId: widget.verificationId,
          fcmToken: fcmToken,
          smsCode: code,
          context: context);

      debugPrint('LOGIN: verifyOTP returned: $responseMap');
      String? savedToken = responseMap['token'];
      String? savedId = responseMap['userId'];

      if (savedToken != null && savedToken.isNotEmpty && savedId != null && savedId.isNotEmpty) {
        await SecureStorage.write('token', savedToken);
        await SecureStorage.write('id', savedId);
        token = savedToken;
        id = savedId;
        debugPrint('LOGIN: Verification success! savedId=$savedId');
        ref.read(userProvider.notifier).refreshUser();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ProfileCompletionScreen()));
      } else {
        debugPrint('LOGIN: OTP verification failed! Server response did not contain valid token/userId: $responseMap');
        SnackbarService().showSnackBar('Wrong OTP');
      }
    } catch (e, stack) {
      debugPrint('LOGIN: Exception during _handleOtpVerification: $e\n$stack');
      SnackbarService().showSnackBar('Wrong OTP');
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
      backgroundColor: kWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    settings: RouteSettings(
                                        name: 'ProfileCompletion'),
                                    builder: (context) => const EditUser()));
                          },
                          fontSize: 16);
                    },
                  )),
            ),
            TextButton(
              onPressed: () {
                NavigationService navigationService = NavigationService();
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
