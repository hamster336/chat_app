import 'dart:io';

import 'package:chat_app/models/ui_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/chat_details.dart';
import '../models/chat_user.dart';
import '../models/local_storage.dart';
import 'home_screen.dart';
import 'loading_screen.dart';

class CreateAccount extends StatefulWidget {
  final String number;

  const CreateAccount({super.key, required this.number});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  String? name;
  String? bio;

  File? pickedImage;

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Create Account', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: (size.height * 0.025)),

                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Choose Image from",
                            style: TextStyle(fontSize: 18),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                onTap: () async {
                                  await pickImage(ImageSource.camera);
                                  Navigator.pop(context);
                                },
                                leading: Icon(Icons.camera),
                                title: Text("Camera"),
                              ),

                              ListTile(
                                onTap: () async {
                                  await pickImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                },
                                leading: Icon(Icons.browse_gallery),
                                title: Text("Gallery"),
                              ),

                              ListTile(
                                onTap: () {
                                  setState(() {
                                    pickedImage = null;
                                  });
                                  Navigator.pop(context);
                                },
                                leading: Icon(Icons.delete),
                                title: Text("Delete this image"),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },

                  child:
                      (pickedImage == null)
                          ? CircleAvatar(
                            radius: 80,
                            child: Icon(Icons.person, size: 90),
                          )
                          : CircleAvatar(
                            radius: 80,
                            backgroundImage: FileImage(pickedImage!),
                          ),
                ),

                const SizedBox(height: 20),

                UiHelper.customTextField(
                  nameController,
                  "Name",
                  Icons.person,
                  false,
                ),

                const SizedBox(height: 15),
                Container(
                  width: size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          widget.number,
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),

                        Spacer(),

                        Icon(Icons.phone),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                UiHelper.customTextField(
                  bioController,
                  "Bio (Optional)",
                  Icons.person,
                  false,
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: size.width * 0.65,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      name = setName(nameController.text.toString());
                      if (name == null) return;

                      bio = setBio(bioController.text.toString());

                      saveData(name!, widget.number, bio);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Save',
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
      ),
    );
  }

  setName(String name) {
    if (name.trim().isEmpty) {
      UiHelper.customAlertBox(context, "Name cannot be empty!");
      return null;
    }
    return name.trim();
  }

  setBio(String text) {
    if (text.trim().isEmpty) {
      return null;
    }
    return text.trim();
  }

  pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imagePath = File(image.path);
      setState(() {
        pickedImage = imagePath;
      });
    } catch (ex) {
      pickedImage = null;
    }
  }

  saveData(String name, String num, String? bio) async {
    // if(name == null) return;

    List<String> searchKeywords = generateSearchKeywords(name.toLowerCase());

    ChatUser user = ChatUser(
      contacts: [],
      number: num,
      searchKeywords: searchKeywords,
      bio: bio,
      name: name,
    );

    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(auth.currentUser?.uid)
          .set(user.toJson(),).then((value) {
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      'Account Created',
                      style: TextStyle(fontSize: 17, color: Colors.black),
                      textDirection: TextDirection.ltr,
                    ),

                    actions: [
                      TextButton(
                        onPressed: () {
                          // updateLoadingState(value: true);
                          // await LocalStorage.saveContacts(await ChatDetails.getContacts());
                          // await LocalStorage.saveCurrentUser(await ChatDetails.getCurrUser(forceRefresh: true));
                          // updateLoadingState();
                          //
                          // Navigator.pushAndRemoveUntil(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => HomeScreen(),
                          //   ),
                          //   (route) => false,
                          // );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => LoadingScreen(
                                message: 'Getting things ready...',
                                loadData: () async{
                                  // await LocalStorage.saveContacts(await ChatDetails.getContacts());
                                  await LocalStorage.saveCurrentUser(await ChatDetails.getCurrUser(forceRefresh: true));
                                },
                                nextScreen: HomeScreen(),
                              ),
                            ),
                          );
                        },
                        child: Text('OK', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  );
                },
              );
            }
          });
    } catch (ex) {
      if (mounted) {
        UiHelper.customAlertBox(
          context,
          "Failed to create account: ${ex.toString()}",
        );
      }
    }
  }

  generateSearchKeywords(String tempName) {
    List<String> keywords = [];
    for (int i = 0; i < tempName.length; i++) {
      if (tempName[i] == " ") {
        continue;
      } else {
        for (int j = i + 1; j <= tempName.length; j++) {
          keywords.add(tempName.substring(i, j));
        }
      }
    }
    return keywords;
  }

  void showProgressIndicator(){
    if(isLoading){
      Center(child: CircularProgressIndicator(),);
    }
  }

}
