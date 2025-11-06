import 'dart:developer';

import 'package:chat_app/models/chat_details.dart';
import 'package:chat_app/models/local_storage.dart';
import 'package:chat_app/screens/create_account.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/models/ui_helper.dart';
import 'package:chat_app/screens/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'done_checking.dart';

class VerifyOTP extends StatefulWidget {
  final String verificationId, number;

  const VerifyOTP({
    super.key,
    required this.verificationId,
    required this.number,
  });

  @override
  State<VerifyOTP> createState() => _VerifyOTPState();
}

class _VerifyOTPState extends State<VerifyOTP> {
  TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void updateLoadingState({bool value = false}) {
    if (!mounted) {
      return;
    }
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                SizedBox(height: (size.height * 0.20)),

                // primary heading text
                SizedBox(
                  width: size.width * 0.85,
                  child: Text(
                    'Verify OTP',
                    style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                  ),
                ),

                // secondary heading text
                SizedBox(
                  width: size.width * 0.85,
                  child: Text(
                    'An otp has been sent to the entered number!',
                    style: TextStyle(fontSize: 24, color: Colors.grey[700]),
                  ),
                ),

                SizedBox(height: size.height * 0.08),

                // tertiary heading text
                SizedBox(
                  width: size.width * 0.85,
                  child: Text(
                    'Enter the 6-digit otp sent to ${getNumber(widget.number)}!',
                    style: TextStyle(fontSize: 17, letterSpacing: 0.6),
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ),

                const SizedBox(height: 10),

                // textField
                SizedBox(
                  width: size.width * 0.85,
                  height: 50,
                  child: TextField(
                    controller: otpController,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, letterSpacing: 5),
                    decoration: InputDecoration(
                      hintText: 'XXXXXXX',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                SizedBox(height: size.height * 0.06),

                // verify button
                SizedBox(
                  width: size.width * 0.60,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (otpController.text.toString().trim().isEmpty) {
                        UiHelper.customAlertBox(
                          context,
                          'Please enter the OTP!',
                        );
                        return;
                      }

                      final nav = Navigator.of(context);    // capture navigator before async

                      // show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (_) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 5,
                                color: Colors.blue[200],
                              ),
                            ),
                      );

                      try {
                        PhoneAuthCredential credential =
                            PhoneAuthProvider.credential(
                              verificationId: widget.verificationId,
                              smsCode: otpController.text.toString().trim(),
                            );

                        await FirebaseAuth.instance.signInWithCredential(
                          credential,
                        );

                        final registered = await isRegistered(widget.number);

                        if(!mounted) return;

                        nav.pop();  // pop loading indicator

                        if (registered) {
                          // Navigator.pop(context); // pop the circular progress indicator
                          nav.pushReplacement(
                            MaterialPageRoute(
                              builder:
                                  (_) => DoneChecking(
                                    nextScreen: LoadingScreen(
                                      message: 'Getting things ready...',
                                      loadData: () async {
                                        ChatDetails.updateCurrentUserId();
                                        await LocalStorage.saveContacts(await ChatDetails.getContacts());
                                        await LocalStorage.saveCurrentUser(await ChatDetails.fetchCurrentUser());

                                      },
                                      nextScreen: HomeScreen(),
                                    ),
                                    message: 'Verification Successful!',
                                  ),
                            ),
                          );
                        } else {
                          // Navigator.pop(context);
                          // navigate to create account screen
                          nav.pushReplacement(
                            MaterialPageRoute(
                              builder:
                                  (_) => DoneChecking(
                                    nextScreen: CreateAccount(
                                      number: widget.number,
                                    ),
                                    message: 'Verification Successful!',
                                  ),
                            ),
                          );
                        }
                      } on FirebaseAuthException catch (ex) {
                        if(!mounted) return;
                        nav.pop(); // pop the loading indicator
                        UiHelper.customAlertBox(nav.context, ex.code.toString());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    child: Text(
                      'Verify',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // methods to hide some digits of the number
  String getNumber(String number) {
    var length = number.length;
    String hidden = getStarString(length - 10);
    return "${number.substring(0, 7)}$hidden${number.substring(length - 3)}";
  }

  String getStarString(int length) {
    String star = '';
    for (int i = 0; i < length; i++) {
      star += '*';
    }
    return star;
  }

  // check if user is already registered or not
   Future<bool> isRegistered(String phoneNum) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) return false;

      String uid = user.uid;

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (userDoc.exists) {
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }
}
