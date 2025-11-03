import 'package:chat_app/models/local_storage.dart';
import 'package:chat_app/models/message_card.dart';
import 'package:chat_app/screens/contact_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/chat_details.dart';
import '../models/chat_user.dart';
import '../models/messages.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser otherUser;
  final String chatRoomId;

  const ChatScreen({
    super.key,
    required this.otherUser,
    required this.chatRoomId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _message = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _scrollController = ScrollController();

  late ChatUser currentUser;
  bool isLoading = false;
  bool isTyping = false;

  late Stream<QuerySnapshot<Map<String, dynamic>>> _msgStream;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();

    // creating msg stream outside the build
    _msgStream = ChatDetails.getAllMessages(widget.otherUser);


    _textController.addListener(() {
      final isCurrentlyTyping = _textController.text.trim().isNotEmpty;
      if (isCurrentlyTyping != isTyping) {
        setState(() => isTyping = isCurrentlyTyping);
      }
    });
  }

  void _loadDetails() async {
    _updateLoadingState(value: true);
    currentUser = await ChatDetails.fetchCurrentUser();
    _message = LocalStorage.getCachedMessages(widget.chatRoomId);
    _updateLoadingState();
  }

  void _updateLoadingState({bool value = false}) {
    if (!mounted) return;

    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(size),
        ),

        body: ColoredBox(
          color: Colors.lightBlue.shade50,
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: _msgStream,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return const Center(child: CircularProgressIndicator());

                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _message = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

                        if(_message.isEmpty) return const Center(child: Text('Sayy Hii!! 👋'));

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300), // smooth scroll duration
                              curve: Curves.easeOut, // easing curve for natural motion
                            );
                          }
                        });

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: _message.length,
                          itemBuilder: (context, index) {
                            return MessageCard(
                              message: _message[index],
                              size: size
                            );
                          },
                        );
                    }
                  },
                ),
              ),

              // bottom message typing and sending widgets
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(25),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.emoji_emotions, size: 28),
                              color: Theme.of(context).primaryColor,
                            ),

                            Expanded(
                              child: TextField(
                                focusNode: _focusNode,
                                controller: _textController,
                                decoration: InputDecoration(
                                  hintText: 'Send a message',
                                  border: InputBorder.none,
                                ),
                                maxLines: null,
                              ),
                            ),

                            // attach Document button
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 50),
                              child: (isTyping) ? null : _attachDocument(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
                        final msg = _textController.text.trim();
                        if(msg.isNotEmpty){
                          ChatDetails.sendMessage(msg, widget.otherUser);
                          _textController.clear();
                        }
                      },
                      icon: Icon(Icons.send, size: 30),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.all(9),
                        shape: CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // popupMenu to attach assets and documents
  PopupMenuButton _attachDocument() {
    return PopupMenuButton<String>(
      offset: Offset(-10, -100),
      itemBuilder:
          (context) => <PopupMenuEntry<String>>[
            PopupMenuItem(
              value: 'camera',
              child: menuItem(Icons.camera_alt, 'Camera'),
            ),
            PopupMenuItem(
              value: 'gallery',
              child: menuItem(Icons.image, 'Gallery'),
            ),
          ],
      onSelected: (String value) {
        switch (value) {
          case 'camera':
            break;
          case 'gallery':
            break;
          default:
            break;
        }
      },
      popUpAnimationStyle: AnimationStyle(
        duration: Duration(milliseconds: 350),
      ),
      // color: Colors.white60,
      icon: Icon(
        Icons.attach_file,
        size: 28,
        color: Theme.of(context).primaryColor,
      ),
      elevation: 1,
      menuPadding: EdgeInsets.all(0),
    );
  }

  // menuItem for PopupMenu
  Row menuItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 25),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  // Title widget for AppBar
  Widget? _appBar(Size size) {
    return Row(
      children: [
        // back navigation
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
          style: IconButton.styleFrom(padding: EdgeInsets.zero),
        ),

        // profile pict ure
        GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ContactProfileScreen(contact: widget.otherUser),
                ),
              ),
          child: CircleAvatar(
            radius: size.shortestSide * 0.05,
            child: Text(
              // (isLoading) ? 'U' :
              widget.otherUser.name.toString().substring(0, 1),
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Flexible(
          flex: 6,
          child:
              Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: size.width * 0.6,
                        child: Text(
                          widget.otherUser.name.toString(),
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Text(
                        'Offline',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }
}
