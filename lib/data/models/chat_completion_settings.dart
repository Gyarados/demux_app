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
  String? systemPrompt;
  bool? systemPromptsAreVisible;
  bool? sendEmptyMessage;

  ChatCompletionSettings(
      {required this.model,
      this.temperature,
      this.topP,
      this.n,
      this.stop,
      this.maxTokens,
      this.presencePenalty,
      this.frequencyPenalty,
      this.logitBias,
      this.systemPrompt,
      this.sendEmptyMessage = false,
      this.systemPromptsAreVisible = true});

  ChatCompletionSettings copyWith({
    String? model,
    // List? functions,
    double? temperature,
    double? topP,
    int? n,
    List? stop,
    int? maxTokens,
    double? presencePenalty,
    double? frequencyPenalty,
    Map? logitBias,
    String? systemPrompt,
    bool? systemPromptsAreVisible,
    bool? sendEmptyMessage,
  }) {
    return ChatCompletionSettings(
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      n: n ?? this.n,
      stop: stop ?? this.stop,
      maxTokens: maxTokens ?? this.maxTokens,
      presencePenalty: presencePenalty ?? this.presencePenalty,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      logitBias: logitBias ?? this.logitBias,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      systemPromptsAreVisible:
          systemPromptsAreVisible ?? this.systemPromptsAreVisible,
      sendEmptyMessage: sendEmptyMessage ?? this.sendEmptyMessage,
    );
  }

  factory ChatCompletionSettings.fromJson(Map<String, dynamic> json) =>
      _$ChatCompletionSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ChatCompletionSettingsToJson(this);

  ChatCompletionSettings removeCustomSettings() {
    return copyWith()
      ..systemPromptsAreVisible = null
      ..sendEmptyMessage = null;
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

  @override
  String toString() {
    return 'ChatCompletionSettings(model: $model, temperature: $temperature, topP: $topP, n: $n, stream: $stream, stop: $stop, maxTokens: $maxTokens, presencePenalty: $presencePenalty, frequencyPenalty: $frequencyPenalty, logitBias: $logitBias, systemPrompt: $systemPrompt, systemPromptsAreVisible: $systemPromptsAreVisible, sendEmptyMessage: $sendEmptyMessage)';
  }
}
