import 'package:json_annotation/json_annotation.dart';

part "message.g.dart";

@JsonSerializable()
class Message {
  final String role;
  String content;

  Message(this.role, this.content);

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

List<Map<String, dynamic>> messageListToJson(List<Message> messages) {
  List<Map<String, dynamic>> messagesJson =
      messages.map((message) => message.toJson()).toList();
  return messagesJson;
}

List<Message> jsonToMessageList(List<dynamic> messagesJson) {
  List<Message> messages =
      messagesJson.map((messageJson) => Message.fromJson(messageJson)).toList();
  return messages;
}