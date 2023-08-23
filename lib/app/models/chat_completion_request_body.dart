import 'package:demux_app/app/models/message.dart';
import 'package:json_annotation/json_annotation.dart';

part "chat_completion_request_body.g.dart";

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class ChatCompletionRequestBody {
  final String model;
  List<Message> messages;
  // List? functions;
  double temperature;
  double? topP;
  int? n;
  bool stream = true;
  List? stop;
  int? maxTokens;
  double? presencePenalty;
  double? frequencyPenalty;
  Map? logitBias;

  ChatCompletionRequestBody({
    required this.model,
    required this.messages,
    this.temperature = 1,
    this.topP,
  });

  factory ChatCompletionRequestBody.fromJson(Map<String, dynamic> json) =>
      _$ChatCompletionRequestBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ChatCompletionRequestBodyToJson(this);
}
