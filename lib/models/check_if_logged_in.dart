import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckIfLoggedIn extends StatefulWidget {
  const CheckIfLoggedIn({super.key});

  @override
  State<CheckIfLoggedIn> createState() => _CheckIfLoggedInState();
}

class _CheckIfLoggedInState extends State<CheckIfLoggedIn> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          // User is logged in
          return const HomeScreen();
        } else {
          // No user → go to Sign Up / Login screen
          return const SignupPage();
        }
      },
    );
  }
}
