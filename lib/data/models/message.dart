import 'package:json_annotation/json_annotation.dart';

part "message.g.dart";

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class Message {
  final String role;
  String content;

  // Custom settings:
  String? modelUsed;

  Message(this.role, this.content, {this.modelUsed});

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message removeCustomSettings() {
    var copy = Message.fromJson(toJson());
    copy.modelUsed = null;
    return copy;
  }

  Map<String, dynamic> getRequestJson() {
    var copy = removeCustomSettings();
    return copy.toJson();
  }
}

List<Map<String, dynamic>> messageListToJson(List<Message> messages) {
  List<Map<String, dynamic>> messagesJson =
      messages.map((message) => message.getRequestJson()).toList();
  return messagesJson;
}

List<Message> jsonToMessageList(List<dynamic> messagesJson) {
  List<Message> messages =
      messagesJson.map((messageJson) => Message.fromJson(messageJson)).toList();
  return messages;
}
