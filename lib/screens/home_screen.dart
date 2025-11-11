import 'dart:async';
import 'dart:developer';

import 'package:chat_app/models/chat_details.dart';
import 'package:chat_app/screens/search_screen.dart';
import 'package:chat_app/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../models/chat_user.dart';
import '../models/local_storage.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> lastMessages = {};
  late Stream<List<ChatUser>> _contactStream;
  TextEditingController searchController = TextEditingController();
  ChatUser currentUser = LocalStorage.getCachedCurrentUser()!;
  // List<ChatUser> contacts = [];
  List<ChatUser> filteredContacts = [];
  bool isLoading = false;
  bool showStreamData = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    log('${identityHashCode(this)}');
    super.initState();

    _contactStream = ChatDetails.getContactStream();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => showStreamData = true);
    });
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
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('Chat', style: TextStyle(fontSize: 35)),
        actions: [
          // Profile Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    duration: Duration(milliseconds: 300),
                    reverseDuration: Duration(milliseconds: 300),
                    child: UserProfileScreen(user: currentUser),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.9),
                shadowColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.6),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: Colors.blue[900]!.withValues(alpha: 0.5),
                  ),
                ),
              ),

              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 25),
                  const SizedBox(width: 10),
                  Text(
                    getFirstName(currentUser.name),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: [
            const SizedBox(height: 10),

            // search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBar(
                controller: searchController,
                onTap: () {},
                onChanged: (_) async {},
                backgroundColor: WidgetStateProperty.all(Colors.grey[200]),
                elevation: WidgetStateProperty.all(0),
                leading: Icon(Icons.search),
                hintText: 'Search',
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
                  child: SizedBox(
                    width: size.width,
                    child: StreamBuilder(
                      stream: _contactStream,
                      builder: (context, snapshot) {
                        List<ChatUser> contactList =
                            LocalStorage.getCachedContacts();

                        contactList.sort(
                          (a, b) => (a.name ?? '').toLowerCase().compareTo(
                            (b.name ?? '').toLowerCase(),
                          ),
                        );
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // while waiting
                          log('Waiting');
                          return _showContacts(
                            contactList,
                          ); // show cached users
                        }

                        if (snapshot.connectionState == ConnectionState.none) {
                          log('No connection');
                          return _showContacts(
                            contactList,
                            text: 'No Internet Connection',
                          ); // show cached users with no connection msg
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                SizedBox(height: size.height * 0.15),
                                Image.asset(
                                  'assets/images/message2.jpg',
                                  height: size.height * 0.33,
                                  width: size.width * 0.85,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  'Add contacts to connect with people',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        log('Stream Contacts');
                        contactList = snapshot.data!;
                        LocalStorage.saveContacts(contactList);
                        // lastMessages = ChatDetails.getAllCachedLastMessages(contactList);
                        return _showContacts(
                          contactList,
                        ); // show users from stream
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // add contacts button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: Duration(milliseconds: 300),
              reverseDuration: Duration(milliseconds: 300),
              child: SearchScreen(),
            ),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(30),
        ),
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.9),
        child: Icon(Icons.add_comment_rounded, color: Colors.white),
      ),
    );
  }

  Card userCard(ChatUser otherUser) {
    // Map<String, dynamic>? msgData = {};
    String sender = '';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 1,
      child: StreamBuilder(
        stream: ChatDetails.getLastMsgStream(otherUser),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final msgData = data?.data();

          if (msgData != null) {
            log('${msgData.keys}');
            sender =
                (msgData['lastMessageFrom'] == ChatDetails.currentUserId)
                    ? 'You'
                    : getFirstName(otherUser.name);
          }

          return ListTile(
            onTap: () {
              // final otherUserId = otherUser.uid;
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  duration: Duration(milliseconds: 300),
                  reverseDuration: Duration(milliseconds: 300),
                  child: ChatScreen(
                    otherUser: otherUser,
                    chatRoomId: ChatDetails.generateChatRoomId(otherUser.uid!),
                  ),
                ),
              );
            },
            leading: CircleAvatar(
              radius: 30,
              child: Text(
                otherUser.name![0].toUpperCase(),
                style: TextStyle(fontSize: 25),
              ),
            ),

            title: Text(
              otherUser.name!,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),

            subtitle:
                (msgData?['lastMessage'] != null)
                    ? Text(
                      '$sender: ${msgData?['lastMessage']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                    : Text(
                      'Tap to begin conversation',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),

            trailing: Text(
              (msgData?['lastMessageTime'] != null)
                  ? ChatDetails.getDate(
                    context: context,
                    time: msgData?['lastMessageTime'],
                  )
                  : 'New',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }

  // get the first name of the user
  String getFirstName(String? name) {
    if (name == null) return 'User';

    int index = name.indexOf(' ');
    if (index == -1) index = name.length;
    return name.substring(0, index);
  }

  Widget _showContacts(List<ChatUser> list, {String? text}) {
    return Column(
      children: [
        if (text != null)
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return userCard(list[index]);
            },
          ),
        ),
      ],
    );
  }
}
