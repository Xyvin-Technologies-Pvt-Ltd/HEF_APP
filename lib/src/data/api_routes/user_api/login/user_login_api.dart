import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hef/src/data/globals.dart';

Future<Map<String, String>> submitPhoneNumber(
    String countryCode, BuildContext context, String phone) async {
  FirebaseAuth auth = FirebaseAuth.instance;

  // On iOS Simulator, physical APNs notifications cannot be received.
  // Enabling appVerificationDisabledForTesting allows testing phone auth on simulators.
  if (kDebugMode && Platform.isIOS) {
    try {
      await auth.setSettings(appVerificationDisabledForTesting: true);
      debugPrint('submitPhoneNumber: set appVerificationDisabledForTesting=true for iOS debug');
    } catch (e) {
      debugPrint('submitPhoneNumber: failed to set auth settings: $e');
    }
  }

  Completer<String> verificationIdcompleter = Completer<String>();
  Completer<String> resendTokencompleter = Completer<String>();
  Completer<String> errorCompleter = Completer<String>();
  final fullPhoneNumber = '+$countryCode$phone';
  debugPrint('submitPhoneNumber: starting verification for $fullPhoneNumber');

  try {
    await auth.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint('submitPhoneNumber: verificationCompleted automatically for $fullPhoneNumber');
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('FirebaseAuthException in verifyPhoneNumber: code=${e.code}, message=${e.message}, details=${e.stackTrace}');
        if (!verificationIdcompleter.isCompleted) {
          verificationIdcompleter.complete('');
          resendTokencompleter.complete('');
          errorCompleter.complete('[${e.code}] ${e.message ?? 'Unknown Firebase error'}');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        debugPrint('submitPhoneNumber: codeSent! verificationId: $verificationId, resendToken: $resendToken');
        if (!verificationIdcompleter.isCompleted) {
          verificationIdcompleter.complete(verificationId);
          resendTokencompleter.complete(resendToken?.toString() ?? '');
          errorCompleter.complete('');
        }
      },
      codeAutoRetrievalTimeout: (String verificationID) {
        debugPrint('submitPhoneNumber: codeAutoRetrievalTimeout: $verificationID');
        if (!verificationIdcompleter.isCompleted) {
          verificationIdcompleter.complete('');
          resendTokencompleter.complete('');
          errorCompleter.complete('Timeout without receiving verification code');
        }
      },
    );
  } catch (e, stack) {
    debugPrint('submitPhoneNumber unexpected error: $e\n$stack');
    if (!verificationIdcompleter.isCompleted) {
      verificationIdcompleter.complete('');
      resendTokencompleter.complete('');
      errorCompleter.complete(e.toString());
    }
  }

  final verificationId = await verificationIdcompleter.future;
  final resendToken = await resendTokencompleter.future;
  final error = await errorCompleter.future;

  return {
    "verificationId": verificationId,
    "resendToken": resendToken,
    "error": error,
  };
}

void resendOTP(String phoneNumber, String verificationId, String resendToken) {
  FirebaseAuth auth = FirebaseAuth.instance;
  debugPrint('resendOTP: resending code to +91$phoneNumber');
  auth.verifyPhoneNumber(
    phoneNumber: '+91$phoneNumber',
    forceResendingToken: int.tryParse(resendToken),
    timeout: const Duration(seconds: 60),
    verificationCompleted: (PhoneAuthCredential credential) {
      debugPrint('resendOTP: Auto-retrieval or instant verification completed');
    },
    verificationFailed: (FirebaseAuthException e) {
      debugPrint("resendOTP failed: code=${e.code}, message=${e.message}");
    },
    codeSent: (String verificationId, int? resendToken) {
      debugPrint("resendOTP: codeSent success! verificationId=$verificationId");
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      debugPrint("resendOTP: codeAutoRetrievalTimeout: $verificationId");
    },
  );
}

Future<Map<String, dynamic>> verifyOTP(
    {required String verificationId,
    required String fcmToken,
    required String smsCode,
    required BuildContext context}) async {
  SnackbarService snackbarService = SnackbarService();
  FirebaseAuth auth = FirebaseAuth.instance;
  PhoneAuthCredential credential = PhoneAuthProvider.credential(
    verificationId: verificationId,
    smsCode: smsCode,
  );

  try {
    UserCredential userCredential = await auth.signInWithCredential(credential);
    User? user = userCredential.user;
    if (user != null) {
      String? idToken = await user.getIdToken();
      log("ID Token: $idToken");
      log("fcm token:$fcmToken");
      log("Verification ID:$verificationId");
      final Map<String, dynamic> tokenMap =
          await verifyUserDB(idToken!, fcmToken, context);
      log(tokenMap.toString());
      return tokenMap;
    } else {
      print("User signed in, but no user information was found.");
      return {};
    }
  } catch (e) {
    snackbarService.showSnackBar('Wrong OTP');
    print("Failed to sign in: ${e.toString()}");
    return {};
  }
}

Future<Map<String, dynamic>> verifyUserDB(
    String idToken, String fcmToken, BuildContext context) async {
  SnackbarService snackbarService = SnackbarService();
  final response = await http.post(
    Uri.parse('$baseUrl/user/login'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"clientToken": idToken, "fcm": fcmToken}),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody = jsonDecode(response.body);
    log(responseBody.toString(),name: 'LOGIN SUCCESS');
    snackbarService.showSnackBar(responseBody['message']);
    return responseBody['data'];
  } else if (response.statusCode == 400) {
    final Map<String, dynamic> responseBody = jsonDecode(response.body);
    log(responseBody.toString(), name: ' LOGIN FAILED STATUS CODE 400');
    snackbarService.showSnackBar(responseBody['message']);
    return {};
  } else {
    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    log(responseBody.toString(),name: 'LOGIN FAILED');
    snackbarService.showSnackBar(responseBody['message']);
    return {};
  }
}
