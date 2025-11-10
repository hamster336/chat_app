import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'messages.g.dart';

@HiveType(typeId: 1)
class Message extends HiveObject{

  @HiveField(0) late final String msg;
  @HiveField(1) late final String read;
  @HiveField(2) late final String fromId;
  @HiveField(3) late final String toId;
  @HiveField(4) late final String sent;
  @HiveField(5) late final MessageType type;

  Message({
    required this.msg,
    required this.read,
    required this.fromId,
    required this.toId,
    required this.type,
    required this.sent,
  });


  Message.fromJson(Map<String, dynamic> json){
    msg = json['msg'].toString();
    read = json['read'].toString();
    fromId = json['from_id'].toString();
    toId = json['to_id'].toString();
    type = json['type'].toString() == MessageType.image.name? MessageType.image : MessageType.text;
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['read'] = read;
    data['from_id'] = fromId;
    data['to_id'] = toId;
    data['type'] = type.name;
    data['sent'] = sent;
    return data;
  }
}


@HiveType(typeId: 2)
enum MessageType{@HiveField(0)text, @HiveField(1) image}