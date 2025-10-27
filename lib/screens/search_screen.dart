
import 'package:chat_app/models/local_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/chat_details.dart';
import '../models/chat_user.dart';
import '../models/ui_helper.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  late List<ChatUser> matchedUsers = [];
  late ChatUser currentUser;
  bool userFound = false;
  bool isLoading = false;
  bool hasSearched = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    ChatUser user = await ChatDetails.getCurrUser();
    setState(() => currentUser = user);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Search'),
      ),

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBar(
                controller: searchController,
                onChanged: (_) async {
                  // log("Contacts: ${currentUser.contacts}");
                  matchedUsers = await findUser(
                    searchController.text.toString(),
                  );
                },
                backgroundColor: WidgetStateProperty.all(Colors.grey[200]),
                elevation: WidgetStateProperty.all(0),
                leading: Icon(Icons.search),
                hintText: 'Find people',
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                child: ColoredBox(
                  color: Theme.of(context).canvasColor,

                  child:
                      (!hasSearched)
                          ? Center(
                            child: Column(
                              children: [
                                SizedBox(height: size.height * 0.15),
                                Image(
                                  image: const AssetImage('images/search.jpg'),
                                  height: size.height * 0.33,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Find people to connect with.',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          )
                          : (isLoading)
                          ? Center(child: CircularProgressIndicator())
                          : (!userFound)
                          ? Center(
                            child: Text(
                              'No match found!',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                          : ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: matchedUsers.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  border:
                                      (index == matchedUsers.length - 1)
                                          ? null
                                          : Border(
                                            bottom: BorderSide(
                                              color: Colors.black26,
                                              width: 0.75,
                                            ),
                                          ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 30,
                                    child: Text(
                                      matchedUsers[index].name![0]
                                          .toUpperCase(),
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),

                                  title: Text(
                                    matchedUsers[index].name!,
                                    style: TextStyle(fontSize: 18),
                                  ),

                                  trailing: IconButton(
                                    onPressed: () {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                       String newContact = matchedUsers[index].name!;

                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                              'Add Contact',
                                              style: TextStyle(
                                                color: Colors.blue[500],
                                                fontSize: 22,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            content: Text(
                                              "Do you want to add $newContact to your contacts?",
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.black,
                                              ),
                                            ),

                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text(
                                                  'No',
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ),

                                              TextButton(
                                                onPressed: (){
                                                  // pop the alert box first to avoid range errors when a single item is left in the list matchedUsers
                                                  Navigator.pop(context);

                                                  if (currentUser.contacts!
                                                      .contains(
                                                        matchedUsers[index]
                                                            .uid!,
                                                      )) {
                                                    UiHelper.customSnackBar(
                                                      context,
                                                      'Contact already added',
                                                    );
                                                  } else {
                                                    _addContact(
                                                      matchedUsers[index].uid!,
                                                    );

                                                    // Update UI
                                                    setState(() => matchedUsers.removeAt(index));

                                                    UiHelper.customSnackBar(
                                                      context,
                                                      'Added to contacts',
                                                    );
                                                  }
                                                },
                                                child: Text(
                                                  'Yes',
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.add_circle_rounded, color: Colors.black54),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<ChatUser>> findUser(String? user) async {
    if (user == null || user.trim().isEmpty) {
      setState(() {
        userFound = false;
        isLoading = false;
        hasSearched = true;
      });
      return [];
    }

    setState(() {
      isLoading = true;
      userFound = false;
      hasSearched = true;
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<ChatUser> users = [];

    try {
      // Convert search term to lowercase for case-insensitive search
      String searchTerm = user.toLowerCase();

      // Query Firestore: searchKeywords must contain the substring
      QuerySnapshot snapshot =
          await firestore
              .collection("Users")
              .where("searchKeywords", arrayContains: searchTerm)
              .get();

      // Convert docs into usable list of user data + uid
      users =
          snapshot.docs
              .where(
                (doc) =>
                    ((doc.id != ChatDetails.currentUserId)
                        && (!currentUser.contacts!.contains(doc.id))
                    ),
              ) // exclude myself && my friends
              .map((doc) {
                final data = ChatUser.fromJson(
                  doc.data() as Map<String, dynamic>,
                );
                data.uid = doc.id; // store the uid (document ID)
                return data;
              })
              .toList();

      setState(() {
        userFound = users.isNotEmpty;
        isLoading = false;
      });
      return users;
    } catch (ex) {
      if (mounted) {
        UiHelper.customAlertBox(context, "Error: ${ex.toString()}");
      }
      setState(() {
        userFound = false;
        isLoading = false;
      });
      return [];
    }
  }

  void _addContact(String newContactUid) async {
    if(!currentUser.contacts!.contains(newContactUid)) currentUser.contacts!.add(newContactUid);

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .update({'Contacts': FieldValue.arrayUnion([newContactUid])});

    // Update Local Storage
    List<ChatUser> cachedContacts = LocalStorage.getCachedContacts();
    bool alreadyExists = cachedContacts.any((c) => c.uid == newContactUid);

    if(!alreadyExists) {
      cachedContacts.add(
        await ChatDetails.getDetails(newContactUid, forceRefresh: true),
      );
      await LocalStorage.saveContacts(cachedContacts);
    }

    // Update cached current user as well
    await LocalStorage.saveCurrentUser(currentUser);
  }
}
