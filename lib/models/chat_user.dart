import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'chat_user.g.dart';


@HiveType(typeId: 0)
class ChatUser extends HiveObject{
  @HiveField(0) String? uid;
  @HiveField(1) List<String>? contacts;
  @HiveField(2) String? number;
  @HiveField(3) List<String>? searchKeywords;
  @HiveField(4) String? bio;
  @HiveField(5) String? name;

  ChatUser({
    this.contacts,
    this.number,
    this.searchKeywords,
    this.bio,
    this.name,
  });

  ChatUser.fromJson(Map<String, dynamic> json){
    contacts = json['Contacts'].cast<String>() ?? [];
    number = json['Number'];
    searchKeywords = json['searchKeywords'].cast<String>();
    bio = json['Bio'];
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Contacts'] = contacts;
    data['Number'] = number;
    data['searchKeywords'] = searchKeywords;
    data['Bio'] = bio;
    data['Name'] = name;
    return data;
  }
}
