import 'package:demux_app/domain/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_completion_settings.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class ChatCompletionSettings {
  String model;
  // List? functions;
  double? temperature;
  double? topP;
  int? n;
  bool stream = true;
  List? stop;
  int? maxTokens;
  double? presencePenalty;
  double? frequencyPenalty;
  Map? logitBias;

  // Custom settings:
  String? systemPrompt = '';
  bool? systemPromptsAreVisible = true;
  bool? sendEmptyMessage = false;

  ChatCompletionSettings({
    required this.model,
    this.temperature,
    this.topP,
    this.n,
    this.stop,
    this.maxTokens,
    this.presencePenalty,
    this.frequencyPenalty,
    this.logitBias
  });

  factory ChatCompletionSettings.fromJson(Map<String, dynamic> json) =>
      _$ChatCompletionSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ChatCompletionSettingsToJson(this);

  ChatCompletionSettings removeCustomSettings() {
    var copy = ChatCompletionSettings.fromJson(toJson());
    copy
      ..systemPrompt = null
      ..systemPromptsAreVisible = null
      ..sendEmptyMessage = null;
    return copy;
  }

  Map<String, dynamic> getRequestJson() {
    var copy = removeCustomSettings();
    return copy.toJson();
  }

  factory ChatCompletionSettings.initial() {
    return ChatCompletionSettings(
      model: OPENAI_CHAT_COMPLETION_DEFAULT_MODEL,
      temperature: OPENAI_CHAT_COMPLETION_DEFAULT_TEMPERATURE,
    );
  }
}
