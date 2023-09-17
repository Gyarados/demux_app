import 'package:demux_app/data/models/chat_completion_settings.dart';
import 'package:demux_app/data/models/message.dart';
import 'package:demux_app/data/utils/uuid_generator.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
)
class Chat {
  List<Message> messages;
  ChatCompletionSettings chatCompletionSettings;
  @JsonKey(includeIfNull: true) // Ensures that uuid is always included
  final String uuid;
  String name;

  Chat(
      {required this.messages,
      required this.chatCompletionSettings,
      String? uuid,
      this.name = "New chat"})
      : uuid = uuid ?? UUIDGenerator.newUUID;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);

  factory Chat.initial() {
    return Chat(
      chatCompletionSettings: ChatCompletionSettings.initial(),
      messages: [],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chat && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'Chat(name: $name, uuid: $uuid, n_messages: ${messages.length})';
  }
}
