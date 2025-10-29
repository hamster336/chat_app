import 'package:chat_app/models/chat_details.dart';
import 'package:chat_app/screens/search_screen.dart';
import 'package:chat_app/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../models/chat_user.dart';
import '../models/local_storage.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool forceRefresh;
  const HomeScreen({super.key, this.forceRefresh = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  ChatUser? currentUser = LocalStorage.getCurrentUser();
  List<ChatUser> contacts = [];
  List<ChatUser> filteredContacts = [];
  bool isLoading = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _contactList();

    if (widget.forceRefresh) {
      _updateUsers();
    }
  }

  void _contactList() async {
    updateLoadingState(value: true);
    List<ChatUser> cachedContacts = LocalStorage.getCachedContacts();
    if (cachedContacts.isNotEmpty) {
      contacts = cachedContacts;
      updateLoadingState();
      return;
    }

    final fetchedContacts = await ChatDetails.getContacts(forceRefresh: true);

    contacts = fetchedContacts;
    updateLoadingState();
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
                    child: UserProfileScreen(user: currentUser!),
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
                    getFirstName(currentUser?.name),
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
                    child:
                        (isLoading)
                            ? Center(child: CircularProgressIndicator())
                            : (contacts.isEmpty)
                            ? RefreshIndicator(
                              onRefresh: () async => _updateUsers(),
                              child: SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                child: Center(
                                  child: Column(
                                    children: [
                                      SizedBox(height: size.height * 0.15),
                                      Image(
                                        image: const AssetImage(
                                          'images/message2.jpg',
                                        ),
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
                                ),
                              ),
                            )
                            : RefreshIndicator(
                              onRefresh: () async => _updateUsers(),
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                itemCount: contacts.length,
                                itemBuilder: (context, index) {
                                  return userCard(contacts[index]);
                                },
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // add contacts
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: Duration(milliseconds: 300),
              reverseDuration: Duration(milliseconds: 300),
              child: SearchScreen(),
              childCurrent: HomeScreen(),
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 1,
      child: ListTile(
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
              // childCurrent: HomeScreen(),
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),

        subtitle: Text('Last Message', maxLines: 1),

        trailing: Text(
          '1 Jan',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _updateUsers() async {
    final fetchedContacts = await ChatDetails.getContacts(forceRefresh: true);

    final fetchedUser = await ChatDetails.getCurrUser(forceRefresh: true);

    if (mounted) {
      setState(() => contacts = fetchedContacts);
      LocalStorage.saveCurrentUser(fetchedUser);
    }
  }

  String getFirstName(String? name) {
    if (name == null) return 'User';

    int index = name.indexOf(' ');
    if (index == -1) index = name.length;
    return name.substring(0, index);
  }
}
