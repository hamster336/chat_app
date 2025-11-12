import 'package:chat_app/models/chat_details.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/ui_helper.dart';
import 'package:chat_app/screens/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/local_storage.dart';

class UserProfileScreen extends StatefulWidget {
  final ChatUser user;
  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top section for profile photo, name, and number
            Container(
              width: size.width,
              height: size.longestSide * 0.35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.9),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile picture
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: size.shortestSide * 0.18,
                      backgroundColor: Colors.white,
                      child: Text(
                        widget.user.name
                            .toString()
                            .substring(0, 1)
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: size.shortestSide * 0.2,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name
                  Text(
                    widget.user.name.toString(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Number
                  Text(
                    widget.user.number.toString(),
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Bio Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Bio',
                        style: TextStyle(
                          fontSize: size.shortestSide * 0.05,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.user.bio ?? 'No bio available',
                    style: TextStyle(
                      fontSize: size.shortestSide * 0.045,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // log Out
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _logOut(),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blue.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout_outlined,
                          color: Colors.black,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: size.shortestSide * 0.05,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.02),

            // delete account
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _deleteAccount(),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.red.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete, color: Colors.red, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Delete Account',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: size.shortestSide * 0.05,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.01),
          ],
        ),
      ),
    );
  }

  void _logOut() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Log Out",
            style: TextStyle(
              fontSize: 20,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),

          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(fontSize: 17, color: Colors.black),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'No',
                style: TextStyle(color: Colors.blue, fontSize: 17),
              ),
            ),

            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await FirebaseAuth.instance.signOut().then((value) {
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                    (route) => false,
                  );
                  LocalStorage.clearAll();
                });
              },
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.blue, fontSize: 17),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Delete Account",
            style: TextStyle(
              fontSize: 20,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),

          content: Text(
            "Are you sure you want to delete your account?",
            style: TextStyle(fontSize: 17, color: Colors.black),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'No',
                style: TextStyle(color: Colors.blue, fontSize: 17),
              ),
            ),

            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                Navigator.pop(context); // close confirmation box
                final uid = ChatDetails.currentUserId;
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
                  // remove current user from the contacts of every other user
                  final users =
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .get();
                  for (var doc in users.docs) {
                    final contacts =
                        ((doc['Contacts'] ?? []) as List).cast<String>();
                    if (contacts.contains(uid)) {
                      await doc.reference.update({
                        'Contacts': FieldValue.arrayRemove([uid]),
                      });
                    }
                  }

                  // delete the document of the current user
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(uid)
                      .delete();

                  // signout currentUser without deleting its auth info
                  await FirebaseAuth.instance.signOut().then((_) {
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const SignupPage(),
                      ),
                      (route) => false,
                    );
                    LocalStorage.clearAll();
                  });
                } catch (ex) {
                  navigator.pop(); // pop the loader
                  if (mounted) {
                    UiHelper.customSnackBar(
                      navigator.context,
                      'Failed to delete account: ${ex.toString()}',
                    );
                  }
                }
              },
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.blue, fontSize: 17),
              ),
            ),
          ],
        );
      },
    );
  }
}
