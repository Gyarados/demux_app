import 'package:demux_app/data/models/chat_completion_settings.dart';
import 'package:demux_app/data/models/message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class Chat {
  List<Message> messages;
  final ChatCompletionSettings chatCompletionSettings;

  Chat({
    required this.messages,
    required this.chatCompletionSettings
  });

  factory Chat.fromJson(Map<String, dynamic> json) =>
      _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);

  factory Chat.initial() {
    return Chat(
      chatCompletionSettings: ChatCompletionSettings.initial(),
      messages: [],
    );
  }
}
