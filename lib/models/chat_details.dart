import 'dart:developer';
import 'package:chat_app/models/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_user.dart';
import 'local_storage.dart';

class ChatDetails {
  static String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  static ChatUser? currentUser = LocalStorage.getCurrentUser();

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

  static Future<ChatUser> getCurrUser({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      ChatUser? cachedUser = LocalStorage.getCurrentUser();
      if (cachedUser != null) {
        return cachedUser;
      }
    }

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
  static generateChatRoomId(String otherUser) {
    List<String> userIds = [currentUserId, otherUser];
    userIds.sort();
    return userIds.join('_');
  }

  // get all messages from a chat room
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return FirebaseFirestore.instance
        .collection('chats/${generateChatRoomId(user.uid!)}/messages/')
        .snapshots();
  }

  // send a message
  static Future<void> sendMessage(String msg, ChatUser otherUser) async {
    // message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final Message message = Message(
      msg: msg,
      read: '',
      fromId: currentUserId,
      toId: otherUser.uid!,
      type: Type.text,
      sent: time,
    );

    final ref = FirebaseFirestore.instance.collection('chats/${generateChatRoomId(otherUser.uid!)}/messages');
    await ref.doc(time).set(message.toJson());
  }

  // format time into readable format
  static String formatTime({required BuildContext context, required String time}){
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  // update the status of the message
  static Future<void> updateMessageStatus(Message message) async{
    FirebaseFirestore.instance.
        collection('chats/${generateChatRoomId(message.fromId)}/messages/').doc(message.sent).update({
          'read': DateTime.now().millisecondsSinceEpoch.toString(),
        });
  }

  // get the last message of each contact
  static Future<Message?> getLastMessage(ChatUser user) async{

    return null;
  }
}
