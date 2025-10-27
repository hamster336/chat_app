class Message {
  Message({
    required this.msg,
    required this.read,
    required this.fromId,
    required this.toId,
    required this.type,
    required this.sent,
  });

  late final String msg;
  late final String read;
  late final String fromId;
  late final String toId;
  late final String sent;
  late final Type type;

  Message.fromJson(Map<String, dynamic> json){
    msg = json['msg'].toString();
    read = json['read'].toString();
    fromId = json['from_id'].toString();
    toId = json['to_id'].toString();
    type = json['type'].toString() == Type.image.name? Type.image : Type.text;
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

enum Type{text, image}