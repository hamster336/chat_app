import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/ui_helper.dart';
import 'otp_screen.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController numController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose(){
    numController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              SizedBox(height: (size.height * 0.20)),

              SizedBox(
                width: size.width * 0.85,
                child: Text(
                  'Welcome',
                  style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(
                width: size.width * 0.85,
                child: Text(
                  'Sign in to begin chats!',
                  style: TextStyle(fontSize: 24, color: Colors.grey[700]),
                ),
              ),

              const SizedBox(height: 80),

              SizedBox(
                width: size.width * 0.85,
                child: Text(
                  'Enter your phone number with country code to verify!',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                child: TextField(
                  maxLength: 15,
                  autofocus: false,
                  controller: numController,
                  decoration: InputDecoration(
                    labelText: 'Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: Icon(Icons.phone),
                    prefixText: '+',
                    counterText: '',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: size.width * 0.60,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (numController.text.trim().isEmpty) {
                      if (mounted) {
                        UiHelper.customAlertBox(
                          context,
                          "Phone number cannot be empty!",
                        );
                      }
                    } else if (!isValidNum(
                      "+${numController.text.toString()}",
                    )) {
                      if (mounted) {
                        UiHelper.customAlertBox(
                          context,
                          "Invalid phone number",
                        );
                      }
                    } else {
                      await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: "+${numController.text.toString()}",

                        verificationCompleted: (
                          PhoneAuthCredential credential,
                        ) async {
                          await FirebaseAuth.instance.signInWithCredential(
                            credential,
                          );
                        },

                        verificationFailed: (FirebaseAuthException ex) {
                          if (mounted) {
                            UiHelper.customAlertBox(
                              context,
                              ex.code.toString(),
                            );
                          }
                        },

                        codeSent: (
                          String verificationId,
                          int? forceResendingToken,
                        ) {
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => VerifyOTP(
                                      verificationid: verificationId,
                                      number:
                                          "+${numController.text.toString()}",
                                    ),
                              ),
                            );
                          }
                        },

                        codeAutoRetrievalTimeout: (String verificationId) {},
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: Text(
                    'Send OTP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isValidNum(String num) {
    String cleaned = num.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.length >= 10 && cleaned.length <= 15) {
      return true;
    }
    return false;
  }
}
