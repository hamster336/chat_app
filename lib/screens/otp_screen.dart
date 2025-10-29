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

class VerifyOTP extends StatefulWidget {
  final String verificationid, number;

  const VerifyOTP({
    super.key,
    required this.verificationid,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Column(
              children: [
                SizedBox(height: (size.height * 0.20)),
                SizedBox(
                  width: size.width * 0.85,
                  child: Text(
                    'Verify OTP',
                    style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(
                  width: size.width * 0.85,
                  child: Text(
                    'An otp has been sent to the entered number!',
                    style: TextStyle(fontSize: 24, color: Colors.grey[700]),
                  ),
                ),

                const SizedBox(height: 80),

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

                const SizedBox(height: 50),

                SizedBox(
                  width: size.width * 0.60,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (otpController.text.toString().trim().isEmpty) {
                        UiHelper.customAlertBox(
                          context,
                          'Please enter the OTP!',
                        );
                      }

                      try {
                        PhoneAuthCredential credential =
                            PhoneAuthProvider.credential(
                              verificationId: widget.verificationid,
                              smsCode: otpController.text.toString(),
                            );
                        FirebaseAuth.instance
                            .signInWithCredential(credential)
                            .then((value) async {
                              await isRegistered(widget.number)
                                  ? {
                                    // updateLoadingState(value: true),
                                    // await LocalStorage.saveContacts(
                                    //   await ChatDetails.getContacts(),
                                    // ),
                                    // await LocalStorage.saveCurrentUser(
                                    //   await ChatDetails.getCurrUser(
                                    //     forceRefresh: true,
                                    //   ),
                                    // ),
                                    // updateLoadingState(),
                                    // Navigator.pushAndRemoveUntil(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder:
                                    //         (BuildContext context) =>
                                    //             HomeScreen(),
                                    //   ),
                                    //   (route) => false,
                                    // ),
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => LoadingScreen(
                                              message: 'Getting things ready...',
                                              loadData: () async{
                                                await LocalStorage.saveContacts(await ChatDetails.getContacts());
                                                await LocalStorage.saveCurrentUser(await ChatDetails.getCurrUser(forceRefresh: true));
                                              },
                                              nextScreen: HomeScreen(),
                                            ),
                                      ),
                                    ),
                                  }
                                  : Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (BuildContext context) =>
                                              CreateAccount(
                                                number: widget.number,
                                              ),
                                    ),
                                    (route) => false,
                                  );
                            });
                      } catch (ex) {
                        UiHelper.customAlertBox(context, ex.toString());
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

                SizedBox(height: size.longestSide * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getNumber(String number) {
    var length = number.length;
    String hidden = getStarString(length - 10);
    return "${number.substring(0, 9)}$hidden${number.substring(length - 3)}";
  }

  String getStarString(int length) {
    String star = '';
    for (int i = 0; i < length; i++) {
      star += '*';
    }
    return star;
  }

  isRegistered(String phoneNum) async {
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
    }
  }
}
