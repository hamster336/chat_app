class Message{

  late final String read;
  late final String fromId;
  late final String msg;
  late final String toId;
  late final String sent;
  late final MessageType type;

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

enum MessageType{text, image}