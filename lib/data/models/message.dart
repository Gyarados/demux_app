import 'dart:convert';
import 'dart:typed_data';

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
  @JsonKey(
    fromJson: imageFromJson,
    toJson: imageToJson,
  )
  Uint8List? image;

  Message(
    this.role,
    this.content, {
    this.image,
    this.modelUsed,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  copyWith({
    String? role,
    String? content,
  }) {
    return Message(
      role ?? this.role,
      content ?? this.content,
    );
  }

  Message removeCustomSettings() {
    return copyWith();
  }

  @override
  String toString() {
    return 'Message(role: $role, content: $content, modelUsed: $modelUsed, image: $image)';
  }
}

List<Map<String, dynamic>> messageListToJson(List<Message> messages) {
  List<Map<String, dynamic>> messagesJson = messages.map((message) {
    if (message.image == null) {
      return message.removeCustomSettings().toJson();
    } else {
      return <String, dynamic>{
        "role": message.role,
        "content": [
          {
            "type": "text",
            "text": message.content,
          },
          {
            "type": "image_url",
            "image_url": {
              "url": "data:image/jpeg;base64,${base64Encode(message.image!)}",
            },
          }
        ]
      };
    }
  }).toList();
  return messagesJson;
}

List<Message> jsonToMessageList(List<dynamic> messagesJson) {
  List<Message> messages =
      messagesJson.map((messageJson) => Message.fromJson(messageJson)).toList();
  return messages;
}

Uint8List? imageFromJson(Map<String, dynamic>? json) {
  if (json == null || json["base64"] == null) {
    return null;
  }
  return base64Decode(json["base64"]);
}

Map<String, dynamic>? imageToJson(Uint8List? image) {
  if (image == null) {
    return null;
  }
  return {"base64": base64Encode(image)};
}
