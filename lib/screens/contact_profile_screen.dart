
import 'package:chat_app/models/chat_details.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/ui_helper.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/local_storage.dart';

class ContactProfileScreen extends StatefulWidget {
  final ChatUser contact;

  const ContactProfileScreen({super.key, required this.contact});

  @override
  State<ContactProfileScreen> createState() => _ContactProfileScreenState();
}

class _ContactProfileScreenState extends State<ContactProfileScreen> {
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
                        widget.contact.name
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
                    widget.contact.name.toString(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Number
                  Text(
                    widget.contact.number.toString(),
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
                    widget.contact.bio ?? 'No bio available',
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

            // Delete Contact
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _deleteConfirmation(),
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
                        const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Delete Contact',
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

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  _deleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Delete Contact',
              style: TextStyle(
                color: Colors.red,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              'Are you sure you want to delete this contact?',
              style: TextStyle(fontSize: 19),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'No',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  _deleteContact(widget.contact.uid!);

                  UiHelper.customSnackBar(
                    context,
                    'Contact deleted',
                    icon: Icons.delete_forever,
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen(forceRefresh: true)),
                    (route) => false,
                  );

                },
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _deleteContact(String contactUid) async {
    final ChatUser currentUser = await ChatDetails.getCurrUser();
    currentUser.contacts!.remove(contactUid);

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .update({
          'Contacts': FieldValue.arrayRemove([contactUid]),
        });

    // Update Local Storage
    await LocalStorage.deleteContact(contactUid);
    await LocalStorage.saveCurrentUser(currentUser);
  }
}
