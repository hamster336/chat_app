import 'package:hive_ce_flutter/hive_flutter.dart';
import 'chat_user.dart';
import 'dart:developer';

class LocalStorage {
  static const String _contactsBox = 'contacts_box';
  static const String _currentUserBox = 'current_user_box';
  static const String _lastMessageBox = 'last_msg_box';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ChatUserAdapter());
    await Hive.openBox<ChatUser>(_contactsBox);
    await Hive.openBox<ChatUser>(_currentUserBox);
    await Hive.openBox<Map>(_lastMessageBox);
  }

  //------> User and contacts caching methods <------
  /// Save contacts
  static Future<void> saveContacts(List<ChatUser> contacts) async {
    final box = Hive.box<ChatUser>(_contactsBox);
    await box.clear();
    for (var contact in contacts) {
      if (contact.uid != null) {
        await box.put(contact.uid, contact);
      }
    }
  }

  /// Get all contacts
  static List<ChatUser> getCachedContacts() {
    final box = Hive.box<ChatUser>(_contactsBox);
    return box.values.toList();
  }

  /// Get single contact by uid
  static ChatUser? getCachedContact(String uid) {
    final box = Hive.box<ChatUser>(_contactsBox);
    return box.get(uid);
  }

  /// Add single contact
  static Future<void> cacheContact(ChatUser contact) async {
    if (contact.uid == null) return;
    final box = Hive.box<ChatUser>(_contactsBox);
    await box.put(contact.uid, contact);
  }

  /// Delete a contact
  static Future<void> deleteCachedContact(String uid) async {
    final box = Hive.box<ChatUser>(_contactsBox);
    await box.delete(uid);
  }

  /// Save current user
  static Future<void> saveCurrentUser(ChatUser user) async {
    final box = Hive.box<ChatUser>(_currentUserBox);
    await box.put('current_user', user);
  }

  /// Get current user
  static ChatUser? getCachedCurrentUser() {
    final box = Hive.box<ChatUser>(_currentUserBox);
    return box.get('current_user');
  }

  /// Clear all data (on logout)
  static Future<void> clearAll() async {
    await Hive.box<ChatUser>(_contactsBox).clear();
    await Hive.box<ChatUser>(_currentUserBox).clear();
    await Hive.box<Map>(_lastMessageBox).clear();
  }

  /// store last Message for a contact
  static Future<void> cacheLastMesage(
    String uid,
    Map<String, dynamic> msg,
  ) async {
    final box = Hive.box<Map>(_lastMessageBox);
    await box.put(uid, msg);
    log('last msg cached');
  }

  /// get the last Message for a contact
  static Map<String, dynamic>? getCachedLastMessage(String uid) {
    final box = Hive.box<Map>(_lastMessageBox);
    final map = box.get(uid, defaultValue: {});
     if(map != null) {
       return {
      'lastMessage' : map['lastMessage'],
      'lastMessageFrom' : map['lastMessageFrom'],
      'lastMessageTime' : map['lastMessageTime']
      };
     }else{
      return null;
     }
  }
}
