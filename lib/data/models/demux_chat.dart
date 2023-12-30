import 'package:demux_app/data/models/message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'demux_chat.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
)
class DemuxChat {
  List<Message> messages;

  DemuxChat(
      {required this.messages});

  factory DemuxChat.fromJson(Map<String, dynamic> json) => _$DemuxChatFromJson(json);

  Map<String, dynamic> toJson() => _$DemuxChatToJson(this);

  @override
  String toString() {
    return 'DemuxChat(n_messages: ${messages.length})';
  }
}
