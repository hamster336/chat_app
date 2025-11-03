import 'package:hive_flutter/hive_flutter.dart';
import 'chat_user.dart';
import 'messages.dart';

class LocalStorage {
  static const String _contactsBox = 'contacts_box';
  static const String _currentUserBox = 'current_user_box';
  static const String _messagesBox = 'messages_Box';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ChatUserAdapter());
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(MessageTypeAdapter());
    await Hive.openBox<ChatUser>(_contactsBox);
    await Hive.openBox<ChatUser>(_currentUserBox);
    await Hive.openBox<Message>(_messagesBox);
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
  static ChatUser? getContact(String uid) {
    final box = Hive.box<ChatUser>(_contactsBox);
    return box.get(uid);
  }

  /// Add single contact
  static Future<void> addContact(ChatUser contact) async {
    if (contact.uid == null) return;
    final box = Hive.box<ChatUser>(_contactsBox);
    await box.put(contact.uid, contact);
  }

  /// Delete a contact
  static Future<void> deleteContact(String uid) async {
    final box = Hive.box<ChatUser>(_contactsBox);
    await box.delete(uid);
  }

  /// Save current user
  static Future<void> saveCurrentUser(ChatUser user) async {
    final box = Hive.box<ChatUser>(_currentUserBox);
    await box.put('current_user', user);
  }

  /// Get current user
  static ChatUser? getCurrentUser() {
    final box = Hive.box<ChatUser>(_currentUserBox);
    return box.get('current_user');
  }

  /// Clear all data (on logout)
  static Future<void> clearAll() async {
    await Hive.box<ChatUser>(_contactsBox).clear();
    await Hive.box<ChatUser>(_currentUserBox).clear();
  }

  // ------> Messages caching methods <------

  /// save messages for a chatRoom
  static Future<void> saveMessages(String chatRoomId, List<Message> messages)async {
    final box = Hive.box(_messagesBox);   // same as writing Hive.box<List>(_messageBox)
    await box.put(chatRoomId, messages);
  }

  /// add a single message to existing chat cache
  static Future<void> addMessageToChat(String chatRoomId, Message message) async{
    final box = Hive.box(_messagesBox);
    final existing = (box.get(chatRoomId, defaultValue: <Message>[])as List).cast<Message>();
    existing.add(message);
    await box.put(chatRoomId, existing);
  }

  /// Get all cached messages for a chatRoom
  static List<Message> getCachedMessages(String chatRoomId){
    final box = Hive.box(_messagesBox);
    return (box.get(chatRoomId, defaultValue: <Message>[]) as List).cast<Message>();
  }

  /// Get last message for a chatRoom
  // static Message? getLastMessage(String chatRoomId) {
  //   final box = Hive.box(_messagesBox);
  //   final cachedMessages = (box.get(chatRoomId, defaultValue: <Message>[]) as List).cast<Message>();
  //   if(cachedMessages.isNotEmpty) return cachedMessages[cachedMessages.length-1];
  //   return null;
  // }

  /// Clear all messages for a specific chat
  static Future<void> clearMessages(String chatRoomId) async{
    final box = Hive.box(_messagesBox);
    await box.delete(chatRoomId);
  }

  /// Clear all messages (on logOut)
  static Future<void> clearAllMessages() async{
    final box = Hive.box(_messagesBox);
    await box.clear();
  }
}