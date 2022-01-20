import 'User.dart';

class Message {
  String content;
  User author;
  String created_at;

  Message(this.content, this.author, this.created_at);

  Message.fromJson(Map<String, dynamic> json) :
      content = json["content"],
      author = User.fromJson(json["author"]),
      created_at = json["created_at"];

    Map<String, dynamic> toJson() => {
      "content" : content,
      "author" : author.toJson(),
      "created_at" : created_at
    };
}