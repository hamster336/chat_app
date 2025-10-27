// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatUserAdapter extends TypeAdapter<ChatUser> {
  @override
  final int typeId = 0;

  @override
  ChatUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatUser(
      contacts: (fields[1] as List?)?.cast<String>(),
      number: fields[2] as String?,
      searchKeywords: (fields[3] as List?)?.cast<String>(),
      bio: fields[4] as String?,
      name: fields[5] as String?,
    )..uid = fields[0] as String?;
  }

  @override
  void write(BinaryWriter writer, ChatUser obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.contacts)
      ..writeByte(2)
      ..write(obj.number)
      ..writeByte(3)
      ..write(obj.searchKeywords)
      ..writeByte(4)
      ..write(obj.bio)
      ..writeByte(5)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
