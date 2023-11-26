// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_completion_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatCompletionSettings _$ChatCompletionSettingsFromJson(
        Map<String, dynamic> json) =>
    ChatCompletionSettings(
      model: json['model'] as String,
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      n: json['n'] as int?,
      stop: json['stop'] as List<dynamic>?,
      maxTokens: json['max_tokens'] as int?,
      presencePenalty: (json['presence_penalty'] as num?)?.toDouble(),
      frequencyPenalty: (json['frequency_penalty'] as num?)?.toDouble(),
      logitBias: json['logit_bias'] as Map<String, dynamic>?,
      systemPrompt: json['system_prompt'] as String?,
      sendEmptyMessage: json['send_empty_message'] as bool? ?? false,
      systemPromptsAreVisible:
          json['system_prompts_are_visible'] as bool? ?? true,
    )..stream = json['stream'] as bool;

Map<String, dynamic> _$ChatCompletionSettingsToJson(
    ChatCompletionSettings instance) {
  final val = <String, dynamic>{
    'model': instance.model,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('temperature', instance.temperature);
  writeNotNull('top_p', instance.topP);
  writeNotNull('n', instance.n);
  val['stream'] = instance.stream;
  writeNotNull('stop', instance.stop);
  writeNotNull('max_tokens', instance.maxTokens);
  writeNotNull('presence_penalty', instance.presencePenalty);
  writeNotNull('frequency_penalty', instance.frequencyPenalty);
  writeNotNull('logit_bias', instance.logitBias);
  writeNotNull('system_prompt', instance.systemPrompt);
  writeNotNull('system_prompts_are_visible', instance.systemPromptsAreVisible);
  writeNotNull('send_empty_message', instance.sendEmptyMessage);
  return val;
}
