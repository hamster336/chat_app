import 'dart:developer';
import 'package:chat_app/models/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_user.dart';
import 'local_storage.dart';

class ChatDetails {
  static String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  //update currentUserId after each signIn
  static void updateCurrentUserId(){
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  /// get cached currentUser
  static ChatUser? currentUser = LocalStorage.getCurrentUser();

  /// get details of a user
  static Future<ChatUser> getDetails(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      ChatUser? cachedUser = LocalStorage.getContact(userId);
      if (cachedUser != null) return cachedUser;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot doc =
          await firestore.collection('Users').doc(userId).get();

      if (doc.exists) {
        final data = ChatUser.fromJson(doc.data() as Map<String, dynamic>);
        data.uid = doc.id;

        await LocalStorage.addContact(data);
        return data;
      } else {
        throw Exception('User not found');
      }
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  /// get contacts of a user
  static Future<List<ChatUser>> getContacts({bool forceRefresh = false}) async {
    // Try to get from cache first
    if (!forceRefresh) {
      List<ChatUser> cachedContacts = LocalStorage.getCachedContacts();
      if (cachedContacts.isNotEmpty) {
        return cachedContacts;
      }
    }

    // Fetch from Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('Users').doc(currentUserId).get();

      List<dynamic> contactIds = userDoc.get('Contacts') ?? [];
      if (contactIds.isEmpty) return [];

      List<ChatUser> allContacts = [];

      for (int i = 0; i < contactIds.length; i += 10) {
        List<String> batch =
            contactIds
                .sublist(
                  i,
                  (i + 10 > contactIds.length) ? contactIds.length : i + 10,
                )
                .cast<String>();

        QuerySnapshot batchSnapshot =
            await firestore
                .collection('Users')
                .where(FieldPath.documentId, whereIn: batch)
                .get();

        for (var doc in batchSnapshot.docs) {
          final ChatUser contactData = ChatUser.fromJson(
            doc.data() as Map<String, dynamic>,
          );
          contactData.uid = doc.id;
          allContacts.add(contactData);
        }
      }

      // Save to local storage
      await LocalStorage.saveContacts(allContacts);
      return allContacts;
    } catch (ex) {
      log(ex.toString());
      return [];
    }
  }

  ///
  static Future<ChatUser> fetchCurrentUser() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUserId)
              .get();

      if (doc.exists) {
        final data = ChatUser.fromJson(doc.data() as Map<String, dynamic>);
        data.uid = doc.id;

        LocalStorage.saveCurrentUser(data);
        return data;
      } else {
        throw Exception('User not found');
      }
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  // chats (collection) -----> chatRoomId (doc) -----> messages (collection) -----> message (doc)
  static String generateChatRoomId(String otherUser) {
    List<String> userIds = [currentUserId, otherUser];
    userIds.sort();
    return userIds.join('_');
  }

  /// get all messages from a chat room
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return FirebaseFirestore.instance
        .collection('chats/${generateChatRoomId(user.uid!)}/messages/')
        .snapshots();
  }

  /// send a message
  static Future<void> sendMessage(String msg, ChatUser otherUser) async {
    final chatRoomId = generateChatRoomId(otherUser.uid!);

    // message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final Message message = Message(
      msg: msg,
      read: '',
      fromId: currentUserId,
      toId: otherUser.uid!,
      type: MessageType.text,
      sent: time,
    );

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatRoomId);

    // store actual message inside messages collection
    await chatRef.collection('messages').doc(time).set(message.toJson());

    // update the chatRoom with last message info
    await chatRef.set({
      'participants' : [currentUserId, otherUser.uid],
      'lastMessage' : msg,
      'lastMessageTime' : time,
      'lastMessageFrom' : currentUserId,
    }, SetOptions(merge: true));
  }

  /// format time into readable format
  static String formatTime({required BuildContext context, required String time}){
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  /// update the status of the message
  static Future<void> updateMessageStatus(Message message) async{
    FirebaseFirestore.instance.
        collection('chats/${generateChatRoomId(message.fromId)}/messages/').doc(message.sent).update({
          'read': DateTime.now().millisecondsSinceEpoch.toString(),
        });
  }

  /// get the last message of each contact
  static Future<Map<String, dynamic>?> getLastMessage(ChatUser user) async{
    final chatRoomId = generateChatRoomId(user.uid!);
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatRoomId);

    try{
      final doc = await chatRef.get();
      final data = doc.data();

      if(data != null){
        return {
          'msg' : data['lastMessage'],
          'msgFrom' : data['lastMessageFrom'],
          'msgTime' : getDate(data['lastMessageTime']),
          'timeStamp' : data['lastMessageTime'],
        };
      }else{
        return null;
      }

    }catch (ex) {
      log(ex.toString());
      return null;
    }
  }

  /// get formated time
  static String getDate(String? time) {
    if(time == null) return '';

    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    DateTime now = DateTime.now();

    final difference = date.difference(now).inDays;

    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    if(difference == 0) return 'Today';
    if(difference == 1) return 'Yesterday';

    if(date.year < now.year) return '${date.day}/${date.month}/${date.year}';

    return '${date.day} ${months[date.month - 1]}';
  }
}
